
import UIKit

public class ADContainerCollectionReusableView: UICollectionReusableView {
    public static let ReuseIdentifier = "ReuseIdentifier"

    var containedView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showView(view: UIView) {
        if containedView != nil {
            return
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        containedView = view
    }
    
}
