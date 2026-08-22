import SwiftUI

struct NotificationPermissionCard: View {
    // MARK: - Properties

    let viewData: NotificationPermissionCardViewData
    let onAction: () -> Void

    // MARK: - Layout

    var body: some View {
        switch viewData.action {
        case .button:
            cardContent
        case .cardTap:
            Button(action: onAction) {
                cardContent
            }
            .buttonStyle(.plain)
        }
    }

    private var cardContent: some View {
        HStack(
            alignment: .top,
            spacing: Margin.x8
        ) {
            Image(systemName: SFSymbol.bellBadgeFill)
                .font(.title2)
                .foregroundStyle(.orange)
                .frame(
                    width: .notificationPermissionIconSize,
                    height: .notificationPermissionIconSize
                )
                .background(
                    .orange.opacity(.notificationPermissionIconOpacity),
                    in: Circle()
                )

            VStack(
                alignment: .leading,
                spacing: Margin.x4
            ) {
                Text(Localizations.Permission.title)
                    .font(.headline)
                Text(viewData.explanation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if case let .button(title) = viewData.action {
                    Button(
                        title,
                        action: onAction
                    )
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .padding(Margin.x8)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color(.Surface.cardBackground),
            in: RoundedRectangle(cornerRadius: .notificationPermissionCardCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: .notificationPermissionCardCornerRadius)
                .stroke(
                    .orange.opacity(.notificationPermissionBorderOpacity),
                    lineWidth: .notificationPermissionBorderWidth
                )
        }
    }
}

// MARK: - Constants

private extension CGFloat {
    static let notificationPermissionIconSize: CGFloat = 36
    static let notificationPermissionCardCornerRadius: CGFloat = 18
    static let notificationPermissionBorderWidth: CGFloat = 1
}

private extension Double {
    static let notificationPermissionIconOpacity = 0.14
    static let notificationPermissionBorderOpacity = 0.32
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(
    "Request",
    traits: .sizeThatFitsLayout
) {
    NotificationPermissionCard(
        viewData: NotificationPermissionCardViewData(
            explanation: Localizations.Permission.explanation,
            action: .button(title: Localizations.Permission.allow)
        ),
        onAction: {}
    )
    .padding()
}

#Preview(
    "Denied",
    traits: .sizeThatFitsLayout
) {
    NotificationPermissionCard(
        viewData: NotificationPermissionCardViewData(
            explanation: Localizations.Permission.deniedExplanation,
            action: .cardTap
        ),
        onAction: {}
    )
    .padding()
}
#endif
