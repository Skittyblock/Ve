import Foundation

class DateSorter: AbstractSorter, SorterProtocol {
    /// Returns an array of specifiers sorted by date.
    func getSpecifiers() -> [PSSpecifier] {
        var specifiers: [PSSpecifier] = []
        let json = LogManager.sharedInstance().getJson()
        let logs = LogManager.sharedInstance().getLogsFromJson(json)
            as? [[AnyHashable: Any]] ?? []

        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true

        for date in getUniqueDatesForLogs(logs) {
            let dateString = formatter.string(from: date)
            specifiers.append(PSSpecifier.groupSpecifier(withName: dateString)!)

            for dictionary in logs {
                let log = Log(from: dictionary)

                if DateUtil.isDate(log.date, in: date) {
                    specifiers.append(createSpecifier(for: log))
                }
            }
        }

        return specifiers
    }

    /// Returns a unique array of start-of-day dates from logs.
    private func getUniqueDatesForLogs(_ logs: [[AnyHashable: Any]]) -> [Date] {
        let calendar = Calendar.current
        var dates: Set<Date> = []

        for dictionary in logs {
            let log = Log(from: dictionary)
            dates.insert(calendar.startOfDay(for: log.date))
        }

        return dates.sorted(by: >)
    }
}
