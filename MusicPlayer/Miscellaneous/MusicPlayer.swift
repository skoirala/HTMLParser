
import AVFoundation

public protocol MusicPlayerDelegate: class {
    func playerItemDidFinishPlaying()
}

public class MusicPlayer: NSObject, NSProgressReporting {

    public init(delegate: MusicPlayerDelegate) {
        self.delegate = delegate
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if handlePlayerItemStatus(keyPath, object: object, change: change) {
            return
        }
        
        if handlePlayerItemDuration(keyPath, object: object, change: change) {
            return
        }
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        
    }
    
    deinit {
        if let audioPlayerItem = audioPlayerItem {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: audioPlayerItem)
        }
        audioPlayerItem?.removeObserver(self, forKeyPath: "status", context: nil)
        audioPlayerItem?.removeObserver(self, forKeyPath: "duration", context: nil)
    }
   
    private weak var delegate: MusicPlayerDelegate!
    public var progress: NSProgress = NSProgress()
    private var timeObserver: AnyObject?
    private var audioPlayer: AVPlayer?
    private var audioPlayerItem: AVPlayerItem?

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
    
    public func prepareToPlayURL(URLString: String) {
        resetProgress()
        preparePlayerItem(forURL: URLString)
    }
}


// MARK: KVO Handlers

extension MusicPlayer {
    
    private func handlePlayerItemStatus(keyPath: String?, object: AnyObject?, change: [String: AnyObject]?) -> Bool {
        
        if let keyPath = keyPath where keyPath == "status",
            let playerItem = object as? AVPlayerItem where playerItem == audioPlayerItem {
            
            let changeStatus = change![NSKeyValueChangeNewKey] as! Int
            let keyValueStatus = AVPlayerItemStatus(rawValue: changeStatus)!
            
            switch keyValueStatus {
            case .ReadyToPlay:
                print("Ready to play")
            case .Failed, .Unknown: fallthrough
            default:
                print("Not ready")
            }
            return true
        }
        return false
    }
    
    private func handlePlayerItemDuration(keyPath: String?, object: AnyObject?, change: [String: AnyObject]?) -> Bool {
        if let keyPath = keyPath where keyPath == "duration",
            let playerItem = object as? AVPlayerItem where playerItem == audioPlayerItem {
            
            let durationValue = change![NSKeyValueChangeNewKey] as! NSValue
            progress.totalUnitCount = Int64(CMTimeGetSeconds(durationValue.CMTimeValue) * 10000)
            return true
        }
        return false
    }
}

// Mark: Private methods

extension MusicPlayer {
    
    private func resetProgress() {
        progress.totalUnitCount = -1
        progress.completedUnitCount = 0
    }
    
    private func preparePlayerItem(forURL URLString: String) {
        removeObservers()
        let URL = NSURL(string: URLString)!
        let asset = AVURLAsset(URL: URL)
        audioPlayerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["tracks"])
        addObservers()
    }
    
    private func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerItemFinished"), name: AVPlayerItemDidPlayToEndTimeNotification, object: audioPlayerItem)
        audioPlayerItem?.addObserver(self, forKeyPath: "status", options: .New, context: nil)
        audioPlayerItem?.addObserver(self, forKeyPath: "duration", options: .New, context: nil)
        audioPlayer = AVPlayer(playerItem: audioPlayerItem!)
        let interval = CMTimeMake(1, 2)
        timeObserver = audioPlayer?.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue()) { [weak self] time in
            let seconds = CMTimeGetSeconds(time)
            self?.progress.completedUnitCount = Int64(seconds * 10000)
        }
    }
    
    private func removeObservers (){
        if let playerItem = audioPlayerItem {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        }
        audioPlayerItem?.removeObserver(self, forKeyPath: "status", context: nil)
        audioPlayerItem?.removeObserver(self, forKeyPath: "duration", context: nil)
        audioPlayer?.removeTimeObserver(timeObserver!)
    }
    
    @objc private func playerItemFinished() {
        audioPlayerItem?.seekToTime(kCMTimeZero)
        delegate.playerItemDidFinishPlaying()
    }
}