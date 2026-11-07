import Foundation

class AbstractSorter: NSObject {
    var object: Any?

    init(object: Any?) {
        self.object = object
        super.init()
    }

    func createSpecifier(for log: Log) -> PSSpecifier {
        let specifier = PSSpecifier.preferenceSpecifierNamed(
            nil,
            target: nil,
            set: nil,
            get: nil,
            detail: VeDetailListController.self,
            cell: .linkCell,
            edit: nil
        )!
        specifier.setProperty(VeLogCell.self, forKey: "cellClass")
        specifier.setProperty("removedSpecifier:", forKey: PSDeletionActionKey)
        specifier.setProperty(true, forKey: "enabled")
        specifier.setProperty(60, forKey: "height")
        specifier.setProperty(log, forKey: "log")
        return specifier
    }
}
