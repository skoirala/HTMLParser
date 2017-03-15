
class NavigationProgressView: UIView {
    var shape: CAShapeLayer
    
    var progress: CGFloat = 0 {
        didSet {
            shape.strokeEnd = progress
        }
    }
    
    init() {
        shape = CAShapeLayer()
        
        super.init(frame: .zero)
        layer.addSublayer(shape)
        shape.lineWidth = 1
        shape.strokeColor = UIColor.blue.cgColor
        shape.fillColor = nil
        shape.strokeEnd = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0 , y: self.bounds.size.height * 0.5))
        path.addLine(to: CGPoint(x:self.bounds.size.width, y:self.bounds.size.height * 0.5))
        shape.path = path.cgPath
    }
    
}
