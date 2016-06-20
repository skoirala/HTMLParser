
import UIKit


public class CollectionViewCell: UICollectionViewCell {
    
    public static let ReuseIdentifier = "com.TopSongListCollectionViewCell.ReuseIdentifier"
    
    public weak var imageView: UIImageView!
    public weak var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        label.text = nil
    }
    
    private func createViews() {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyleCaption2)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center

        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        
        vibrancyView.contentView.addSubview(label)
        blurEffectView.contentView.addSubview(vibrancyView)
        contentView.addSubview(blurEffectView)
        
        let constraints = [imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                           imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                           imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                           imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                           
                           blurEffectView.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50),
                           blurEffectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                           blurEffectView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                           blurEffectView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                           
                           vibrancyView.topAnchor.constraint(equalTo: blurEffectView.contentView.topAnchor),
                           vibrancyView.bottomAnchor.constraint(equalTo: blurEffectView.contentView.bottomAnchor),
                           vibrancyView.leftAnchor.constraint(equalTo: blurEffectView.contentView.leftAnchor),
                           vibrancyView.rightAnchor.constraint(equalTo: blurEffectView.contentView.rightAnchor),
                           
                           label.topAnchor.constraint(equalTo: vibrancyView.contentView.topAnchor),
                           label.bottomAnchor.constraint(equalTo: vibrancyView.contentView.bottomAnchor),
                           label.leftAnchor.constraint(equalTo: vibrancyView.contentView.leftAnchor, constant: 5),
                           label.rightAnchor.constraint(equalTo: vibrancyView.contentView.rightAnchor, constant: -5)
                        ]
        constraints.forEach { $0.isActive = true }
        
        self.imageView = imageView
        self.label = label
    }
}
