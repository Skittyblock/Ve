import UIKit

class VeFullAttachmentCell: PSTableCell {
    private let attachmentImageView = UIImageView()

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?,
        specifier: PSSpecifier?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier,
            specifier: specifier
        )

        let image = specifier?.property(forKey: "image") as? UIImage

        attachmentImageView.image = image
        attachmentImageView.contentMode = .scaleAspectFill
        addSubview(attachmentImageView)

        attachmentImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            attachmentImageView.topAnchor.constraint(equalTo: topAnchor),
            attachmentImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            attachmentImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            attachmentImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
