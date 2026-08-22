import UIKit

@MainActor
final class AppSettingsOpener: AppSettingsOpening {
    // MARK: - Public methods

    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }
}
