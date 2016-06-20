

import UIKit


public class TopSongListViewAdapter: NSObject {
    
    public init(onChange: (Void) -> Void, selection: (Song) -> Void) {
        self.onChange = onChange
        self.onSelection = selection
    }
    
    public func loadTopSongs(_ completion: ((Void) -> Void)? = nil) {
        
        topSongRequest = TopSongsRequest(limit: 100)
        
        topSongRequest.startWithCompletion { result in
            completion?()
            switch result {
            case let .success(results):
                self.songs = results
            case let .failure(message):
                self.showError(message)
            }
        }
    }
    
    public func reset() {
        songs = []
    }
    
    private var songs: [Song] = [] {
        didSet {
            onChange()
        }
    }
    
    private let onChange: (Void) -> Void
    private let onSelection: (Song) -> Void
    
    private var imageDownloader = ImageDownloader()
    
    private var topSongRequest: TopSongsRequest!
}

// MARK: UICollectionViewDataSource

extension TopSongListViewAdapter: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.ReuseIdentifier, for: indexPath) as! CollectionViewCell
        configureCell(cell, forCollectionView:collectionView, atIndexPath:indexPath)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelection(songs[(indexPath as NSIndexPath).item])
    }
}

//MARK: Private methods

extension TopSongListViewAdapter {
    private func configureCell(_ cell: CollectionViewCell, forCollectionView collectionView: UICollectionView, atIndexPath indexPath: IndexPath) {
        let song = songs[(indexPath as NSIndexPath).item]
        cell.label.text = song.title
        
        if let imageURL = song.bigImageURL {
            let image = imageDownloader.imageForURL(imageURL) { [weak self] image in
                if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                    cell.imageView?.image = image
                } else {
                    cell.imageView?.image = nil
                }
                cell.imageView.layer.add(self!.animationForDownloadedImage(), forKey: nil)
            }
            cell.imageView.image = image
        }
    }
    
    private func animationForDownloadedImage() -> CAAnimation {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        return transition
    }
    
    private func showError(_ message: String) {
        print(message)
    }
}
