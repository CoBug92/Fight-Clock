import UIKit

@MainActor
final class IdleTimerController: IdleTimerControlling {
    // MARK: - Public methods

    func setDisabled(_ isDisabled: Bool) {
        UIApplication.shared.isIdleTimerDisabled = isDisabled
    }
}
