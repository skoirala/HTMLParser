

public class ADSpace {

    public func load(adType: ADSpaceADType) {
        
        let urlString = jsonURLS.random()
        
        jsonRequest.request(path: urlString) { [weak self] (result: Result<JSON>) in
            
            guard let weakSelf = self else { return }
            
            switch result {
            case let .Success(json):
                let adContent = weakSelf.createADContent(json: json)
                weakSelf.loadADViewDetail(content: adContent, forType: adType)

            case let .Failure(error):
                weakSelf.delegate?.adSpace(adSpace: weakSelf, didFailWithError: error)
            }
        }
    }
    
    private func createADContent(json: JSON) -> ADSpaceContent {
        
        let id = json["id"]!.string
        let contentValue = json["type"]?.string
        let contentType = ADSpaceContentType(rawValue: contentValue!)!
        
        let url = json["url"]!.string
        let width = json["width"]!.cgFloat
        let height = json["height"]!.cgFloat
        
        let actionElement = json["action"]?["element"]?.string
        let actionURL = json["action"]?["url"]?.string
        
        return ADSpaceContent(id: id,
                              type: contentType,
                              url: url,
                              width: width,
                              height: height,
                              actionElement: actionElement,
                              actionURL: actionURL)
    }

    
    private func loadADViewDetail(content: ADSpaceContent, forType type: ADSpaceADType) {
        
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.loadADViewDetail(content: content, forType:type)
            }
            return
        }
        
        if content.type == .image {
        
            let imageRequest = ADSpaceImageRequest()
            
            imageRequest.request(path: content.url, useBasePath: false) { [weak self] imageResult in
                self?.handle(result:imageResult, for: content, forType: type)
            }
        } else if content.type == .html {
            let htmlRequest = ADSpaceHTMLRequest()
            htmlRequest.request(path: content.url, useBasePath: false) { [weak self] htmlResult in
                self?.handle(result:htmlResult, for: content, forType: type)
            }

        } else if  content.type == .video {
            self.handle(result:Result.Success(URL(string: content.url)!), for:content, forType: type)
        }
    }
    
    
    private func handle<T: ADSpaceViewContentType>(result: Result<T>, for content: ADSpaceContent, forType type: ADSpaceADType) {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.handle(result: result, for: content, forType:type)
            }
            return
        }
        
        switch result {
        case let .Success(resultContent):
            createADSpaceView(resultContent, content: content, type: type)
        case let .Failure(error):
            self.delegate?.adSpace(adSpace: self, didFailWithError: error)
        }
    }
    
    private func createADSpaceView<T: ADSpaceViewContentType>(_ viewContent: T, content: ADSpaceContent, type: ADSpaceADType) {
        switch type {
        case let .interstitial(in: viewController):
            loadFullScreen(viewContent, content: content, viewController: viewController)
        case .banner:
            loadBanner(viewContent, content: content)
        }
    }
    
    private func loadFullScreen<T: ADSpaceViewContentType>(_ viewContent: T, content: ADSpaceContent, viewController: UIViewController) {
        var adSpaceView: ADSpaceView<T>!

        let onClose = { [weak self] in
            guard let weakSelf = self else { return }
            if let index = weakSelf.views.index(of: adSpaceView) {
                weakSelf.views.remove(at: index)
            }
            weakSelf.fullScreenAdDelegate?.fullScreenAdDidClose(adSpace: weakSelf)
        }
        
        let onClick = { [weak self] in
        }
        
        let loadCompletion = { [weak self] in
            guard let weakSelf = self else { return }

            let fullScreenViewController = ADFullScreenViewController(adView: adSpaceView,
                                                                      contentSize: content.proportionalContentSize, closed:{
                                                                        if let index = weakSelf.views.index(of: adSpaceView) {
                                                                            weakSelf.views.remove(at: index)
                                                                        }

                                                                        weakSelf.fullScreenAdDelegate?.fullScreenAdDidClose(adSpace: weakSelf)
            })
            viewController.present(fullScreenViewController,
                                   animated: true,
                                   completion: nil)
            weakSelf.fullScreenAdDelegate?.fullScreenAdDidLoad(adSpace: weakSelf)
            
            
        }
        
        let loadError: (Error) -> Void = { [weak self] error in
            guard let weakSelf = self else { return }
            
            if let index = weakSelf.views.index(of: adSpaceView) {
                weakSelf.views.remove(at: index)
            }
            weakSelf.fullScreenAdDelegate?.fullScreenAd(adSpace: weakSelf,
                                                        didFailWithError: error)
        }
        
        adSpaceView = ADSpaceFactory.adSpaceViewFor(content: content,
                                                    resultContent: viewContent,
                                                    onClick: onClick,
                                                    onClose: onClose,
                                                    loadCompletion:loadCompletion,
                                                    loadError:loadError)
        views.append(adSpaceView)
        adSpaceView.start()
    }

    
    func loadBanner<T: ADSpaceViewContentType>(_ viewContent: T, content: ADSpaceContent) {
        var adSpaceView: ADSpaceView<T>!

        let onClose = { [weak self] in
            guard let weakSelf = self else { return }
            if let index = weakSelf.views.index(of: adSpaceView) {
                weakSelf.views.remove(at: index)
            }
            weakSelf.delegate?.adSpace(adSpace:weakSelf, willCloseView: adSpaceView)
        }
        
        let onClick = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.performClickAction(content)
        }
        
        let loadCompletion = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.delegate?.adSpace(adSpace: weakSelf,
                                       didLoadView: adSpaceView,
                                       contentSize: content.proportionalContentSize)
            
            
        }
        
        let loadError: (Error) -> Void = { [weak self] error in
            guard let weakSelf = self else { return }
            
            if let index = weakSelf.views.index(of: adSpaceView) {
                weakSelf.views.remove(at: index)
            }
            
            weakSelf.delegate?.adSpace(adSpace: weakSelf, didFailWithError: error)
        }
        
        adSpaceView = ADSpaceFactory.adSpaceViewFor(content: content,
                                                    resultContent: viewContent,
                                                    onClick: onClick,
                                                    onClose: onClose,
                                                    loadCompletion:loadCompletion,
                                                    loadError:loadError)
        views.append(adSpaceView)
        adSpaceView.start()
    }
    
    private func performClickAction(_ content: ADSpaceContent) {
        guard let actionURL = content.actionURL else { return }
        let window = UIApplication.shared.delegate?.window
        let webViewController = ADDetailWebViewController(urlString: actionURL)
        let navigationController = UINavigationController(rootViewController: webViewController)
        window??.rootViewController?.present(navigationController,
                                             animated: true,
                                             completion: nil)
    }
    
    deinit {
        views.removeAll()
    }
    
    private var views: [UIView] = []
    
    public init() {}
    
    public weak var delegate: ADSpaceDelegate?
    public weak var fullScreenAdDelegate: ADSpaceFullScreenDelegate?
    
    
    private let jsonRequest = ADSpaceJSONRequest()
}
