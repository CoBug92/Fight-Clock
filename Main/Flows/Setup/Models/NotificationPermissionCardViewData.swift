struct NotificationPermissionCardViewData {
    let explanation: String
    let action: Action

    enum Action {
        case button(title: String)
        case cardTap
    }
}
