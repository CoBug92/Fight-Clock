import SwiftUI

struct CollapsiblePickerCard<Content: View>: View {
    // MARK: - Properties

    let title: String
    let summary: String
    let accessibleSummary: String
    @Binding var isExpanded: Bool
    let content: Content
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast

    // MARK: - Init

    init(
        title: String,
        summary: String,
        accessibleSummary: String? = nil,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.summary = summary
        self.accessibleSummary = accessibleSummary ?? summary
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
                withAnimation(reduceMotion ? nil : .bouncy(duration: .collapsiblePickerAnimationDuration)) {
                    isExpanded.toggle()
                }
            } label: {
                let layout = dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout(
                    alignment: .leading,
                    spacing: Margin.x2
                )) : AnyLayout(HStackLayout(spacing: Margin.x4))

                HStack(spacing: Margin.x4) {
                    layout {
                        Text(title)
                            .font(.title3.bold())
                            .layoutPriority(1)
                        if !dynamicTypeSize.isAccessibilitySize {
                            Spacer(minLength: Margin.x4)
                        }
                        if !isExpanded {
                            Text(summary)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color(.Text.secondaryForeground))
                                .multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .trailing)
                        }
                    }
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                    if dynamicTypeSize.isAccessibilitySize {
                        Spacer(minLength: .zero)
                    }
                    Image(systemName: isExpanded ? SFSymbol.chevronUp : SFSymbol.chevronDown)
                        .font(.caption.bold())
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        .foregroundStyle(Color(.Text.secondaryForeground))
                        .accessibilityHidden(true)
                }
                .frame(minHeight: .collapsiblePickerMinimumTouchHeight)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(title)
            .accessibilityValue(Localizations.Accessibility.disclosureValue(
                accessibleSummary,
                isExpanded ? Localizations.Accessibility.expanded : Localizations.Accessibility.collapsed
            ))
            .accessibilityAddTraits(.isHeader)

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
        .overlay {
            if contrast == .increased {
                RoundedRectangle(cornerRadius: .collapsiblePickerCardCornerRadius)
                    .strokeBorder(.primary)
                    .allowsHitTesting(false)
            }
        }
    }
}

// MARK: - Constants

private extension CGFloat {
    static let collapsiblePickerCardCornerRadius: CGFloat = 18
    static let collapsiblePickerMinimumTouchHeight: CGFloat = 44
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
