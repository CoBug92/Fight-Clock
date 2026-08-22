import SwiftUI

struct CollapsiblePickerCard<Content: View>: View {
    // MARK: - Properties

    let title: String
    let summary: String
    @Binding var isExpanded: Bool
    let content: Content

    // MARK: - Init

    init(
        title: String,
        summary: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.summary = summary
        _isExpanded = isExpanded
        self.content = content()
    }

    // MARK: - Layout

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: Margin.x4
        ) {
            Button {
                withAnimation(.bouncy(duration: .collapsiblePickerAnimationDuration)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: Margin.x4) {
                    Text(title)
                        .font(.title3.bold())
                    Spacer(minLength: Margin.x4)
                    if !isExpanded {
                        Text(summary)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                    Image(systemName: isExpanded ? SFSymbol.chevronUp : SFSymbol.chevronDown)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(summary)

            if isExpanded {
                content
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(Margin.x8)
        .background(
            Color(.Surface.cardBackground),
            in: RoundedRectangle(cornerRadius: .collapsiblePickerCardCornerRadius)
        )
    }
}

// MARK: - Constants

private extension CGFloat {
    static let collapsiblePickerCardCornerRadius: CGFloat = 18
}

private extension Double {
    static let collapsiblePickerAnimationDuration = 0.3
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(
    "Collapsed",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var isExpanded = false

    CollapsiblePickerCard(
        title: "Round",
        summary: "2:30",
        isExpanded: $isExpanded
    ) {
        Text("Duration picker")
    }
    .padding()
}

#Preview(
    "Expanded",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var isExpanded = true

    CollapsiblePickerCard(
        title: "Round",
        summary: "2:30",
        isExpanded: $isExpanded
    ) {
        Text("Duration picker")
    }
    .padding()
}
#endif
