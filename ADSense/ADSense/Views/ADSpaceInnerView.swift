
public protocol ADSpaceViewContentType { }

extension UIImage: ADSpaceViewContentType { }
extension String: ADSpaceViewContentType { }
extension URL: ADSpaceViewContentType { }


public class ADSpaceView<T: ADSpaceViewContentType>: UIView {
    
    public let content: T
    public let contentSize: CGSize
    
    
    let closed: () -> ()
    let onLoadError: (Error) -> ()
    let onLoadCompletion: () -> ()
    let click: () -> ()
    
    public func showCloseButton(shows: Bool) {
        
    }
    
    public func showBorder(shows: Bool) {
        
    }
    
    public init(content: T,
                contentSize: CGSize,
                click: @escaping () -> (),
                closed: @escaping () -> (),
                loadCompletion: @escaping () -> (),
                loadError: @escaping (Error) -> ()) {
        self.contentSize = contentSize
            self.content = content
        self.closed = closed
        self.click = click
        self.onLoadError = loadError
        self.onLoadCompletion = loadCompletion
        super.init(frame: .zero)
    }
    
    public func start() { }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
}
