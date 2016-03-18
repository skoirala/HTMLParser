
import UIKit


public class TopSongListView: UIView {
        
    private weak var collectionView: UICollectionView!
    
    public var dataSource: UICollectionViewDataSource? {
        set {
            collectionView.dataSource = newValue
        } get {
            return collectionView.dataSource
        }
    }
    
    public var delegate: UICollectionViewDelegate? {
        set {
            collectionView.delegate = newValue
        } get {
            return collectionView.delegate
        }
    }
    
    public func reloadData() {
        collectionView.reloadData()
    }
    
    
    public init() {
        super.init(frame: .zero)
        createViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func createViews() {
        let kGapBetweenBoundaries: CGFloat = 2
        let numberOfColumns: CGFloat = 2
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        
        
        let gapInBetween: CGFloat = kGapBetweenBoundaries
        let sectionInset = UIEdgeInsets(top: kGapBetweenBoundaries, left: kGapBetweenBoundaries, bottom: kGapBetweenBoundaries, right: kGapBetweenBoundaries)
        let lineSpacing = kGapBetweenBoundaries
        
        let widthOfItem = (screenWidth - (numberOfColumns - 1) * gapInBetween - sectionInset.left - sectionInset.right) / numberOfColumns
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = gapInBetween
        flowLayout.sectionInset = sectionInset
        flowLayout.minimumLineSpacing = lineSpacing
        flowLayout.itemSize = CGSizeMake(widthOfItem, widthOfItem)
        flowLayout.scrollDirection = .Vertical
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: flowLayout)
        collectionView.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.ReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        let allConstraints = [
            collectionView.topAnchor.constraintEqualToAnchor(topAnchor),
            collectionView.bottomAnchor.constraintEqualToAnchor(bottomAnchor),
            collectionView.leftAnchor.constraintEqualToAnchor(leftAnchor),
            collectionView.rightAnchor.constraintEqualToAnchor(rightAnchor)
        ]
        allConstraints.forEach { $0.active = true }
        
        self.collectionView = collectionView
    }
    
}
