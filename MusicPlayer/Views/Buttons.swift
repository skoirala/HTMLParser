
import UIKit



public class PlayPauseButton: UIButton {
    
    public enum State {
        case Playing
        case Paused
    }
    
    public var playingState: State = .Paused {
        didSet {
            createButtonLayerPath()
        }
    }
    
    public var progress: CGFloat = 0 {
        didSet {
            progressLayer.strokeEnd = progress
        }
    }
    
    public override var highlighted: Bool {
        didSet {
            if highlighted {
                highLightLayer.fillColor = tintColor.colorWithAlphaComponent(0.3).CGColor
            } else {
                highLightLayer.fillColor = nil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        outlineLayer = CAShapeLayer()
        progressLayer = CAShapeLayer()
        buttonLayer = CAShapeLayer()
        highLightLayer = CAShapeLayer()
        
        layer.addSublayer(highLightLayer)
        layer.addSublayer(outlineLayer)
        layer.addSublayer(progressLayer)
        layer.addSublayer(buttonLayer)
        
        outlineLayer.fillColor = nil
        outlineLayer.lineWidth = LineWidth
        outlineLayer.strokeColor = UIColor.lightGrayColor().CGColor
        
        progressLayer.fillColor = nil
        progressLayer.lineCap = kCALineCapRound
        progressLayer.lineWidth = LineWidth
        progressLayer.strokeEnd = 0
        
        buttonLayer.strokeColor = nil
        buttonLayer.lineWidth = LineWidth
        
        highLightLayer.fillColor = nil
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        createLayersPath()
        createButtonLayerPath()
    }
    
    public override func tintColorDidChange() {
        progressLayer.strokeColor = tintColor.CGColor
        buttonLayer.fillColor = tintColor.CGColor
    }
    
    private func createLayersPath() {
        let width = CGRectGetWidth(bounds)
        let height = CGRectGetHeight(bounds)
        
        precondition(width == height)
        
        let center = CGPoint(x: width * 0.5, y: height * 0.5)
        let circleRadius = width * 0.5 - LineWidth * 0.5
        
        
        let progressPath = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(3 * M_PI_2), clockwise: true)
        outlineLayer.path = progressPath.CGPath
        progressLayer.path = progressPath.CGPath
        highLightLayer.path = progressPath.CGPath
    }
    
    private func createButtonLayerPath() {
        let width = CGRectGetWidth(bounds)
        let height = CGRectGetHeight(bounds)
        
        let center = CGPoint(x: width * 0.5, y: height * 0.5)
        let circleRadius = width * 0.5 - LineWidth * 0.5
        let allPoints = pointsAtCorners(center, circleRadius: circleRadius * 0.6)
        let rect = CGRect(x: allPoints[0].x, y: allPoints[0].y, width: allPoints[1].x - allPoints[0].x, height: allPoints[3].y - allPoints[1].y )
        
        var path: UIBezierPath
        
        switch playingState {
        case .Playing:
            path = pauseButtonPathInside(rect)
        case .Paused:
            path = playButtonPathInside(rect)
        }
        
        buttonLayer.path = path.CGPath
    }
    
    
    private func pauseButtonPathInside(rect: CGRect) -> UIBezierPath {
        let width = CGRectGetWidth(rect)
        let height = CGRectGetHeight(rect)
        
        let spaceInBetween = width * 0.2
        
        let widthOfLine = (width - spaceInBetween) * 0.5
        
        let leftPath = UIBezierPath()
        leftPath.moveToPoint(rect.origin)
        leftPath.addLineToPoint(CGPoint(x: rect.origin.x, y: rect.origin.y + height))
        leftPath.addLineToPoint(CGPoint(x: rect.origin.x + widthOfLine, y: rect.origin.y + height))
        leftPath.addLineToPoint(CGPoint(x: rect.origin.x + widthOfLine, y: rect.origin.y))
        leftPath.addLineToPoint(rect.origin)
        leftPath.closePath()
        
        let rightPath = leftPath.copy() as! UIBezierPath
        rightPath.applyTransform(CGAffineTransformMakeTranslation(widthOfLine + spaceInBetween,0))
        
        let compositePath = leftPath
        compositePath.appendPath(rightPath)
        return compositePath
    }
    
    private func playButtonPathInside(rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(rect.origin)
        path.addLineToPoint(CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
        path.addLineToPoint(CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height * 0.5))
        path.addLineToPoint(rect.origin)
        
        return path
    }
    
    private func pointsAtCorners(center: CGPoint, circleRadius radius: CGFloat) -> [CGPoint] {
        let cornersAngle = CGFloat(M_PI_4).stride(through: CGFloat(2 * M_PI), by: CGFloat(M_PI_2))
        
        return cornersAngle.map { angle in
            let angleWithFirstQuadrant = CGFloat(M_PI)
            return CGPoint(x: center.x + radius * cos(angleWithFirstQuadrant + angle),
                y: center.y + radius * sin(angleWithFirstQuadrant + angle))
        }
    }
    
    private let LineWidth: CGFloat = 2.0
    
    private var outlineLayer: CAShapeLayer!
    private var progressLayer: CAShapeLayer!
    private var buttonLayer: CAShapeLayer!
    private var highLightLayer: CAShapeLayer!
    
}