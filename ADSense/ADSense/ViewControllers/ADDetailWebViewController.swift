
import WebKit


class ADDetailWebViewController: UIViewController, WKNavigationDelegate {
    
    let url: URL
    
    var ProgressObserverContext = 1
    
    static func show(urlString: String) {
        let detailViewController = ADDetailWebViewController(urlString: urlString)
        let navigationController = UINavigationController(rootViewController: detailViewController)
        let window = UIApplication.shared.delegate?.window
        window??.rootViewController?.present(navigationController,
                                             animated: true,
                                             completion: nil)
    }
    
    var webView: WKWebView!
    fileprivate var progressView: NavigationProgressView!
    
    init(urlString: String) {
        url = URL(string: urlString)!
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress", context: &ProgressObserverContext)
        webView.stopLoading()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        createViews()
        loadURL()
    }
    
    func createViews() {
        
        let bundle = Bundle(for: ADDetailWebViewController.self)
        
        let image = UIImage(named: "exit_gray", in: bundle, compatibleWith: nil)
        
        
        let barButtonItem = UIBarButtonItem(image: image,
                                            style: .plain,
                                            target: self,
                                            action: #selector(exitButtonPressed))
        navigationItem.rightBarButtonItem = barButtonItem
        progressView = NavigationProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        
        
        progressView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        progressView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        progressView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        webView.topAnchor.constraint(equalTo: progressView.bottomAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.addObserver(self, forKeyPath: "estimatedProgress",
                            options: .new, context: &ProgressObserverContext)
        webView.navigationDelegate = self
    }
    
    func exitButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let aContext = context, aContext == &ProgressObserverContext {
            let progress = change?[NSKeyValueChangeKey.newKey] as! CGFloat
            progressView.progress = progress
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    func loadURL() {
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print("started provisional navigation")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        print("finished navigation")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        print("failed navigation \(error)")
    }
}
