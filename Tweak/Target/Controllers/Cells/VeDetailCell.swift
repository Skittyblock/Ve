import UIKit

class VeDetailCell: PSTableCell {
    private let detailTitleLabel = UILabel()
    private let detailContentLabel = UILabel()

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

        detailContentLabel.textColor = UIColor.label.withAlphaComponent(0.6)
        detailContentLabel.font = .systemFont(ofSize: 17, weight: .regular)
        detailContentLabel.textAlignment = .right
        detailContentLabel.setMarqueeEnabled(true)
        detailContentLabel.setMarqueeRunning(true)
        addSubview(detailContentLabel)

        detailTitleLabel.textColor = .label
        detailTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        addSubview(detailTitleLabel)

        detailContentLabel.translatesAutoresizingMaskIntoConstraints = false
        detailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailContentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            detailContentLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            detailTitleLabel.trailingAnchor.constraint(equalTo: detailContentLabel.leadingAnchor, constant: -8),
            detailTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            detailTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
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
        let title = specifier?.property(forKey: "title") as? String
        let content = specifier?.property(forKey: "content") as? String

        detailTitleLabel.text = title
        detailContentLabel.text = content
    }
}
