
import UIKit


public class AlbumSongsListTableViewAdapter: NSObject {

    public func loadAlbumDetail() {
        albumDetailLoader.loadAlbumDetail { [weak self] albums in
            self?.albums = albums
            self?.tableView.reloadData()
        }
    }
    
    public init(album:Album, tableView: UITableView) {
        super.init()
        tableView.registerClass(AlbumSongListTableViewCell.self, forCellReuseIdentifier: "Cell")
        albumDetailLoader = AlbumDetailLoader(album: album)
        self.tableView = tableView
        setup()
    }
    
    deinit {
        progress.removeObserver(self, forKeyPath: "fractionCompleted")
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if  keyPath == "fractionCompleted" {
            guard let fractionCompleted = change?[NSKeyValueChangeNewKey] as? Double else {
                return
            }
            updateProgressForPlayingItem(CGFloat(fractionCompleted))
            return
        }
        
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
    
    private let progress = NSProgress()
    private var albumDetailLoader: AlbumDetailLoader!
    private lazy var musicPlayer: MusicPlayer = MusicPlayer(delegate: self)
    private var albums: [AlbumDetail] = []
    private var playingIndexPath: NSIndexPath?
    weak private var tableView: UITableView!
}

// MARK: UITableViewDatSource

extension AlbumSongsListTableViewAdapter: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! AlbumSongListTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

}

// MARK: UITableViewDelegate

extension AlbumSongsListTableViewAdapter: UITableViewDelegate {
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        playPauseItemAtIndexPath(indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: Private methods

extension AlbumSongsListTableViewAdapter {
    
    private func setup() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        progress.totalUnitCount = 100
        progress.addChild(musicPlayer.progress, withPendingUnitCount: 100)
        progress.addObserver(self, forKeyPath: "fractionCompleted", options: .New, context: nil)
    }
    
    private func configureCell(cell: AlbumSongListTableViewCell, atIndexPath indexPath:NSIndexPath) {
        cell.titleLabel.text = albums[indexPath.row].name
       
        if let playingIndexPath = playingIndexPath where playingIndexPath == indexPath {
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
    
    private func addPlayButtonEventHandlerToCell(cell: AlbumSongListTableViewCell, atIndexPath indexPath: NSIndexPath) {
        cell.onPlayButtonTapped = { [weak self] in
            self?.playPauseItemAtIndexPath(indexPath)
        }
    }
    
    private func playPauseItemAtIndexPath(indexPath: NSIndexPath) {
        if let playingIndexPath = playingIndexPath where playingIndexPath == indexPath {
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
    
    private func updateProgressForPlayingItem(progress: CGFloat) {
        if let playingIndexPath = playingIndexPath, cell = tableView.cellForRowAtIndexPath(playingIndexPath)
            as? AlbumSongListTableViewCell {
            cell.updateProgress(progress)
        }
    }
    
    private func playSampleAtIndexPath(indexPath: NSIndexPath) {
        musicPlayer.prepareToPlayURL(albums[indexPath.row].previewURL)
        musicPlayer.play()
    }
    
    private func updatePlayingAtIndexPath(indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? AlbumSongListTableViewCell else {
            return
        }
        cell.setPlaying()
        cell.updateProgress(0)
    }
    
    private func resetPlayingAtIndexPath(indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? AlbumSongListTableViewCell else {
            return
        }
        cell.setPaused()
        cell.updateProgress(0)
    }
    
    private func togglePlayAtIndexPath(indexPath: NSIndexPath) {
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


