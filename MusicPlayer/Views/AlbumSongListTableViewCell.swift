
import UIKit


public class AlbumSongListTableViewCell: UITableViewCell {
    
    public weak var playButton: PlayPauseButton!
    public weak var titleLabel: UILabel!

    public var onPlayButtonTapped: (Void -> Void)!
    
    public func setPlaying() {
        playButton.playingState = .Playing
    }
    
    public func setPaused() {
        playButton.playingState = .Paused
    }
    
    public func updateProgress(progress: CGFloat) {
        playButton.progress = progress
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        setPaused()
    }
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clearColor()
        createViews()
        setupConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createViews() {
        let playButton = PlayPauseButton(frame: .zero)
        playButton.addTarget(self, action: Selector("playButtonTapped"), forControlEvents: .TouchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playButton)
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        self.playButton = playButton
        self.titleLabel = titleLabel
    }
    
    @objc private func playButtonTapped() {
        onPlayButtonTapped()
    }
    
    private func setupConstraints() {
        let views = ["titleLabel": titleLabel, "playButton": playButton]
        
        let hFormat = "H:|-[titleLabel]-[playButton(==24)]-|"
        let titleLabelVFormat = "V:|-[titleLabel]-|"
        let playButtonVFormat = "V:|-(>=0)-[playButton]-(>=0)-|"
        
        [hFormat, titleLabelVFormat, playButtonVFormat].forEach { format in
            let constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: views)
            contentView.addConstraints(constraints)
        }
        playButton.widthAnchor.constraintEqualToAnchor(playButton.heightAnchor).active = true
        playButton.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor).active = true
        
    }
}
