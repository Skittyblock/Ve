import UIKit

class VeAttachmentCell: PSTableCell {
    private let attachmentImageView = UIImageView()
    private let attachmentTitleLabel = UILabel()
    private let attachmentSizeLabel = UILabel()

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
        attachmentImageView.clipsToBounds = true
        attachmentImageView.layer.cornerRadius = 6
        addSubview(attachmentImageView)

        attachmentTitleLabel.text = "Image"
        attachmentTitleLabel.textColor = .label
        attachmentTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        addSubview(attachmentTitleLabel)

        let size = image?.size ?? .zero
        attachmentSizeLabel.text = String(
            format: "Width: %.0fpx Height: %.0fpx",
            Double(size.width),
            Double(size.height)
        )
        attachmentSizeLabel.textColor = UIColor.label.withAlphaComponent(0.6)
        attachmentSizeLabel.font = .systemFont(ofSize: 14, weight: .regular)
        addSubview(attachmentSizeLabel)

        attachmentImageView.translatesAutoresizingMaskIntoConstraints = false
        attachmentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        attachmentSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            attachmentImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            attachmentImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            attachmentImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            attachmentImageView.widthAnchor.constraint(equalToConstant: 90),
            attachmentTitleLabel.leadingAnchor.constraint(equalTo: attachmentImageView.trailingAnchor, constant: 12),
            attachmentTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            attachmentTitleLabel.centerYAnchor.constraint(equalTo: attachmentImageView.centerYAnchor, constant: -11),
            attachmentSizeLabel.leadingAnchor.constraint(equalTo: attachmentImageView.trailingAnchor, constant: 12),
            attachmentSizeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            attachmentSizeLabel.centerYAnchor.constraint(equalTo: attachmentImageView.centerYAnchor, constant: 11)
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
