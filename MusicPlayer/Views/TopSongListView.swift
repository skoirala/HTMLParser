
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
    
    public func setHeaderSize(size: CGSize) {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.headerReferenceSize = size
    }
    
    
    private func createViews() {
        let kGapBetweenBoundaries: CGFloat = 2
        let numberOfColumns: CGFloat = 2
        let screenWidth = UIScreen.main.bounds.size.width
        
        
        let gapInBetween: CGFloat = kGapBetweenBoundaries
        let sectionInset = UIEdgeInsets(top: 0, left: kGapBetweenBoundaries, bottom: kGapBetweenBoundaries, right: kGapBetweenBoundaries)
        let lineSpacing = kGapBetweenBoundaries
        
        let widthOfItem = (screenWidth - (numberOfColumns - 1) * gapInBetween - sectionInset.left - sectionInset.right) / numberOfColumns
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = gapInBetween
        flowLayout.sectionInset = sectionInset
        flowLayout.minimumLineSpacing = lineSpacing
        flowLayout.itemSize = CGSize(width: widthOfItem, height: widthOfItem)
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: flowLayout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.ReuseIdentifier)
        collectionView.register(ADContainerCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ADContainerCollectionReusableView.ReuseIdentifier)
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        let allConstraints = [
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor)
        ]
        allConstraints.forEach { $0.isActive = true }
        
        self.collectionView = collectionView
    }
    
}
