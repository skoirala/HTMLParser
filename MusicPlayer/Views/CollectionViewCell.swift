
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
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        label.textAlignment = .Center

        let blurEffect = UIBlurEffect(style: .ExtraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        
        vibrancyView.contentView.addSubview(label)
        blurEffectView.contentView.addSubview(vibrancyView)
        contentView.addSubview(blurEffectView)
        
        let constraints = [imageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor),
                           imageView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor),
                           imageView.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor),
                           imageView.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor),
                           
                           blurEffectView.topAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -50),
                           blurEffectView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor),
                           blurEffectView.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor),
                           blurEffectView.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor),
                           
                           vibrancyView.topAnchor.constraintEqualToAnchor(blurEffectView.contentView.topAnchor),
                           vibrancyView.bottomAnchor.constraintEqualToAnchor(blurEffectView.contentView.bottomAnchor),
                           vibrancyView.leftAnchor.constraintEqualToAnchor(blurEffectView.contentView.leftAnchor),
                           vibrancyView.rightAnchor.constraintEqualToAnchor(blurEffectView.contentView.rightAnchor),
                           
                           label.topAnchor.constraintEqualToAnchor(vibrancyView.contentView.topAnchor),
                           label.bottomAnchor.constraintEqualToAnchor(vibrancyView.contentView.bottomAnchor),
                           label.leftAnchor.constraintEqualToAnchor(vibrancyView.contentView.leftAnchor, constant: 5),
                           label.rightAnchor.constraintEqualToAnchor(vibrancyView.contentView.rightAnchor, constant: -5)
                        ]
        constraints.forEach { $0.active = true }
        
        self.imageView = imageView
        self.label = label
    }
}