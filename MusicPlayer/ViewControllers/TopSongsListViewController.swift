
import UIKit


public class TopSongsListViewController: UIViewController {
    
    private var listViewAdapter: TopSongListViewAdapter!
    private var listView: TopSongListView!
    
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
    
    private func createViews() {
        listView = TopSongListView()
        listView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(listView)
        let constraints = [
            listView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            listView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
            listView.leftAnchor.constraintEqualToAnchor(view.leftAnchor),
            listView.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        ]
        constraints.forEach { $0.active = true }
    }
    
    private func setupListViewAdapter() {
        listViewAdapter = TopSongListViewAdapter(onChange: {
            self.listView.reloadData()
            }, selection: { song in
                self.showAlbumDetail(song)
        })
        
        listView.delegate = listViewAdapter
        listView.dataSource = listViewAdapter
    }
    
    private func showAlbumDetail(song: Song) {
        let songDetailViewController = AlbumListViewController(song: song)
        navigationController?.pushViewController(songDetailViewController, animated: true)
    }
}

