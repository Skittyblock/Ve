import Foundation

class SearchSorter: AbstractSorter, SorterProtocol {
    /// Returns an array of specifiers sorted with a search term.
    func getSpecifiers() -> [PSSpecifier] {
        var specifiers: [PSSpecifier] = []
        let json = LogManager.sharedInstance().getJson()
        let logs = LogManager.sharedInstance().getLogsFromJson(json)
            as? [[AnyHashable: Any]] ?? []

        specifiers.append(PSSpecifier.groupSpecifier(withName: "Search Results")!)

        guard let searchTerm = (object as? String)?.lowercased() else {
            return specifiers
        }

        for dictionary in logs {
            let log = Log(from: dictionary)

            if log.title.lowercased().contains(searchTerm) || log.content.lowercased().contains(searchTerm) {
                specifiers.append(createSpecifier(for: log))
            }
        }

        return specifiers
    }
}
