
import UIKit


public class AlbumListViewAdapter: NSObject {
    
    public init(song: Song, onChange: Void -> Void, onSelection: Album -> Void) {
        self.onChange = onChange
        self.onSelection = onSelection
        artistDetailLoader = ArtistDetailLoader(song: song)
    }
    
    public func loadArtistDetail() {
        artistDetailLoader.loadArtistDetail { detail in
            self.artistDetail = detail
        }
    }
    
    private var artistDetail: ArtistDetail? {
        didSet {
            onChange()
        }
    }
    
    private let onChange: Void -> Void
    
    private let onSelection: Album -> Void
    
    private var imageDownloader = ImageDownloader()
    
    private var artistDetailLoader: ArtistDetailLoader!
}

// MARK: UICollectionViewDataSource

extension AlbumListViewAdapter: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artistDetail?.albums.count ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCell.ReuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        configureCell(cell, forCollectionView:collectionView, atIndexPath:indexPath)
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let album = artistDetail?.albums[indexPath.item] {
            onSelection(album)
        }
    }
}

//MARK: Private methods

extension AlbumListViewAdapter {
    
    private func configureCell(cell: CollectionViewCell, forCollectionView collectionView: UICollectionView, atIndexPath indexPath: NSIndexPath) {
        let albumDetail = artistDetail!.albums[indexPath.item]
        cell.label.text = albumDetail.name
        
        let imageURL =  albumDetail.imageURL
        let image = imageDownloader.imageForURL(imageURL) { [weak self] image in
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CollectionViewCell {
                cell.imageView?.image = image
            } else {
                cell.imageView?.image = nil
            }
            if let strongSelf  = self {
                cell.imageView.layer.addAnimation(strongSelf.animationForDownloadedImage(), forKey: nil)
            }
        }
        cell.imageView.image = image
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

