
import UIKit


public class AlbumListViewController: UIViewController {
    
    public init(song: Song) {
        self.song = song
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Albums"
        
        createViews()
        setupListViewAdapter()
        downloadSongArtwork()
        
        listViewAdapter.loadArtistDetail()
    }
    
    internal let imageDownloader = ImageDownloader()
    internal var listViewAdapter: AlbumListViewAdapter!
    internal var listView: TopSongListView!
    internal let song: Song
    
    internal weak var imageView: UIImageView!
}

// MARK: Private methods

extension AlbumListViewController {
    
    internal func setupListViewAdapter() {
        listViewAdapter = AlbumListViewAdapter(song: song, onChange: {[weak self] in
            self?.listView.reloadData()
            } , onSelection: { [weak self] album in
                self?.showSongListViewController(album)
            })
        
        listView.delegate = listViewAdapter
        listView.dataSource = listViewAdapter
    }
    
    internal func downloadSongArtwork(){
        imageDownloader.imageForURL(song.bigImageURL!) {[weak self] image in
            self?.imageView.image = image
        }
    }
    
    @objc private func showArtistDetail() {
        let artistDetailViewController = ArtistDetailViewController(song: song)
        navigationController?.pushViewController(artistDetailViewController, animated: true)
    }
    
    internal func createViews() {
        let button = UIButton(type: .detailDisclosure)
        button.addTarget(self, action: #selector(showArtistDetail), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView:button)

        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurredView)
        listView = TopSongListView()
        listView.translatesAutoresizingMaskIntoConstraints = false
        blurredView.contentView.addSubview(listView)
        
        
        let constraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            blurredView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            blurredView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurredView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurredView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            listView.topAnchor.constraint(equalTo: blurredView.contentView.topAnchor),
            listView.bottomAnchor.constraint(equalTo: blurredView.contentView.bottomAnchor),
            listView.leftAnchor.constraint(equalTo: blurredView.contentView.leftAnchor),
            listView.rightAnchor.constraint(equalTo: blurredView.contentView.rightAnchor)
        ]
        constraints.forEach { $0.isActive = true }
        
        self.imageView = imageView
    }
    
    private func showAlbumDetail(_ song: Song) {
        let songDetailViewController = AlbumListViewController(song: song)
        navigationController?.pushViewController(songDetailViewController, animated: true)
    }
    
    private func showSongListViewController(_ album: Album) {
        let albumSongViewController = AlbumSongsListViewController(album: album)
        navigationController?.pushViewController(albumSongViewController, animated: true)
    }

}
