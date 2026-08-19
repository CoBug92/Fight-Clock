import UIKit

@MainActor
final class IdleTimerController: IdleTimerControlling {
    func setDisabled(_ isDisabled: Bool) {
        UIApplication.shared.isIdleTimerDisabled = isDisabled
    }
}
