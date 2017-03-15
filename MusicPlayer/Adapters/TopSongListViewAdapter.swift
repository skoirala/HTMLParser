

import UIKit

public class TopSongListViewAdapter: NSObject {
    
    weak public var headerView: UIView?
    
    public init(onChange: @escaping (Void) -> Void, selection: @escaping (Song) -> Void) {
        self.onChange = onChange
        self.onSelection = selection
    }
    
    public func loadTopSongs(countryIdentifier: String, _ completion: ((Void) -> Void)? = nil) {
        
        topSongRequest = TopSongsRequest(countryIdentifier: countryIdentifier, limit: 16)
        
        topSongRequest.startWithCompletion {  [weak self] result in
            if self == nil {
                return
            }
            switch result {
            case let .success(results):
                self?.songs = results
            case let .failure(message):
                self?.showError(message)
            }
        }
    }
    
    public func reset() {
        songs = []
    }
    
    internal var songs: [Song] = [] {
        didSet {
            onChange()
        }
    }
    
    internal let onChange: (Void) -> Void
    internal let onSelection: (Song) -> Void
    
    internal var imageDownloader = ImageDownloader()
    
    internal var topSongRequest: TopSongsRequest!
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
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader  && headerView != nil {
            let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ADContainerCollectionReusableView.ReuseIdentifier, for: indexPath) as! ADContainerCollectionReusableView
            supplementaryView.showView(view: headerView!)
            return supplementaryView
        }
        return UICollectionReusableView()
    }
}

//MARK: Private methods

extension TopSongListViewAdapter {
    internal func configureCell(_ cell: CollectionViewCell, forCollectionView collectionView: UICollectionView, atIndexPath indexPath: IndexPath) {
        let song = songs[(indexPath as NSIndexPath).item]
        cell.label.text = song.title
        if let imageURL = song.bigImageURL {
            
            let image = imageDownloader.imageForURL(imageURL) { [weak self] image in
                let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
                cell?.imageView?.image = image
                
                if let strongSelf  = self {
                    cell?.imageView.layer.add(strongSelf.animationForDownloadedImage(), forKey: nil)
                }
                
                if (cell == nil) {
                    collectionView.reloadItems(at: [indexPath])
                }
            }
            
            if image != nil {
                cell.imageView.image = image
            }
        }
    }
    
    internal func animationForDownloadedImage() -> CAAnimation {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        return transition
    }
    
    internal func showError(_ message: String) {
        print(message)
    }
}
