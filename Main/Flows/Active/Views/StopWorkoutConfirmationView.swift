import SwiftUI

// MARK: - StopWorkoutConfirmationView

struct StopWorkoutConfirmationView: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    // MARK: - Layout

    var body: some View {
        VStack(spacing: Margin.x8) {
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: Margin.x4
                ) {
                    Text(Localizations.Stop.title)
                        .font(.title2.bold())
                        .accessibilityAddTraits(.isHeader)
                    Text(Localizations.Stop.message)
                        .font(.body)
                }
                .multilineTextAlignment(.leading)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }

            Button(
                role: .destructive,
                action: onConfirm
            ) {
                Text(Localizations.Stop.confirm)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(Color(.Text.timerDestructiveForeground))

            Button(
                role: .cancel,
                action: onCancel
            ) {
                Text(Localizations.Action.cancel)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .font(.headline)
        .controlSize(.large)
        .multilineTextAlignment(.center)
        .padding(Margin.x8)
        .presentationDragIndicator(.visible)
        .accessibilityAction(.escape, onCancel)
    }
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview {
    StopWorkoutConfirmationView(onConfirm: {}, onCancel: {})
        .environment(\.dynamicTypeSize, .accessibility5)
}
#endif
