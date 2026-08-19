import SwiftUI

struct CollapsiblePickerCard<Content: View>: View {
    let title: String
    let summary: String
    @Binding var isExpanded: Bool
    let content: Content

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

    var body: some View {
        VStack(alignment: .leading, spacing: Margin.compact) {
            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: Margin.compact) {
                    Text(title)
                        .font(.title3.bold())
                    Spacer(minLength: Margin.compact)
                    if !isExpanded {
                        Text(summary)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
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
        .padding(Margin.standard)
        .background(Color(.cardBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Preview

#Preview("Collapsed") {
    @Previewable @State var isExpanded = false

    CollapsiblePickerCard(title: "Round", summary: "2:30", isExpanded: $isExpanded) {
        Text("Duration picker")
    }
    .padding()
}

#Preview("Expanded") {
    @Previewable @State var isExpanded = true

    CollapsiblePickerCard(title: "Round", summary: "2:30", isExpanded: $isExpanded) {
        Text("Duration picker")
    }
    .padding()
}
