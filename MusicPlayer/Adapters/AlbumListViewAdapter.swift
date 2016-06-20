
import UIKit


public class AlbumListViewAdapter: NSObject {
    
    public init(song: Song, onChange: (Void) -> Void, onSelection: (Album) -> Void) {
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
    
    private let onChange: (Void) -> Void
    
    private let onSelection: (Album) -> Void
    
    private var imageDownloader = ImageDownloader()
    
    private var artistDetailLoader: ArtistDetailLoader!
}

// MARK: UICollectionViewDataSource

extension AlbumListViewAdapter: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artistDetail?.albums.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.ReuseIdentifier, for: indexPath) as! CollectionViewCell
        configureCell(cell, forCollectionView:collectionView, atIndexPath:indexPath)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let album = artistDetail?.albums[(indexPath as NSIndexPath).item] {
            onSelection(album)
        }
    }
}

//MARK: Private methods

extension AlbumListViewAdapter {
    
    private func configureCell(_ cell: CollectionViewCell, forCollectionView collectionView: UICollectionView, atIndexPath indexPath: IndexPath) {
        let albumDetail = artistDetail!.albums[(indexPath as NSIndexPath).item]
        cell.label.text = albumDetail.name
        
        let imageURL =  albumDetail.imageURL
        let image = imageDownloader.imageForURL(imageURL) { [weak self] image in
            if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                cell.imageView?.image = image
            } else {
                cell.imageView?.image = nil
            }
            if let strongSelf  = self {
                cell.imageView.layer.add(strongSelf.animationForDownloadedImage(), forKey: nil)
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
    
    private func showError(_ message: String) {
        print(message)
    }
}

