import Foundation
import Observation
import ServiceManagement

@MainActor
@Observable
final class LoginItem {
    private static let configuredKey = "loginItemConfigured"
    private(set) var isEnabled = SMAppService.mainApp.status == .enabled
    private(set) var error: String?

    func enableOnFirstLaunch() {
        guard !UserDefaults.standard.bool(forKey: Self.configuredKey) else { return }
        UserDefaults.standard.set(true, forKey: Self.configuredKey)
        setEnabled(true)
    }

    func toggle() {
        setEnabled(!isEnabled)
    }

    private func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            error = nil
        } catch {
            self.error = "Could not change Open at login: \(error.localizedDescription)"
        }
        let status = SMAppService.mainApp.status
        isEnabled = status == .enabled
        if enabled, status == .requiresApproval {
            error = "Allow DevPorts in System Settings > General > Login Items"
        }
    }
}
