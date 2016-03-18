

import UIKit


public class TopSongListViewAdapter: NSObject {
    
    public init(onChange: Void -> Void, selection: Song -> Void) {
        self.onChange = onChange
        self.onSelection = selection
    }
    
    public func loadTopSongs(completion: (Void -> Void)? = nil) {
        
        topSongRequest = TopSongsRequest(limit: 100)
        
        topSongRequest.startWithCompletion { result in
            completion?()
            switch result {
            case let .Success(results):
                self.songs = results
            case let .Failure(message):
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
    
    private let onChange: Void -> Void
    private let onSelection: Song -> Void
    
    private var imageDownloader = ImageDownloader()
    
    private var topSongRequest: TopSongsRequest!
}

// MARK: UICollectionViewDataSource

extension TopSongListViewAdapter: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCell.ReuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        configureCell(cell, forCollectionView:collectionView, atIndexPath:indexPath)
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        onSelection(songs[indexPath.item])
    }
}

//MARK: Private methods

extension TopSongListViewAdapter {
    private func configureCell(cell: CollectionViewCell, forCollectionView collectionView: UICollectionView, atIndexPath indexPath: NSIndexPath) {
        let song = songs[indexPath.item]
        cell.label.text = song.title
        
        if let imageURL = song.bigImageURL {
            let image = imageDownloader.imageForURL(imageURL) { [weak self] image in
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CollectionViewCell {
                    cell.imageView?.image = image
                } else {
                    cell.imageView?.image = nil
                }
                cell.imageView.layer.addAnimation(self!.animationForDownloadedImage(), forKey: nil)
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
    
    private func showError(message: String) {
        print(message)
    }
}