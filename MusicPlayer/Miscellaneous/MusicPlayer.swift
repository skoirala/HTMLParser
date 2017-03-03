
import AVFoundation

public protocol MusicPlayerDelegate: class {
    func playerItemDidFinishPlaying()
}

public class MusicPlayer: NSObject, ProgressReporting {

    public init(delegate: MusicPlayerDelegate) {
        self.delegate = delegate
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if handlePlayerItemStatus(keyPath, object: object, change: change) {
            return
        }
        
        if handlePlayerItemDuration(keyPath, object: object, change: change) {
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        
    }
    
    deinit {
        if let audioPlayerItem = audioPlayerItem {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayerItem)
        }
        audioPlayerItem?.removeObserver(self, forKeyPath: "status", context: nil)
        audioPlayerItem?.removeObserver(self, forKeyPath: "duration", context: nil)
    }
   
    internal weak var delegate: MusicPlayerDelegate!
    public var progress: Progress = Progress()
    internal var timeObserver: Any?
    internal var audioPlayer: AVPlayer?
    internal var audioPlayerItem: AVPlayerItem?

}

// MARK: Public methods

extension MusicPlayer {
    
    public var isPlaying: Bool {
        return audioPlayer?.rate == 1
    }
    
    public func play() {
        audioPlayer?.play()
    }
    
    public func pause() {
        audioPlayer?.pause()
    }
    
    public func prepareToPlayURL(_ URLString: String) {
        resetProgress()
        preparePlayerItem(forURL: URLString)
    }
}


// MARK: KVO Handlers

extension MusicPlayer {
    
    internal func handlePlayerItemStatus(_ keyPath: String?, object: Any?, change: [NSKeyValueChangeKey : Any]?) -> Bool {
        
        if let keyPath = keyPath, keyPath == "status",
            let playerItem = object as? AVPlayerItem, playerItem == audioPlayerItem {
            
            let changeStatus = change![NSKeyValueChangeKey.newKey] as! Int
            let keyValueStatus = AVPlayerItemStatus(rawValue: changeStatus)!
            
            switch keyValueStatus {
            case .readyToPlay:
                print("Ready to play")
            case .failed, .unknown: fallthrough
            default:
                print("Not ready")
            }
            return true
        }
        return false
    }
    
    internal func handlePlayerItemDuration(_ keyPath: String?, object: Any?, change: [NSKeyValueChangeKey: Any]?) -> Bool {
        if let keyPath = keyPath, keyPath == "duration",
            let playerItem = object as? AVPlayerItem, playerItem == audioPlayerItem {
            
            let durationValue = change![NSKeyValueChangeKey.newKey] as! NSValue
            progress.totalUnitCount = Int64(CMTimeGetSeconds(durationValue.timeValue) * 10000)
            return true
        }
        return false
    }
}

// Mark: Private methods

extension MusicPlayer {
    
    internal func resetProgress() {
        progress.totalUnitCount = -1
        progress.completedUnitCount = 0
    }
    
    internal func preparePlayerItem(forURL URLString: String) {
        removeObservers()
        let URL = Foundation.URL(string: URLString)!
        let asset = AVURLAsset(url: URL)
        audioPlayerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["tracks"])
        addObservers()
    }
    
    internal func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(MusicPlayer.playerItemFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayerItem)
        audioPlayerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        audioPlayerItem?.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
        audioPlayer = AVPlayer(playerItem: audioPlayerItem!)
        let interval = CMTimeMake(1, 2)
        timeObserver = audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            let seconds = CMTimeGetSeconds(time)
            self?.progress.completedUnitCount = Int64(seconds * 10000)
        }
    }
    
    private func removeObservers (){
        if let playerItem = audioPlayerItem {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        }
        audioPlayerItem?.removeObserver(self, forKeyPath: "status", context: nil)
        audioPlayerItem?.removeObserver(self, forKeyPath: "duration", context: nil)
        audioPlayer?.removeTimeObserver(timeObserver!)
    }
    
    @objc private func playerItemFinished() {
        audioPlayerItem?.seek(to: kCMTimeZero)
        delegate.playerItemDidFinishPlaying()
    }
}
