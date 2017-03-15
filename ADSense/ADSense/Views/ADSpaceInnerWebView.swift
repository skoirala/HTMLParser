
import WebKit


class ADSpaceInnerWebView: ADSpaceView<String>, WKNavigationDelegate, WKScriptMessageHandler {
    
    let ActionItemName = "click"
    let actionElementName: String?
    
    var webView: WKWebView!
    
    public init(content: String,
                contentSize: CGSize,
                actionElementName: String?,
                click: @escaping () -> (),
                closed: @escaping () -> (),
                loadCompletion: @escaping () -> (),
                loadError: @escaping (Error) -> ()) {
        self.actionElementName = actionElementName

        super.init(content: content,
                   contentSize: contentSize,
                   click: click,
                   closed: closed,
                   loadCompletion: loadCompletion,
                   loadError: loadError)

        
        setupWebView()
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func start() {
        webView.loadHTMLString(content, baseURL: nil)
    }
    
    private func setupWebView() {
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        
        if  let actionElement = actionElementName {
            let queryScript = "var element = document.querySelector('\(actionElement)'); element.addEventListener('mousedown', function(){ var message = {}; window.webkit.messageHandlers.\(ActionItemName).postMessage(message);})";
            
            let buttonScript = WKUserScript(source: queryScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            userContentController.addUserScript(buttonScript)
            userContentController.add(self, name: ActionItemName)
        }
        
        
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = userContentController
        webView = WKWebView(frame:.zero, configuration: webConfiguration)
        webView.scrollView.isScrollEnabled = false
        
        webView.navigationDelegate = self
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = UIColor.clear
        webView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: leftAnchor, constant: -4).isActive = true
        webView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onLoadError(error)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onLoadCompletion()
    }
    
    internal func userContentController(_ userContentController: WKUserContentController,
                                        didReceive message: WKScriptMessage) {
        if message.name == ActionItemName {
            click()
        }
    }
}
