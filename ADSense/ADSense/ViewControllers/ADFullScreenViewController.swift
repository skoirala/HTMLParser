

class CounterView: UIView, CAAnimationDelegate {
    
    
    let progressLayer: CAShapeLayer
    
    let textLayer: CATextLayer
    
    var count = 0
    
    var currentTime: TimeInterval = 0
    
    let timeDuration: Double
    
    let completion: () -> ()
    
    // timeDuration in seconds
    
    public init(frame: CGRect, timeDuration: Double, completion: @escaping () -> ()) {
        
        self.timeDuration = timeDuration
        self.completion = completion
        let color =  UIColor(red: 204.0 / 255.0, green: 1, blue: 1, alpha: 1.0).cgColor
        progressLayer = CAShapeLayer()
        progressLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        progressLayer.fillColor = nil
        progressLayer.strokeColor = color
        progressLayer.lineCap = kCALineCapRound
        
        progressLayer.rasterizationScale = UIScreen.main.scale
        progressLayer.shouldRasterize = true

        textLayer = CATextLayer()
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.frame = progressLayer.frame
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.shouldRasterize = true
        textLayer.foregroundColor = color
        textLayer.font = UIFont.systemFont(ofSize: 4)
        textLayer.fontSize = 20

        super.init(frame: frame)
        
        
        backgroundColor = UIColor.clear
        isOpaque = true
        
        layer.addSublayer(progressLayer)
        layer.addSublayer(textLayer)
        configurePath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        currentTime = CACurrentMediaTime()
        
        let displayLink = CADisplayLink(target: self,
                                        selector: #selector(displayFrame))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        
        if #available(iOS 10.0, *) {
            displayLink.preferredFramesPerSecond = 60
        } else {
            // Fallback on earlier versions
        }
    }
    
    dynamic private func displayFrame(displayLink: CADisplayLink) {
        var timeElapsed = displayLink.timestamp - currentTime

        if (timeElapsed > timeDuration) {
            currentTime = CACurrentMediaTime()
            displayLink.invalidate()
            
            let interval  = DispatchTimeInterval.milliseconds(250)
            let time = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: time, execute: { [weak self] in
                self?.textLayer.string = "0"
                self?.progressLayer.strokeEnd = 1
                
                let inTime = DispatchTime.now() + 0.22
                
                DispatchQueue.main.asyncAfter(deadline: inTime, execute: {
                    let transition = CATransition()
                    transition.type = kCATransitionFade
                    transition.duration = 0.25
                    transition.delegate = self
                    
                    self?.textLayer.add(transition, forKey: "animation")
                    self?.progressLayer.add(transition, forKey: nil)
                    
                    self?.textLayer.opacity = 0
                    self?.progressLayer.opacity = 0
                    
                })
            })
        }
        
        
        let strokePath = timeElapsed / timeDuration
        progressLayer.strokeEnd = CGFloat(strokePath)
        
        let timeRemaining = Int(abs(timeDuration - timeElapsed)) + 1
        textLayer.string = "\(timeRemaining)"
        
        let size = textLayer.preferredFrameSize()
        let superLayerBounds = self.progressLayer.bounds
        
        let newFrame = CGRect(x: superLayerBounds.size.width * 0.5 - size.width * 0.5,
                              y: superLayerBounds.size.height * 0.5 - size.height * 0.5,
                              width: size.width,
                              height: size.height)
        textLayer.frame = newFrame
        
    }
    
    
    
    func configurePath() {
        let lineWidth: CGFloat = 2
        progressLayer.lineWidth = lineWidth
        
        
        let radius = frame.size.width * 0.5 - lineWidth * 0.5
        let path = UIBezierPath(arcCenter: CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
            , radius: radius,
              startAngle: CGFloat(-M_PI_2),
              endAngle: CGFloat(-M_PI_2 + 2 * M_PI),
              clockwise: true)
        progressLayer.path = path.cgPath
        
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if (flag) {
            completion()
        }
    }
    
}


class ADFullScreenViewController<T: ADSpaceViewContentType>: UIViewController {
    
    let closed: () -> ()
    var contentSize: CGSize!
    weak var adView: ADSpaceView<T>!
    
    
    public init(adView: ADSpaceView<T>,
                contentSize: CGSize,
                closed: @escaping () -> ()) {
        self.adView = adView
        self.contentSize = contentSize
        self.closed = closed
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        let screenSize = UIScreen.main.bounds
        let counterView = CounterView(frame: CGRect(x: screenSize.width - 60, y: 10, width: 50, height: 50), timeDuration: 6) {
            self.showCloseButton()
        }
        
        view.addSubview(counterView)
        
        createViews()
        
        adView.showBorder(shows: false)
        adView.showCloseButton(shows: false)
    }
    
    private func createViews() {
        adView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adView)
        adView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        adView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        adView.widthAnchor.constraint(equalToConstant: contentSize.width).isActive = true
        adView.heightAnchor.constraint(equalToConstant: contentSize.height).isActive = true
    }
    
    func showCloseButton() {
        let bundle = Bundle(for: ADSpaceInnerVideoView.self)

        let closeImage = UIImage(named: "exit_gray", in: bundle, compatibleWith: nil)
        let closeTemplateImage = closeImage?.withRenderingMode(.alwaysTemplate)

        let closeButton = UIButton(frame: .zero)
        closeButton.tintColor = UIColor.white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(closeTemplateImage, for: .normal)
        closeButton.layer.cornerRadius = 20
        view.addSubview(closeButton)
        
        closeButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

    }
    
    func closeButtonTapped() {
        adView.removeFromSuperview()
        adView = nil
        dismiss(animated: true, completion:closed)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
