import SwiftUI

struct StartSessionButton: View {
    // MARK: - Properties

    let onStart: () -> Void

    // MARK: - Layout

    var body: some View {
        Button(action: onStart) {
            Text(Localizations.Action.start)
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .padding(
                    .vertical,
                    Margin.x4
                )
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .controlSize(.large)
        .accessibilityHint(Localizations.Accessibility.startHint)
    }
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(traits: .sizeThatFitsLayout) {
    StartSessionButton(onStart: {})
        .padding()
}
#endif
