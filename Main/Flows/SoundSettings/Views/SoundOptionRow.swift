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
                Spacer()
                Image(systemName: isSelected ? SFSymbol.checkmarkCircleFill : SFSymbol.circle)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .orange : .secondary)
            }
            .padding(
                .vertical,
                Margin.x3
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
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
