import UIKit

class VeAttachmentListController: AbstractListController {
    private var grabber: _UIGrabber?
    var image: UIImage?

    override var specifiers: NSMutableArray? {
        get {
            if let specifiers = value(forKey: "_specifiers") as? NSMutableArray {
                return specifiers
            } else {
                let specifiers = NSMutableArray()
                setValue(specifiers, forKey: "_specifiers")

                let attachmentSpecifier = PSSpecifier.preferenceSpecifierNamed(
                    nil,
                    target: self,
                    set: nil,
                    get: nil,
                    detail: nil,
                    cell: .staticTextCell,
                    edit: nil
                )!
                attachmentSpecifier.setProperty(VeFullAttachmentCell.self, forKey: "cellClass")
                attachmentSpecifier.setProperty(500, forKey: "height")
                attachmentSpecifier.setProperty(image, forKey: "image")
                specifiers.add(attachmentSpecifier)

                let actionsSpecifier = PSSpecifier.preferenceSpecifierNamed(
                    "Actions",
                    target: self,
                    set: nil,
                    get: nil,
                    detail: nil,
                    cell: .groupCell,
                    edit: nil
                )!
                specifiers.add(actionsSpecifier)

                let copySpecifier = PSSpecifier.preferenceSpecifierNamed(
                    "Copy to Clipboard",
                    target: self,
                    set: nil,
                    get: nil,
                    detail: nil,
                    cell: .buttonCell,
                    edit: nil
                )!
                copySpecifier.buttonAction = #selector(copyAttachment)
                specifiers.add(copySpecifier)

                let saveSpecifier = PSSpecifier.preferenceSpecifierNamed(
                    "Save to Photo Library",
                    target: self,
                    set: nil,
                    get: nil,
                    detail: nil,
                    cell: .buttonCell,
                    edit: nil
                )!
                saveSpecifier.buttonAction = #selector(saveAttachment)
                specifiers.add(saveSpecifier)

                return specifiers
            }
        }
        set {
            super.specifiers = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let grabber = _UIGrabber()
        self.grabber = grabber
        view.addSubview(grabber)

        grabber.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            grabber.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            grabber.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    /// Prevents the specifiers from reloading on resume.
    override func shouldReloadSpecifiersOnResume() -> Bool {
        false
    }

    /// Copies the attachment to the clipboard.
    @objc private func copyAttachment() {
        UIPasteboard.general.image = image
    }

    /// Saves the attachment to the photo library.
    @objc private func saveAttachment() {
        guard let image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
