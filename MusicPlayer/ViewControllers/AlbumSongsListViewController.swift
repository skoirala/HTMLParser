
import UIKit


public class AlbumSongsListViewController: UITableViewController {
    
    public init(album: Album) {
        self.album = album
        super.init(style: .plain)
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
        imageView.contentMode = .scaleToFill

        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.addSubview(imageView)
        backgroundView.addSubview(blurredView)
        
        tableView.backgroundView = backgroundView
        tableView.separatorStyle = .none
                
        title = album.name
                let constraints = [
                           blurredView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
                           blurredView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
                           blurredView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor),
                           blurredView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor),
                           imageView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
                           imageView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
                           imageView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor),
                           imageView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor)
        ]
        constraints.forEach { $0.isActive = true }
        
        self.imageView = imageView
    }
    
    private let album: Album
    private lazy var albumListTableViewAdapter:AlbumSongsListTableViewAdapter = AlbumSongsListTableViewAdapter(album: self.album, tableView: self.tableView)
    private let imageDownloader = ImageDownloader()
    private weak var imageView: UIImageView!
}
