import UIKit

class BiometricProtectionOverlayView: UIView {
    private let iconImageView = UIImageView()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemBackground

        let configuration = UIImage.SymbolConfiguration(pointSize: 138, weight: .regular)
        iconImageView.image = UIImage(systemName: "lock.fill")?.withConfiguration(configuration)

        iconImageView.tintColor = UIColor.label.withAlphaComponent(0.6)
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)

        label.text = "Notification Logs\nAre Locked"
        label.textColor = UIColor.label.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 28, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 2
        addSubview(label)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -26),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: iconImageView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
