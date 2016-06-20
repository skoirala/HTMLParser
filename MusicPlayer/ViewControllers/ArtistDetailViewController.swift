
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
    
    public override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
        if  keyPath == "fractionCompleted" {
            guard let fractionCompleted = change?[NSKeyValueChangeKey.newKey] as? Double else {
                return
            }
            
            playPauseButton.progress = CGFloat(fractionCompleted)
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    deinit {
        progress.removeObserver(self, forKeyPath: "fractionCompleted")
    }
    
    private var playPauseButton: PlayPauseButton!
    private var label: UILabel!
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    
    private var progress: Progress!
    private let song: Song
    private var player: MusicPlayer!
    private let imageDownloader = ImageDownloader()
    private lazy var artistDetailLoader: ArtistDetailLoader = ArtistDetailLoader(song: self.song)
    
}

// MARK: Private methods

extension ArtistDetailViewController {
    
    private func createViews() {
        playPauseButton = PlayPauseButton()
        playPauseButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        playPauseButton.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        let playPauseBarButtonItem = UIBarButtonItem(customView:playPauseButton)
        navigationItem.rightBarButtonItem = playPauseBarButtonItem
        
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        label = UILabel()
        label.textColor = UIColor.darkGray()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurredView)
        
        scrollView.addSubview(label)
        blurredView.contentView.addSubview(scrollView)
        
        let constraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            blurredView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            blurredView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurredView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurredView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.topAnchor.constraint(equalTo: blurredView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: blurredView.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: blurredView.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: blurredView.rightAnchor),
            
            label.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            label.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -20),
            ]
        constraints.forEach { $0.isActive = true }
        self.imageView = imageView
    }
    
    private func setup() {
        view.backgroundColor = UIColor.white()
        title = song.artistName
        
        downloadMusicArt()
        loadArtistDetails()
        
        if let previewURL = song.previewURL {
            player = MusicPlayer(delegate: self)
            player.prepareToPlayURL(previewURL)
            progress = Progress()
            progress.totalUnitCount = 100
            progress.addChild(player.progress, withPendingUnitCount: 100)
            progress.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: nil)
        } else {
            self.playPauseButton.isEnabled = false
        }
    }
    
    @objc private func playPause() {
        if player.isPlaying {
            playPauseButton.playingState = .paused
            player.pause()
        } else {
            playPauseButton.playingState = .playing
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
        playPauseButton.playingState = .paused
    }
}
