import SwiftUI

struct SoundSettingsLink<Destination: View>: View {
    // MARK: - Properties

    let summary: String
    @ViewBuilder let destination: () -> Destination

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
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: Margin.x8)
                Image(systemName: SFSymbol.chevronRight)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .padding(Margin.x8)
            .background(
                Color(.Surface.cardBackground),
                in: RoundedRectangle(cornerRadius: .soundSettingsLinkCornerRadius)
            )
        }
        .buttonStyle(.plain)
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
