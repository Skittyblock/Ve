import UIKit

enum SortOption: String {
    case application = "Application"
    case date = "Date"
    case search = "Search"
}

@objc(VeLogsListController)
class VeLogsListController: AbstractListController {
    private var preferences: UserDefaults = {
        let preferences = UserDefaults(suiteName: kPreferencesIdentifier)!
        preferences.register(defaults: [
            kPreferenceKeySorting: kPreferenceKeySortingDefaultValue
        ])
        return preferences
    }()
    private lazy var pfSorting: SortOption = {
        preferences.string(forKey: kPreferenceKeySorting).flatMap(SortOption.init) ?? .date
    }()

    private lazy var pullToRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(handlePullToRefresh),
            for: .valueChanged
        )
        // pullToRefreshControl.tintColor = .label
        return refreshControl
    }()
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    private let rightBarButtonItem: UIBarButtonItem = {
        if #available(iOS 26, *) {
            let filterImage = UIImage(systemName: "line.3.horizontal.decrease")
            return UIBarButtonItem(image: filterImage, menu: nil)
        } else {
            let filterButton = UIButton()
            let filterImage = UIImage(
                systemName: "line.3.horizontal.decrease.circle"
            )?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 23, weight: .regular)
            )
            filterButton.setImage(filterImage, for: .normal)
            filterButton.tintColor = .systemBlue
            filterButton.showsMenuAsPrimaryAction = true
            return UIBarButtonItem(customView: filterButton)
        }
    }()

    override var specifiers: NSMutableArray? {
        get {
            if let specifiers = value(forKey: "_specifiers") as? NSMutableArray {
                return specifiers
            } else {
                let specifiers = NSMutableArray()
                setValue(specifiers, forKey: "_specifiers")

                if searchController.searchBar.text != "" {
                    specifiers.addObjects(
                        from: getSpecifiersForSorting(
                            .search,
                            withObject: searchController.searchBar.text
                        )
                    )
                } else {
                    specifiers.addObjects(
                        from: getSpecifiersForSorting(pfSorting, withObject: nil)
                    )
                }

                return specifiers
            }
        }
        set {
            super.specifiers = newValue
        }
    }

    /// Sets up the controller's view.
    override func viewDidLoad() {
        wantsAuth = true
        super.viewDidLoad()

        navigationItem.searchController = searchController
        table.refreshControl = pullToRefreshControl

        reloadSpecifiers()
    }

    /// Sets up the filter button after the default "Edit" button is installed.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.rightBarButtonItem = rightBarButtonItem

        createFilterButtonMenu()
    }

    /// Restores the filter button when the app enters the foreground.
    override func applicationDidBecomeActive() {
        super.applicationDidBecomeActive()
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    /// Prevents the specifiers from reloading on resume.
    override func shouldReloadSpecifiersOnResume() -> Bool {
        false
    }

    /// Creates the filter button's menu.
    private func createFilterButtonMenu() {
        let applicationSortingAction = UIAction(
            title: SortOption.application.rawValue,
            image: nil,
            identifier: nil
        ) { [weak self] _ in
            guard let self else { return }

            self.pfSorting = .application
            preferences.set(self.pfSorting.rawValue, forKey: kPreferenceKeySorting)

            self.createFilterButtonMenu()
            self.reloadSpecifiers()
        }

        let dateSortingAction = UIAction(
            title: SortOption.date.rawValue,
            image: nil,
            identifier: nil
        ) { [weak self] _ in
            guard let self else { return }

            self.pfSorting = .date
            preferences.set(self.pfSorting.rawValue, forKey: kPreferenceKeySorting)

            self.createFilterButtonMenu()
            self.reloadSpecifiers()
        }

        if pfSorting == .application {
            applicationSortingAction.state = .on
        } else if pfSorting == .date {
            dateSortingAction.state = .on
        }

        let menu = UIMenu(title: "", children: [applicationSortingAction, dateSortingAction])

        if #available(iOS 26, *) {
            navigationItem.rightBarButtonItem?.menu = menu
        } else {
            (navigationItem.rightBarButtonItem?.customView as? UIButton)?.menu = menu
        }
    }

    /// Returns an array of sorted specifiers.
    private func getSpecifiersForSorting(
        _ sorting: SortOption,
        withObject object: Any?
    ) -> [PSSpecifier] {
        let sorter: (any SorterProtocol)?

        if sorting == .application {
            sorter = ApplicationSorter(object: object)
        } else if sorting == .date {
            sorter = DateSorter(object: object)
        } else if sorting == .search {
            sorter = SearchSorter(object: object)
        } else {
            sorter = nil
        }

        let specifiers = sorter?.getSpecifiers() as? [PSSpecifier] ?? []

        // The target is this controller, not the sorter.
        for specifier in specifiers {
            specifier.target = self
            specifier.setProperty(
                NSStringFromSelector(#selector(removedSpecifier(_:))),
                forKey: PSDeletionActionKey
            )
        }

        return specifiers
    }

    /// Removes a log when its specifier is removed.
    @objc private func removedSpecifier(_ specifier: PSSpecifier) {
        LogManager.sharedInstance().remove(
            specifier.property(forKey: "log") as? Log
        )
        reloadSpecifiers()
    }

    /// Reloads the specifiers via pull to refresh.
    @objc private func handlePullToRefresh() {
        reloadSpecifiers()
        pullToRefreshControl.endRefreshing()
    }
}

extension VeLogsListController: UISearchBarDelegate {
    /// Reloads the specifiers when the search button is tapped.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        reloadSpecifiers()
    }

    /// Resets the search text before reloading the specifiers.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // The search bar clears its text automatically, but not before the specifiers are reloaded.
        searchController.searchBar.text = ""
        reloadSpecifiers()
    }
}
