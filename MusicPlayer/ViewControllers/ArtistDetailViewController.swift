
import UIKit


public class ArtistDetailViewController: UIViewController {
    
    public init(song: Song) {
        self.song = song
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLayoutSubviews() {
        label.preferredMaxLayoutWidth = scrollView.bounds.size.width - 40.0
        super.viewDidLayoutSubviews()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        setup()
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if  keyPath == "fractionCompleted" {
            guard let fractionCompleted = change?[NSKeyValueChangeNewKey] as? Double else {
                return
            }
            
            playPauseButton.progress = CGFloat(fractionCompleted)
            return
        }
        
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
    
    deinit {
        progress.removeObserver(self, forKeyPath: "fractionCompleted")
    }
    
    private var playPauseButton: PlayPauseButton!
    private var label: UILabel!
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    
    private var progress: NSProgress!
    private let song: Song
    private var player: MusicPlayer!
    private let imageDownloader = ImageDownloader()
    private lazy var artistDetailLoader: ArtistDetailLoader = ArtistDetailLoader(song: self.song)
    
}

// MARK: Private methods

extension ArtistDetailViewController {
    
    private func createViews() {
        playPauseButton = PlayPauseButton()
        playPauseButton.frame = CGRectMake(0, 0, 22, 22)
        playPauseButton.addTarget(self, action: #selector(playPause), forControlEvents: .TouchUpInside)
        let playPauseBarButtonItem = UIBarButtonItem(customView:playPauseButton)
        navigationItem.rightBarButtonItem = playPauseBarButtonItem
        
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFit
        view.addSubview(imageView)
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        label = UILabel()
        label.textColor = UIColor.darkGrayColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        
        let blurEffect = UIBlurEffect(style: .ExtraLight)
        let blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurredView)
        
        scrollView.addSubview(label)
        blurredView.contentView.addSubview(scrollView)
        
        let constraints = [
            imageView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            imageView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
            imageView.leftAnchor.constraintEqualToAnchor(view.leftAnchor),
            imageView.rightAnchor.constraintEqualToAnchor(view.rightAnchor),
            blurredView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor),
            blurredView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
            blurredView.leftAnchor.constraintEqualToAnchor(view.leftAnchor),
            blurredView.rightAnchor.constraintEqualToAnchor(view.rightAnchor),
            scrollView.topAnchor.constraintEqualToAnchor(blurredView.topAnchor),
            scrollView.bottomAnchor.constraintEqualToAnchor(blurredView.bottomAnchor),
            scrollView.leftAnchor.constraintEqualToAnchor(blurredView.leftAnchor),
            scrollView.rightAnchor.constraintEqualToAnchor(blurredView.rightAnchor),
            
            label.topAnchor.constraintEqualToAnchor(scrollView.topAnchor, constant: 20),
            label.bottomAnchor.constraintEqualToAnchor(scrollView.bottomAnchor, constant: -20),
            label.leftAnchor.constraintEqualToAnchor(scrollView.leftAnchor, constant: 20),
            label.rightAnchor.constraintEqualToAnchor(scrollView.rightAnchor, constant: -20),
            ]
        constraints.forEach { $0.active = true }
        self.imageView = imageView
    }
    
    private func setup() {
        view.backgroundColor = UIColor.whiteColor()
        title = song.artistName
        
        downloadMusicArt()
        loadArtistDetails()
        
        player = MusicPlayer(delegate: self)
        player.prepareToPlayURL(song.previewURL!)
        progress = NSProgress()
        progress.totalUnitCount = 100
        progress.addChild(player.progress, withPendingUnitCount: 100)
        progress.addObserver(self, forKeyPath: "fractionCompleted", options: .New, context: nil)
    }
    
    @objc private func playPause() {
        if player.isPlaying {
            playPauseButton.playingState = .Paused
            player.pause()
        } else {
            playPauseButton.playingState = .Playing
            player.play()
        }
    }
    
    private func downloadMusicArt() {
        imageDownloader.imageForURL(song.bigImageURL!) { [weak self] image in
            self?.imageView.image = image
        }
    }
    
    private func loadArtistDetails() {
        artistDetailLoader.loadArtistDetail { artistDetail in
            if let biography = artistDetail.biography {
                self.label.text = biography
            } else {
                self.label.text = "No biography available"
            }
        }
    }
}

// MARK: MusicPlayerDelegate

extension ArtistDetailViewController: MusicPlayerDelegate {
    
    public func playerItemDidFinishPlaying() {
        playPauseButton.playingState = .Paused
    }
}
