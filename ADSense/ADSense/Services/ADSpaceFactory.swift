
import Foundation

public struct ADSpaceFactory<T: ADSpaceViewContentType>  {
    
    static func adSpaceViewFor(content: ADSpaceContent,
                               resultContent: T,
                               onClick: @escaping () -> (),
                               onClose: @escaping () -> (),
                               loadCompletion: @escaping () -> (),
                               loadError: @escaping (Error) -> ()) -> ADSpaceView<T> {
        
        if let resultContent = resultContent as? String, content.type == .html {
            let webView =  ADSpaceWebViewCreator.adSpaceViewFor(content: content,
                                                                resultContent: resultContent,
                                                                onClick: onClick,
                                                                onClose: onClose,
                                                                loadCompletion: loadCompletion,
                                                                loadError: loadError)
            return webView as! ADSpaceView<T>
        }
        
        if let resultContent = resultContent as? UIImage, content.type == .image {
            let imageView =  ADSpaceImageViewCreator.adSpaceViewFor(content: content,
                                                                    resultContent: resultContent,
                                                                    onClick: onClick,
                                                                    onClose: onClose,
                                                                    loadCompletion: loadCompletion,
                                                                    loadError: loadError)
            return imageView as! ADSpaceView<T>
        }
        
        if let resultContent = resultContent as? URL, content.type == .video {
            let videoView =  ADSpaceVideoViewCreator.adSpaceViewFor(content: content,
                                                                    resultContent: resultContent,
                                                                    onClick: onClick,
                                                                    onClose: onClose,
                                                                    loadCompletion: loadCompletion,
                                                                    loadError: loadError)
            return videoView as! ADSpaceView<T>
        }
        
        fatalError("Unknow type")
        
    }
    
}


fileprivate protocol ADSpaceViewCreatorType {
    
    associatedtype T: ADSpaceViewContentType
    
    static func adSpaceViewFor(content: ADSpaceContent,
                               resultContent: Self.T,
                               onClick: @escaping () -> (),
                               onClose: @escaping () -> (),
                               loadCompletion: @escaping () -> (),
                               loadError: @escaping (Error) -> ()) -> ADSpaceView<Self.T>
}

fileprivate extension ADSpaceViewCreatorType where T == String {
    
    static func adSpaceViewFor(content: ADSpaceContent,
                               resultContent: String,
                               onClick: @escaping () -> (),
                               onClose: @escaping () -> (),
                               loadCompletion: @escaping () -> (),
                               loadError: @escaping (Error) -> ()) -> ADSpaceView<String> {
        return  ADSpaceInnerWebView(content: resultContent,
                                    contentSize: content.proportionalContentSize,
                                    actionElementName:content.actionElement,
                                    click: onClick,
                                    closed: onClose,
                                    loadCompletion:loadCompletion,
                                    loadError:loadError)
    }

}

fileprivate extension ADSpaceViewCreatorType where T == UIImage {
    
    static func adSpaceViewFor(content: ADSpaceContent,
                               resultContent: UIImage,
                               onClick: @escaping () -> (),
                               onClose: @escaping () -> (),
                               loadCompletion: @escaping () -> (),
                               loadError: @escaping (Error) -> ()) -> ADSpaceView<UIImage> {
        return ADSpaceInnerImageContainerView(content: resultContent,
                                              contentSize: content.proportionalContentSize,
                                              click: onClick,
                                              closed: onClose,
                                              loadCompletion:loadCompletion,
                                              loadError:loadError)
    }
}

fileprivate extension ADSpaceViewCreatorType where T == URL {
    
    static func adSpaceViewFor(content: ADSpaceContent,
                               resultContent: URL,
                               onClick:  @escaping () -> (),
                               onClose: @escaping () -> (),
                               loadCompletion: @escaping () -> (),
                               loadError: @escaping (Error) -> ()) -> ADSpaceView<URL> {
        return ADSpaceInnerVideoView(content: resultContent,
                                     contentSize: content.proportionalContentSize,
                                     click: onClick,
                                     closed: onClose,
                                     loadCompletion:loadCompletion,
                                     loadError:loadError)
    }
}

fileprivate struct ADSpaceImageViewCreator: ADSpaceViewCreatorType {
    typealias T = UIImage
}


fileprivate struct ADSpaceWebViewCreator: ADSpaceViewCreatorType {
    typealias T = String
}

fileprivate struct ADSpaceVideoViewCreator: ADSpaceViewCreatorType {
    typealias T = URL
}
