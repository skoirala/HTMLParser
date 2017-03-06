
import UIKit


public class AlbumSongsListTableViewAdapter: NSObject {

    var headerViewHeight: CGFloat = 0
    var headerView: UIView?
    
    func reloadView() {
        tableView.reloadData()
    }
    
    public func loadAlbumDetail() {
        albumDetailLoader.loadAlbumDetail { [weak self] albums in
            self?.albums = albums
            self?.tableView.reloadData()
        }
    }
    
    public init(album:Album, tableView: UITableView) {
        super.init()
        tableView.register(AlbumSongListTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(ADContainerTableReuseableView.self, forHeaderFooterViewReuseIdentifier: ADContainerTableReuseableView.ReuseIdentifier)
        albumDetailLoader = AlbumDetailLoader(album: album)
        self.tableView = tableView
        setup()
    }
    
    deinit {
        progress.removeObserver(self, forKeyPath: "fractionCompleted")
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if  keyPath == "fractionCompleted" {
            guard let fractionCompleted = change?[NSKeyValueChangeKey.newKey] as? Double else {
                return
            }
            updateProgressForPlayingItem(CGFloat(fractionCompleted))
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    internal let progress = Progress()
    internal var albumDetailLoader: AlbumDetailLoader!
    internal lazy var musicPlayer: MusicPlayer = MusicPlayer(delegate: self)
    internal var albums: [AlbumDetail] = []
    internal var playingIndexPath: IndexPath?
    weak internal var tableView: UITableView!
}

// MARK: UITableViewDatSource

extension AlbumSongsListTableViewAdapter: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AlbumSongListTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = headerView {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: ADContainerTableReuseableView.ReuseIdentifier) as! ADContainerTableReuseableView
            cell.showView(view:headerView)
            return cell
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return headerViewHeight
    }

}

// MARK: UITableViewDelegate

extension AlbumSongsListTableViewAdapter: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playPauseItemAtIndexPath(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: Private methods

extension AlbumSongsListTableViewAdapter {
    
    internal func setup() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        progress.totalUnitCount = 100
        progress.addChild(musicPlayer.progress, withPendingUnitCount: 100)
        progress.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: nil)
    }
    
    internal func configureCell(_ cell: AlbumSongListTableViewCell, atIndexPath indexPath:IndexPath) {
        cell.titleLabel.text = albums[(indexPath as NSIndexPath).row].name
       
        if let playingIndexPath = playingIndexPath, playingIndexPath == indexPath {
            if musicPlayer.isPlaying {
                cell.setPlaying()
            } else {
                cell.setPaused()
            }
        } else {
            cell.updateProgress(0)
            cell.setPaused()
        }
        
        addPlayButtonEventHandlerToCell(cell, atIndexPath: indexPath)
    }
    
    internal func addPlayButtonEventHandlerToCell(_ cell: AlbumSongListTableViewCell, atIndexPath indexPath: IndexPath) {
        cell.onPlayButtonTapped = { [weak self] in
            self?.playPauseItemAtIndexPath(indexPath)
        }
    }
    
    internal func playPauseItemAtIndexPath(_ indexPath: IndexPath) {
        if let playingIndexPath = playingIndexPath, playingIndexPath == indexPath {
            togglePlayAtIndexPath(indexPath)
            return
        }
        
        if let playingIndexPath = playingIndexPath  {
            resetPlayingAtIndexPath(playingIndexPath)
        }
        
        updatePlayingAtIndexPath(indexPath)
        playSampleAtIndexPath(indexPath)
        playingIndexPath = indexPath
    }
    
    internal func updateProgressForPlayingItem(_ progress: CGFloat) {
        if let playingIndexPath = playingIndexPath, let cell = tableView.cellForRow(at: playingIndexPath)
            as? AlbumSongListTableViewCell {
            cell.updateProgress(progress)
        }
    }
    
    internal func playSampleAtIndexPath(_ indexPath: IndexPath) {
        musicPlayer.prepareToPlayURL(albums[(indexPath as NSIndexPath).row].previewURL)
        musicPlayer.play()
    }
    
    internal func updatePlayingAtIndexPath(_ indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AlbumSongListTableViewCell else {
            return
        }
        cell.setPlaying()
        cell.updateProgress(0)
    }
    
    internal func resetPlayingAtIndexPath(_ indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AlbumSongListTableViewCell else {
            return
        }
        cell.setPaused()
        cell.updateProgress(0)
    }
    
    internal func togglePlayAtIndexPath(_ indexPath: IndexPath) {
        if musicPlayer.isPlaying {
            musicPlayer.pause()
            resetPlayingAtIndexPath(indexPath)
        } else {
            musicPlayer.play()
            updatePlayingAtIndexPath(indexPath)
        }
    }
}

// MARK: MusicPlayerDelegate

extension AlbumSongsListTableViewAdapter: MusicPlayerDelegate {
    
    public func playerItemDidFinishPlaying() {
        resetPlayingAtIndexPath(playingIndexPath!)
        playingIndexPath = nil
    }
    
}


