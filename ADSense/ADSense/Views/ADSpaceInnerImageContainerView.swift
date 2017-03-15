
import Foundation

class ADSpaceInnerImageContainerView: ADSpaceView<UIImage> {
    
    var imageView: UIImageView!
    var closeButton: UIButton!
    var borderView: UIView!

    
    override public init(content: UIImage,
                contentSize: CGSize,
                click: @escaping () -> (),
                closed: @escaping () -> (),
                loadCompletion: @escaping () -> (),
                loadError: @escaping (Error) -> ()) {
        super.init(content: content,
                   contentSize: contentSize,
                   click: click,
                   closed: closed,
                   loadCompletion: loadCompletion,
                   loadError: loadError)
        setupImageViews()

    }

    override func showCloseButton(shows: Bool) {
        closeButton.isHidden = !shows
    }
    
    override func showBorder(shows: Bool) {
        borderView.isHidden = !shows
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func start() {
        onLoadCompletion()
    }
    
    private func setupImageViews() {
    
        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = content
        addSubview(imageView)
        
        let borderView = UIView(frame: .zero)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = UIColor.white
        addSubview(borderView)
        
        borderView.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        borderView.layer.shadowOpacity = 0.8
        borderView.layer.shadowColor = UIColor.darkGray.cgColor
        
        borderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        borderView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        borderView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        borderView.heightAnchor.constraint(equalToConstant: 2).isActive = true

        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: borderView.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageView.isUserInteractionEnabled = true
        
        let screenSize = UIScreen.main.bounds.size
        
        imageView.heightAnchor.constraint(equalToConstant: (screenSize.width / contentSize.width) * contentSize.height  );
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ADSpaceInnerImageContainerView.tapped))
        imageView.addGestureRecognizer(tap)
        
        
        let bundle = Bundle(for: ADSpaceInnerImageContainerView.self)
        let image = UIImage(named: "exit_gray", in: bundle, compatibleWith: nil)
        let templateImage = image?.withRenderingMode(.alwaysTemplate)
        
        let closeButton = UIButton(frame: .zero)
        closeButton.tintColor = window?.tintColor
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(templateImage, for: .normal)
        closeButton.backgroundColor = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        closeButton.layer.cornerRadius = 20
        addSubview(closeButton)
        closeButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        closeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        self.closeButton = closeButton
        self.borderView = borderView
        
    }

    @objc
    private func tapped() {
        click()
    }
    
    @objc
    private func closeButtonTapped() {
        closed()
    }
}

