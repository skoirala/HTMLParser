
import UIKit


public class TopSongsListViewController: UIViewController {
    
    internal var listViewAdapter: TopSongListViewAdapter!
    internal var listView: TopSongListView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "Top Songs"

        createViews()
        setupListViewAdapter()
        listViewAdapter.loadTopSongs()
    }
}

// MARK: Private methods

extension TopSongsListViewController {
    
    internal func createViews() {
        listView = TopSongListView()
        listView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(listView)
        let constraints = [
            listView.topAnchor.constraint(equalTo: view.topAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            listView.leftAnchor.constraint(equalTo: view.leftAnchor),
            listView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]
        constraints.forEach { $0.isActive = true }
    }
    
    internal func setupListViewAdapter() {
        listViewAdapter = TopSongListViewAdapter(onChange: {
            self.listView.reloadData()
            }, selection: { song in
                self.showAlbumDetail(song)
        })
        
        listView.delegate = listViewAdapter
        listView.dataSource = listViewAdapter
    }
    
    internal func showAlbumDetail(_ song: Song) {
        let songDetailViewController = AlbumListViewController(song: song)
        navigationController?.pushViewController(songDetailViewController, animated: true)
    }
}

