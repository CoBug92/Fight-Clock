import SwiftUI

struct SetupHeaderView: View {
    // MARK: - Layout

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: Margin.x4
        ) {
            Text(Localizations.App.name)
                .font(
                    .system(
                        size: .setupHeaderTitleFontSize,
                        weight: .black,
                        design: .rounded
                    )
                )
            Text(Localizations.Setup.tagline)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
}

// MARK: - Constants

private extension CGFloat {
    static let setupHeaderTitleFontSize: CGFloat = 42
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(traits: .sizeThatFitsLayout) {
    SetupHeaderView()
        .padding()
}
#endif
