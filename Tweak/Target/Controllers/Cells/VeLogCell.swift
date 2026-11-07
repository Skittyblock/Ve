import UIKit

class VeLogCell: PSTableCell {
    private let iconImageView = UIImageView()
    private let logTitleLabel = UILabel()
    private let logContentLabel = UILabel()

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

        let log = specifier?.property(forKey: "log") as? Log

        if let log {
            iconImageView.image = UIImage._applicationIconImage(
                forBundleIdentifier: log.bundleIdentifier,
                format: 1,
                scale: 2
            )
        }
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 7
        iconImageView.layer.borderWidth = 0.5
        iconImageView.layer.borderColor = UIColor.label.withAlphaComponent(0.1).cgColor
        addSubview(iconImageView)

        if let log {
            logTitleLabel.text = log.title.isEmpty ? log.getDisplayName() : log.title
        }
        logTitleLabel.textColor = .label
        logTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(logTitleLabel)

        if let log {
            logContentLabel.text = log.content.isEmpty ? "N/A" : log.content
        }
        logContentLabel.textColor = UIColor.label.withAlphaComponent(0.6)
        logContentLabel.font = .systemFont(ofSize: 14, weight: .regular)
        addSubview(logContentLabel)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        logTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        logContentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            logTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            logTitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            logTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            logContentLabel.topAnchor.constraint(equalTo: logTitleLabel.bottomAnchor, constant: 2),
            logContentLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            logContentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
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
