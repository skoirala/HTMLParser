
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
    
    private let imageDownloader = ImageDownloader()
    private var listViewAdapter: AlbumListViewAdapter!
    private var listView: TopSongListView!
    private let song: Song
    
    private weak var imageView: UIImageView!
}

// MARK: Private methods

extension AlbumListViewController {
    
    private func setupListViewAdapter() {
        listViewAdapter = AlbumListViewAdapter(song: song, onChange: {[weak self] in
            self?.listView.reloadData()
            } , onSelection: { [weak self] album in
                self?.showSongListViewController(album)
            })
        
        listView.delegate = listViewAdapter
        listView.dataSource = listViewAdapter
    }
    
    private func downloadSongArtwork(){
        imageDownloader.imageForURL(song.bigImageURL!) {[weak self] image in
            self?.imageView.image = image
        }
    }
    
    @objc private func showArtistDetail() {
        let artistDetailViewController = ArtistDetailViewController(song: song)
        navigationController?.pushViewController(artistDetailViewController, animated: true)
    }
    
    private func createViews() {
        let button = UIButton(type: .DetailDisclosure)
        button.addTarget(self, action: Selector("showArtistDetail"), forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView:button)

        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .ScaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        
        let blurEffect = UIBlurEffect(style: .ExtraLight)
        let blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurredView)
        listView = TopSongListView()
        listView.translatesAutoresizingMaskIntoConstraints = false
        blurredView.contentView.addSubview(listView)
        
        
        let constraints = [
            imageView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            imageView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
            imageView.leftAnchor.constraintEqualToAnchor(view.leftAnchor),
            imageView.rightAnchor.constraintEqualToAnchor(view.rightAnchor),
            
            blurredView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor),
            blurredView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
            blurredView.leftAnchor.constraintEqualToAnchor(view.leftAnchor),
            blurredView.rightAnchor.constraintEqualToAnchor(view.rightAnchor),
            
            listView.topAnchor.constraintEqualToAnchor(blurredView.contentView.topAnchor),
            listView.bottomAnchor.constraintEqualToAnchor(blurredView.contentView.bottomAnchor),
            listView.leftAnchor.constraintEqualToAnchor(blurredView.contentView.leftAnchor),
            listView.rightAnchor.constraintEqualToAnchor(blurredView.contentView.rightAnchor)
        ]
        constraints.forEach { $0.active = true }
        
        self.imageView = imageView
    }
    
    private func showAlbumDetail(song: Song) {
        let songDetailViewController = AlbumListViewController(song: song)
        navigationController?.pushViewController(songDetailViewController, animated: true)
    }
    
    private func showSongListViewController(album: Album) {
        let albumSongViewController = AlbumSongsListViewController(album: album)
        navigationController?.pushViewController(albumSongViewController, animated: true)
    }

}
