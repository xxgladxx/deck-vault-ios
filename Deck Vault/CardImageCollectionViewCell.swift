import UIKit

class CardImageCollectionViewCell: UICollectionViewCell {

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    let selectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.contentMode = .bottom
        imageView.clipsToBounds = true
        imageView.tintColor = .systemGreen
        imageView.isHidden = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectionImageView)

        contentView.backgroundColor = .clear // Set content view's background color to clear
        backgroundColor = .clear // Set cell's background color to clear

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        selectionImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectionImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            selectionImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionImageView.widthAnchor.constraint(equalToConstant: 20),
            selectionImageView.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    func configure(with image: UIImage?, isSelected: Bool) {
        imageView.image = image
        selectionImageView.isHidden = !isSelected
    }
}
