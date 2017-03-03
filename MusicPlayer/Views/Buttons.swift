
import UIKit



public class PlayPauseButton: UIButton {
    
    public enum State {
        case playing
        case paused
    }
    
    public var playingState: State = .paused {
        didSet {
            createButtonLayerPath()
        }
    }
    
    public var progress: CGFloat = 0 {
        didSet {
            progressLayer.strokeEnd = progress
        }
    }
    
    public override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                highLightLayer.fillColor = tintColor.withAlphaComponent(0.3).cgColor
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
        outlineLayer.strokeColor = UIColor.lightGray.cgColor
        
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
        progressLayer.strokeColor = tintColor.cgColor
        buttonLayer.fillColor = tintColor.cgColor
    }
    
    private func createLayersPath() {
        let width = bounds.width
        let height = bounds.height
        
        precondition(width == height)
        
        let center = CGPoint(x: width * 0.5, y: height * 0.5)
        let circleRadius = width * 0.5 - LineWidth * 0.5
        
        
        let progressPath = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(3 * M_PI_2), clockwise: true)
        outlineLayer.path = progressPath.cgPath
        progressLayer.path = progressPath.cgPath
        highLightLayer.path = progressPath.cgPath
    }
    
    private func createButtonLayerPath() {
        let width = bounds.width
        let height = bounds.height
        
        let center = CGPoint(x: width * 0.5, y: height * 0.5)
        let circleRadius = width * 0.5 - LineWidth * 0.5
        let allPoints = pointsAtCorners(center, circleRadius: circleRadius * 0.6)
        let rect = CGRect(x: allPoints[0].x, y: allPoints[0].y, width: allPoints[1].x - allPoints[0].x, height: allPoints[3].y - allPoints[1].y )
        
        var path: UIBezierPath
        
        switch playingState {
        case .playing:
            path = pauseButtonPathInside(rect)
        case .paused:
            path = playButtonPathInside(rect)
        }
        
        buttonLayer.path = path.cgPath
    }
    
    
    private func pauseButtonPathInside(_ rect: CGRect) -> UIBezierPath {
        let width = rect.width
        let height = rect.height
        
        let spaceInBetween = width * 0.2
        
        let widthOfLine = (width - spaceInBetween) * 0.5
        
        let leftPath = UIBezierPath()
        leftPath.move(to: rect.origin)
        leftPath.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + height))
        leftPath.addLine(to: CGPoint(x: rect.origin.x + widthOfLine, y: rect.origin.y + height))
        leftPath.addLine(to: CGPoint(x: rect.origin.x + widthOfLine, y: rect.origin.y))
        leftPath.addLine(to: rect.origin)
        leftPath.close()
        
        let rightPath = leftPath.copy() as! UIBezierPath
        rightPath.apply(CGAffineTransform(translationX: widthOfLine + spaceInBetween,y: 0))
        
        let compositePath = leftPath
        compositePath.append(rightPath)
        return compositePath
    }
    
    private func playButtonPathInside(_ rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: rect.origin)
        path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
        path.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height * 0.5))
        path.addLine(to: rect.origin)
        
        return path
    }
    
    private func pointsAtCorners(_ center: CGPoint, circleRadius radius: CGFloat) -> [CGPoint] {
        let cornersAngle = stride(from: CGFloat(M_PI_4), through: CGFloat(2 * M_PI), by: CGFloat(M_PI_2))
        
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
