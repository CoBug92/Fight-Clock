import SwiftUI

struct SetupHeaderView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = CGFloat.setupHeaderTitleFontSize

    // MARK: - Layout

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: Margin.x4
        ) {
            Text(Localizations.App.name)
                .font(titleFont)
                .accessibilityAddTraits(.isHeader)
            Text(Localizations.Setup.tagline)
                .font(.headline)
                .foregroundStyle(Color(.Text.secondaryForeground))
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    private var titleFont: Font {
        if dynamicTypeSize.isAccessibilitySize {
            return .system(
                .largeTitle,
                design: .rounded,
                weight: .black
            )
        }
        return .system(
            size: titleSize,
            weight: .black,
            design: .rounded
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
