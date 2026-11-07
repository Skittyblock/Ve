import Foundation

class ApplicationSorter: AbstractSorter, SorterProtocol {
    /// Returns an array of specifiers sorted alphabetically by application.
    func getSpecifiers() -> [PSSpecifier] {
        var specifiers: [PSSpecifier] = []
        let json = LogManager.sharedInstance().getJson()
        let logs = LogManager.sharedInstance().getLogsFromJson(json)
            as? [[AnyHashable: Any]] ?? []

        for displayName in getUniqueDisplayNamesForLogs(logs) {
            specifiers.append(PSSpecifier.groupSpecifier(withName: displayName)!)

            for dictionary in logs {
                let log = Log(from: dictionary)

                if displayName == log.getDisplayName() {
                    specifiers.append(createSpecifier(for: log))
                }
            }
        }

        return specifiers
    }

    /// Returns a unique array of all display names from logs.
    ///
    /// Logs that return "SpringBoard" as their display name are added at the bottom.
    private func getUniqueDisplayNamesForLogs(_ logs: [[AnyHashable: Any]]) -> [String] {
        var displayNames: [String] = []
        var isUnknownPresent = false

        for dictionary in logs {
            let log = Log(from: dictionary)
            let displayName = log.getDisplayName()

            if !displayNames.contains(displayName) {
                if displayName == "SpringBoard" {
                    isUnknownPresent = true
                } else {
                    displayNames.append(displayName)
                }
            }
        }

        var sortedDisplayNames = displayNames.sorted {
            $0.compare($1) == .orderedAscending
        }

        if isUnknownPresent {
            sortedDisplayNames.append("SpringBoard")
        }

        return sortedDisplayNames
    }
}
