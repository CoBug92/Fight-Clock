import SwiftUI

struct SoundSettingsLink<Destination: View>: View {
    // MARK: - Properties

    let summary: String
    @ViewBuilder let destination: () -> Destination
    @Environment(\.colorSchemeContrast) private var contrast

    // MARK: - Layout

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: Margin.x8) {
                VStack(
                    alignment: .leading,
                    spacing: Margin.x4
                ) {
                    Text(Localizations.Setup.Sound.title)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text(summary)
                        .font(.subheadline)
                        .foregroundStyle(Color(.Text.secondaryForeground))
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: Margin.x8)
                Image(systemName: SFSymbol.chevronRight)
                    .font(.caption.bold())
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    .foregroundStyle(Color(.Text.secondaryForeground))
                    .accessibilityHidden(true)
            }
            .padding(Margin.x8)
            .background(
                Color(.Surface.cardBackground),
                in: RoundedRectangle(cornerRadius: .soundSettingsLinkCornerRadius)
            )
            .contentShape(RoundedRectangle(cornerRadius: .soundSettingsLinkCornerRadius))
            .overlay {
                if contrast == .increased {
                    RoundedRectangle(cornerRadius: .soundSettingsLinkCornerRadius)
                        .strokeBorder(.primary)
                        .allowsHitTesting(false)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Localizations.Setup.Sound.title)
        .accessibilityValue(summary)
    }
}

// MARK: - Constants

private extension CGFloat {
    static let soundSettingsLinkCornerRadius: CGFloat = 18
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(traits: .sizeThatFitsLayout) {
    NavigationStack {
        SoundSettingsLink(summary: "Гонг · Колокол · Ритм") {
            Color.clear
        }
        .padding()
    }
}
#endif
