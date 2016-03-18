
import UIKit


public class AlbumSongsListViewController: UITableViewController {
    
    public init(album: Album) {
        self.album = album
        super.init(style: .Plain)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        
        albumListTableViewAdapter.loadAlbumDetail()
        imageDownloader.downloadImageForURL(album.imageURL) { [weak self] image in
            self?.imageView.image = image
        }
    }
    
    private func createViews() {
        let backgroundView = UIView()
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFit

        let blurEffect = UIBlurEffect(style: .ExtraLight)
        let blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.addSubview(imageView)
        backgroundView.addSubview(blurredView)
        
        tableView.backgroundView = backgroundView
        tableView.separatorStyle = .None
                
        title = album.name
                let constraints = [
                           blurredView.topAnchor.constraintEqualToAnchor(backgroundView.topAnchor),
                           blurredView.bottomAnchor.constraintEqualToAnchor(backgroundView.bottomAnchor),
                           blurredView.leftAnchor.constraintEqualToAnchor(backgroundView.leftAnchor),
                           blurredView.rightAnchor.constraintEqualToAnchor(backgroundView.rightAnchor),
                           imageView.topAnchor.constraintEqualToAnchor(backgroundView.topAnchor),
                           imageView.bottomAnchor.constraintEqualToAnchor(backgroundView.bottomAnchor),
                           imageView.leftAnchor.constraintEqualToAnchor(backgroundView.leftAnchor),
                           imageView.rightAnchor.constraintEqualToAnchor(backgroundView.rightAnchor)
        ]
        constraints.forEach { $0.active = true }
        
        self.imageView = imageView
    }
    
    private let album: Album
    private lazy var albumListTableViewAdapter:AlbumSongsListTableViewAdapter = AlbumSongsListTableViewAdapter(album: self.album, tableView: self.tableView)
    private let imageDownloader = ImageDownloader()
    private weak var imageView: UIImageView!
}
