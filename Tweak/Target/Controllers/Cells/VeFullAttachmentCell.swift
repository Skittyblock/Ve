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

        attachmentImageView.contentMode = .scaleAspectFill
        addSubview(attachmentImageView)

        attachmentImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            attachmentImageView.topAnchor.constraint(equalTo: topAnchor),
            attachmentImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            attachmentImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            attachmentImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        configure(with: specifier)
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

    override func refreshCellContents(with specifier: PSSpecifier?) {
        super.refreshCellContents(with: specifier)
        configure(with: specifier)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        configure(with: nil)
    }

    private func configure(with specifier: PSSpecifier?) {
        let image = specifier?.property(forKey: "image") as? UIImage
        attachmentImageView.image = image
    }
}
