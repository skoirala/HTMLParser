
import UIKit


fileprivate class RotatingView: UIView {
    
    
    let gradientLayer: CAGradientLayer
    let shapeLayer: CAShapeLayer

    override init(frame: CGRect) {
        
        shapeLayer = CAShapeLayer()
        shapeLayer.frame = frame
        
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        let startColor = UIColor(colorLiteralRed: Float(51) / 255.0,
                                 green: Float(204) / 255.0,
                                 blue: 1,
                                 alpha: 0.2)
        
        let endColor = startColor.withAlphaComponent(1)
        
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0, 0.75]
        gradientLayer.startPoint = CGPoint(x:0.5, y:0)
        gradientLayer.endPoint = CGPoint(x:0.5, y:1)
        
        
        super.init(frame: frame)
        
        layer.addSublayer(gradientLayer)
        
        let lineWidth: CGFloat = 2
        
        let radius = frame.width * 0.5 - lineWidth * 0.5
        let path = UIBezierPath(arcCenter: CGPoint(x: frame.width * 0.5, y: frame.height * 0.5), radius: radius, startAngle: CGFloat(-M_PI_2 * 0.5 - M_PI_2 * 0.45), endAngle: CGFloat(2 * M_PI - M_PI_2 - M_PI_2 * 0.5 + M_PI_2 * 0.45), clockwise: true)
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineCap = kCALineCapRound
        
        gradientLayer.mask = shapeLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class ProgressView: UIView {
    
    private var rotatingView: UIView!
    
    public class func showIn(view containerView: UIView) {
        let view = ProgressView(frame: containerView.bounds)
        let bounds = containerView.bounds
        
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 2
        view.layer.add(transition, forKey: nil)

        view.center = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        containerView.addSubview(view)
    }
    
    public class func hideFrom(view containerView: UIView) {
        for view in containerView.subviews {
            if view is ProgressView {
                let transition = CATransition()
                transition.type = kCATransitionFade
                transition.duration = 2
                view.layer.add(transition, forKey: nil)

                view.removeFromSuperview()
            }
        }
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        startAnimating()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let dimension = 80
        
        rotatingView = RotatingView(frame: CGRect(origin: .zero, size: CGSize(width: dimension, height: dimension)))
        
        rotatingView.center = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
        addSubview(rotatingView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func startAnimating() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = 2 * M_PI
        animation.repeatCount = HUGE
        animation.duration = 2
        rotatingView.layer.add(animation, forKey: nil)
    }
    
}

