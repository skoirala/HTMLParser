
import AVFoundation

class ADSpaceVideoView: UIView {

    deinit {
        playerLayer.player = nil
        playerLayer.removeFromSuperlayer()
    }
    
    public var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    
    public func showPreview(image image: CGImage) {
        previewLayer?.contents = image
    }
    
    public func removePreview() {
        previewLayer?.removeFromSuperlayer()
    }
    
    override class var layerClass: Swift.AnyClass {
        return AVPlayerLayer.self
    }
    
    private let contentSize: CGSize

    public init(contentSize: CGSize) {
        self.contentSize = contentSize
        
        super.init(frame: .zero)
        
        let previewLayer = CALayer()
        previewLayer.contentsGravity = kCAGravityResizeAspect
        previewLayer.backgroundColor = UIColor.white.cgColor
        self.previewLayer = previewLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let previewLayer = previewLayer {
            previewLayer.frame = self.bounds
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    weak private var previewLayer: CALayer?

}

class ADSpaceInnerVideoView: ADSpaceView<URL>  {
    var closeButton: UIButton!
    var borderView: UIView!

    weak var videoView: ADSpaceVideoView!
    var PlayerObservingContext = 0
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var assetGenerator: AVAssetImageGenerator!
    
    
    var playButton: UIButton!
    
    override func showCloseButton(shows: Bool) {
        closeButton.isHidden = !shows
    }
    
    override func showBorder(shows: Bool) {
        borderView.isHidden = !shows
    }
    
    deinit {
        videoView.removeFromSuperview()
        player?.pause()
        playerItem = nil
        player = nil
        assetGenerator = nil
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if (newSuperview == nil) {
            videoView.removeFromSuperview()
            player?.pause()
            playerItem = nil
            player = nil
            assetGenerator = nil
        }
    }
    
    override public init(content: URL,
                         contentSize: CGSize,
                         click: @escaping () -> (),
                         closed: @escaping () -> (),
                         loadCompletion: @escaping () -> (),
                         loadError: @escaping (Error) -> ()) {
        
        player = AVPlayer()

        super.init(content: content,
                   contentSize: contentSize,
                   click: click,
                   closed: closed,
                   loadCompletion: loadCompletion,
                   loadError: loadError)

        backgroundColor = UIColor.white
        setupVideoView()
        
        videoView.playerLayer.player = player
    }
    
    override func start() {
        loadAssets()
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupVideoView() {
        let videoView = ADSpaceVideoView(contentSize: contentSize)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(videoView)
        
        videoView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        videoView.heightAnchor.constraint(equalToConstant: contentSize.height).isActive = true
        videoView.widthAnchor.constraint(equalToConstant: contentSize.width).isActive = true
        videoView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        videoView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        videoView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        self.videoView = videoView
        
        let bundle = Bundle(for: ADSpaceInnerVideoView.self)
        var playImage = UIImage(named: "Play.png", in: bundle, compatibleWith: nil)
        playImage = playImage?.withRenderingMode(.alwaysTemplate)
        
        
        let playButton = UIButton(frame: .zero)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.tintColor = UIColor.white
        playButton.setImage(playImage, for: .normal)
        addSubview(playButton)
        

        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(tapped))
        addGestureRecognizer(tapGestureRecognizer)
        
        playButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        playButton.addTarget(self,
                             action: #selector(playButtonTapped),
                             for: .touchUpInside)
        
        self.playButton = playButton
        
        
        let closeImage = UIImage(named: "exit_gray", in: bundle, compatibleWith: nil)
        let closeTemplateImage = closeImage?.withRenderingMode(.alwaysTemplate)

        let closeButton = UIButton(frame: .zero)
        closeButton.tintColor = window?.tintColor
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(closeTemplateImage, for: .normal)
        closeButton.backgroundColor = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        closeButton.layer.cornerRadius = 20
        addSubview(closeButton)
        closeButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        closeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        
        let borderView = UIView(frame: .zero)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = UIColor.white
        addSubview(borderView)
        
        borderView.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        borderView.layer.shadowOpacity = 0.8
        borderView.layer.shadowColor = UIColor.darkGray.cgColor
        
        borderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        borderView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        borderView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        borderView.heightAnchor.constraint(equalToConstant: 2).isActive = true

        self.closeButton = closeButton
        self.borderView = borderView
    }
    
    dynamic
    private func closeButtonTapped() {
        videoView.removeFromSuperview()
        player?.pause()
        playerItem = nil
        player = nil
        assetGenerator = nil

        closed()
    }
    
    dynamic
    private func playButtonTapped() {
        tapped()
    }
    
    dynamic
    private func tapped() {
        videoView.removePreview()
        
        if player?.rate == 0 {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.playButton.transform = CGAffineTransform(scaleX: 5, y: 5)
                self?.playButton.alpha = 0
            }
            player?.play()

        } else {
            self.playButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)

            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.playButton.transform = CGAffineTransform.identity
                self?.playButton.alpha = 1
            }
            player?.pause()
        }
    }
    
    
     private func loadAssets() {
        let asset = AVURLAsset(url: content)
        assetGenerator = AVAssetImageGenerator(asset: asset)
        
        asset.loadValuesAsynchronously(forKeys: ["tracks", "duration"]) { [weak self] in
            
            var error: NSError?
            
            for key in ["tracks", "duration"] {
                let status = asset.statusOfValue(forKey: key, error: &error)
                
                if status == AVKeyValueStatus.failed {
                    
                    DispatchQueue.main.async {
                        self?.onLoadError(error!)
                    }
                    
                    return
                } else if status == AVKeyValueStatus.loading || status == AVKeyValueStatus.unknown {
                    return
                }
            }
            
            do {
                DispatchQueue.main.async {
                    try? self?.loadPreview(asset)
                }

            } catch {
                print("Error occurred")
                DispatchQueue.main.async {
                    self?.onLoadError(error)
                }
                return
            }
            DispatchQueue.main.async {
                self?.loadPlayerItem(asset)
            }
        }
    }

    private func loadPreview(_ asset: AVURLAsset) throws {
        let time = CMTime(seconds: Double(3), preferredTimescale: 1)
        var actualTime = CMTime()
        let cgImage = try self.assetGenerator.copyCGImage(at: time, actualTime: &actualTime)
        videoView.showPreview(image: cgImage)
    }
    
    
    private func loadPlayerItem(_ asset: AVURLAsset) {
        self.playerItem = AVPlayerItem(asset: asset)
        self.playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: &self.PlayerObservingContext)
        self.player?.replaceCurrentItem(with: self.playerItem)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let context = context, context == &PlayerObservingContext {
            let status = playerItem?.status
            if status == AVPlayerItemStatus.readyToPlay {
                playerItem?.removeObserver(self, forKeyPath: keyPath!, context: context)
                onLoadCompletion()

            }
            return
        }
        
        super.observeValue(forKeyPath: keyPath,
                           of: object,
                           change: change,
                           context: context)
    }
}

