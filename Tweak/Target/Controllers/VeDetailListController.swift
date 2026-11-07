import UIKit

class VeDetailListController: AbstractListController {
    private var preferences: UserDefaults = {
        let preferences = UserDefaults(suiteName: kPreferencesIdentifier)!
        preferences.register(defaults: [
            kPreferenceKeyBlockedSenders: [String]()
        ])
        return preferences
    }()
    private lazy var pfBlockedSenders: [String] = {
        preferences.stringArray(forKey: kPreferenceKeyBlockedSenders) ?? []
    }()

    private let rightBarButtonItem: UIBarButtonItem = {
        if #available(iOS 26, *) {
            let removeImage = UIImage(systemName: "minus")
            return UIBarButtonItem(image: removeImage, menu: nil)
        } else {
            let removeButton = UIButton()
            let removeImage = UIImage(systemName: "minus.circle")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 23, weight: .regular)
            )
            removeButton.setImage(removeImage, for: .normal)
            removeButton.tintColor = .systemRed
            removeButton.showsMenuAsPrimaryAction = true
            return UIBarButtonItem(customView: removeButton)
        }
    }()
    private var log: Log?

    override var specifiers: NSMutableArray? {
        get {
            if let specifiers = value(forKey: "_specifiers") as? NSMutableArray {
                return specifiers
            } else {
                let specifiers = NSMutableArray()
                setValue(specifiers, forKey: "_specifiers")
                return specifiers
            }
        }
        set {
            super.specifiers = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        log = specifier.property(forKey: "log") as? Log
        loadSpecifiers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // The remove button needs to be set up after the view has loaded.
        // Otherwise the default "Edit" button will override it.
        navigationItem.rightBarButtonItem = rightBarButtonItem

        createRemoveButtonMenu()
    }

    private func loadSpecifiers() {
        guard let log else { return }

        let specifiers = NSMutableArray()
        let displayName = log.getDisplayName()

        let detailsSpecifier = PSSpecifier.groupSpecifier(withName: "Details")!
        detailsSpecifier.setProperty(
            "Tap on any cell to copy its contents.",
            forKey: "footerText"
        )
        specifiers.add(detailsSpecifier)

        let bundleIDSpecifier = PSSpecifier.preferenceSpecifierNamed(
            nil,
            target: self,
            set: nil,
            get: nil,
            detail: nil,
            cell: .buttonCell,
            edit: nil
        )!
        bundleIDSpecifier.setProperty(VeDetailCell.self, forKey: "cellClass")
        bundleIDSpecifier.buttonAction = #selector(copyContent(_:))
        bundleIDSpecifier.setProperty("Bundle Identifier", forKey: "title")
        bundleIDSpecifier.setProperty(log.bundleIdentifier, forKey: "content")
        specifiers.add(bundleIDSpecifier)

        let displayNameSpecifier = PSSpecifier.preferenceSpecifierNamed(
            nil,
            target: self,
            set: nil,
            get: nil,
            detail: nil,
            cell: .buttonCell,
            edit: nil
        )!
        displayNameSpecifier.setProperty(VeDetailCell.self, forKey: "cellClass")
        displayNameSpecifier.buttonAction = #selector(copyContent(_:))
        displayNameSpecifier.setProperty("Application", forKey: "title")
        displayNameSpecifier.setProperty(displayName, forKey: "content")
        specifiers.add(displayNameSpecifier)

        if !log.title.isEmpty {
            let titleSpecifier = PSSpecifier.preferenceSpecifierNamed(
                nil,
                target: self,
                set: nil,
                get: nil,
                detail: nil,
                cell: .buttonCell,
                edit: nil
            )!
            titleSpecifier.setProperty(VeDetailCell.self, forKey: "cellClass")
            titleSpecifier.buttonAction = #selector(copyContent(_:))
            titleSpecifier.setProperty("Title", forKey: "title")
            titleSpecifier.setProperty(log.title, forKey: "content")
            specifiers.add(titleSpecifier)
        }

        if let subtitle = log.subtitle {
            let subtitleSpecifier = PSSpecifier.preferenceSpecifierNamed(
                nil,
                target: self,
                set: nil,
                get: nil,
                detail: nil,
                cell: .buttonCell,
                edit: nil
            )!
            subtitleSpecifier.setProperty(VeDetailCell.self, forKey: "cellClass")
            subtitleSpecifier.buttonAction = #selector(copyContent(_:))
            subtitleSpecifier.setProperty("Subtitle", forKey: "title")
            subtitleSpecifier.setProperty(subtitle, forKey: "content")
            specifiers.add(subtitleSpecifier)
        }

        if !log.content.isEmpty {
            let contentSpecifier = PSSpecifier.preferenceSpecifierNamed(
                nil,
                target: self,
                set: nil,
                get: nil,
                detail: nil,
                cell: .buttonCell,
                edit: nil
            )!
            contentSpecifier.setProperty(VeDetailCell.self, forKey: "cellClass")
            contentSpecifier.buttonAction = #selector(copyContent(_:))
            contentSpecifier.setProperty("Message", forKey: "title")
            contentSpecifier.setProperty(log.content, forKey: "content")
            specifiers.add(contentSpecifier)
        }

        let dateSpecifier = PSSpecifier.preferenceSpecifierNamed(
            nil,
            target: self,
            set: nil,
            get: nil,
            detail: nil,
            cell: .buttonCell,
            edit: nil
        )!
        dateSpecifier.setProperty(VeDetailCell.self, forKey: "cellClass")
        dateSpecifier.buttonAction = #selector(copyContent(_:))
        dateSpecifier.setProperty("Date", forKey: "title")

        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        dateSpecifier.setProperty(formatter.string(from: log.date), forKey: "content")

        specifiers.add(dateSpecifier)

        let attachments = LogManager.sharedInstance().getAttachmentsFor(log) as? [UIImage] ?? []
        if !attachments.isEmpty {
            specifiers.add(PSSpecifier.groupSpecifier(withName: "Attachments")!)

            for image in attachments {
                let attachmentSpecifier = PSSpecifier.preferenceSpecifierNamed(
                    nil,
                    target: self,
                    set: nil,
                    get: nil,
                    detail: nil,
                    cell: .buttonCell,
                    edit: nil
                )!
                attachmentSpecifier.setProperty(VeAttachmentCell.self, forKey: "cellClass")
                attachmentSpecifier.buttonAction = #selector(presentAttachment(_:))
                attachmentSpecifier.setProperty(true, forKey: "enabled")
                attachmentSpecifier.setProperty(70, forKey: "height")
                attachmentSpecifier.setProperty(image, forKey: "image")
                specifiers.add(attachmentSpecifier)
            }
        }

        if displayName != "SpringBoard" {
            specifiers.add(PSSpecifier.emptyGroup()!)

            let openSpecifier = PSSpecifier.preferenceSpecifierNamed(
                "Open " + displayName,
                target: self,
                set: nil,
                get: nil,
                detail: nil,
                cell: .buttonCell,
                edit: nil
            )!
            openSpecifier.buttonAction = #selector(openSenderApplication)
            specifiers.add(openSpecifier)
        }

        insertContiguousSpecifiers(specifiers as [AnyObject], at: 0)
    }

    override func shouldReloadSpecifiersOnResume() -> Bool {
        false
    }

    private func createRemoveButtonMenu() {
        guard let log else { return }

        var actions: [UIAction] = []

        let removeAction = UIAction(
            title: "Remove",
            image: nil,
            identifier: nil
        ) { [weak self] _ in
            guard let self else { return }

            LogManager.sharedInstance().remove(self.log)
            self.parent.perform(#selector(reloadSpecifiers))
            self.navigationController?.popViewController(animated: true)
        }
        actions.append(removeAction)

        if pfBlockedSenders.contains(log.bundleIdentifier) {
            let unblockAction = UIAction(
                title: "Unblock Sender",
                image: nil,
                identifier: nil
            ) { [weak self] _ in
                guard let self else { return }

                self.pfBlockedSenders.removeAll {
                    $0 == log.bundleIdentifier
                }
                self.preferences.set(
                    self.pfBlockedSenders,
                    forKey: kPreferenceKeyBlockedSenders
                )
                CFNotificationCenterPostNotification(
                    CFNotificationCenterGetDarwinNotifyCenter(),
                    CFNotificationName(kNotificationKeyPreferencesReload as CFString),
                    nil,
                    nil,
                    true
                )
                self.createRemoveButtonMenu()
            }
            actions.append(unblockAction)
        } else {
            let blockAction = UIAction(
                title: "Block Sender",
                image: nil,
                identifier: nil
            ) { [weak self] _ in
                guard let self else { return }

                self.pfBlockedSenders.append(log.bundleIdentifier)
                self.preferences.set(
                    self.pfBlockedSenders,
                    forKey: kPreferenceKeyBlockedSenders
                )
                CFNotificationCenterPostNotification(
                    CFNotificationCenterGetDarwinNotifyCenter(),
                    CFNotificationName(kNotificationKeyPreferencesReload as CFString),
                    nil,
                    nil,
                    true
                )
                self.createRemoveButtonMenu()
            }
            actions.append(blockAction)
        }

        let menu = UIMenu(title: "", children: actions)

        if #available(iOS 26, *) {
            navigationItem.rightBarButtonItem?.menu = menu
        } else {
            (navigationItem.rightBarButtonItem?.customView as? UIButton)?.menu = menu
        }
    }

    /// Copies the specifier's content to the clipboard.
    @objc private func copyContent(_ specifier: PSSpecifier) {
        UIPasteboard.general.string = specifier.property(forKey: "content") as? String
    }

    /// Presents an attachment modally.
    @objc private func presentAttachment(_ specifier: PSSpecifier) {
        let attachmentListController = VeAttachmentListController()
        attachmentListController.image = specifier.property(forKey: "image") as? UIImage
        present(attachmentListController, animated: true)
    }

    /// Opens the log's sender application.
    @objc private func openSenderApplication() {
        guard let log else { return }
        openApplication(log.bundleIdentifier)
    }
}
