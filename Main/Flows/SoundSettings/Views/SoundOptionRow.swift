import SwiftUI

struct SoundOptionRow: View {
    // MARK: - Properties

    let sound: BundledTimerSound
    let isSelected: Bool
    let onSelect: () -> Void

    // MARK: - Layout

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Margin.x8) {
                Text(sound.localizedTitle)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                Spacer()
                Image(systemName: isSelected ? SFSymbol.checkmarkCircleFill : SFSymbol.circle)
                    .font(.title3)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    .foregroundStyle(isSelected ? Color(.Text.accentForeground) : Color(.Text.secondaryForeground))
                    .accessibilityHidden(true)
            }
            .padding(
                .vertical,
                Margin.x3
            )
            .frame(minHeight: .soundOptionMinimumTouchHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Constants

private extension CGFloat {
    static let soundOptionMinimumTouchHeight: CGFloat = 44
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(
    traits: .sizeThatFitsLayout
) {
    VStack(spacing: .zero) {
        SoundOptionRow(
            sound: .brightBell,
            isSelected: true,
            onSelect: {}
        )
        .padding()
        SoundOptionRow(
            sound: .brightBell,
            isSelected: false,
            onSelect: {}
        )
        .padding()
    }
}
#endif
