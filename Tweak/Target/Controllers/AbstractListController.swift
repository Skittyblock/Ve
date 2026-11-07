import LocalAuthentication
import UIKit

class AbstractListController: PSEditableListController {
    private var preferences: UserDefaults = {
        let preferences = UserDefaults(suiteName: kPreferencesIdentifier)!
        preferences.register(defaults: [
            kPreferenceKeyUseBiometricProtection: false,
        ])
        return preferences
    }()

    var wantsAuth = false
    private var biometricProtectionOverlayView: BiometricProtectionOverlayView?
    private var willEnterForegroundTask: Task<Void, Never>?
    private var didBecomeActiveTask: Task<Void, Never>?

    override func viewDidLoad() {
        super.viewDidLoad()

        let biometricProtectionOverlayView = BiometricProtectionOverlayView(frame: view.bounds)
        biometricProtectionOverlayView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        view.addSubview(biometricProtectionOverlayView)
        self.biometricProtectionOverlayView = biometricProtectionOverlayView

        if wantsAuth {
            checkBiometrics()
        } else {
            hideBiometricProtectionOverlay()
        }

        let foregroundNotifications = NotificationCenter.default.notifications(
            named: UIApplication.willEnterForegroundNotification
        )
        let activeNotifications = NotificationCenter.default.notifications(
            named: UIApplication.didBecomeActiveNotification
        )
        willEnterForegroundTask = Task { @MainActor [weak self] in
            for await _ in foregroundNotifications {
                guard !Task.isCancelled, let self else { break }
                self.applicationWillEnterForeground()
            }
        }
        didBecomeActiveTask = Task { @MainActor [weak self] in
            for await _ in activeNotifications {
                guard !Task.isCancelled, let self else { break }
                self.applicationDidBecomeActive()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    /// Shows the biometric protection overlay when the app resigns active.
    @objc private func applicationWillResignActive() {
        showBiometricProtectionOverlay()
    }

    /// Notes that a biometric protection check should be performed when the app will enter the foreground.
    private func applicationWillEnterForeground() {
        wantsAuth = isBiometricProtectionEnabled()
    }

    /// Performs a biometric protection check and applies the filter button when the app entered the foreground.
    func applicationDidBecomeActive() {
        if !isBiometricProtectionEnabled() {
            wantsAuth = false
            hideBiometricProtectionOverlay()
            return
        }

        if wantsAuth {
            wantsAuth = false
            checkBiometrics()
        } else if biometricProtectionOverlayView?.isHidden == false {
            // UIApplicationWillEnterForegroundNotification is only fired when the app is in the background,
            // which means wantsAuth isn't set to YES when the app is pushed to the app switcher for example.
            // Since the biometric protection overlay is shown when the app resigns active, it needs to be hidden again.
            hideBiometricProtectionOverlay()
        }
    }

    private func isBiometricProtectionEnabled() -> Bool {
        preferences.bool(forKey: kPreferenceKeyUseBiometricProtection)
    }

    /// Performs a biometric protection check.
    ///
    /// If access granted, the biometric protection overlay view will be hidden.
    /// Otherwise, it'll pop the controller.
    private func checkBiometrics() {
        wantsAuth = false
        if !isBiometricProtectionEnabled() {
            hideBiometricProtectionOverlay()
            return
        }

        let laContext = LAContext()
        laContext.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Vē needs to make sure you're permitted to view the notification logs."
        ) { [weak self] success, _ in
            Task { @MainActor [weak self] in
                guard let self else { return }

                if success || !self.isBiometricProtectionEnabled() {
                    self.hideBiometricProtectionOverlay()
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    private func showBiometricProtectionOverlay() {
        biometricProtectionOverlayView?.isHidden = !isBiometricProtectionEnabled()
    }

    private func hideBiometricProtectionOverlay() {
        biometricProtectionOverlayView?.isHidden = true
    }
}
