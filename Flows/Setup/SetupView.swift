import SwiftUI

struct SetupView: View {
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: Margin.section) {
                    header
                    roundsPicker
                    DurationPicker(
                        title: Localizations.Setup.roundDuration,
                        duration: roundDurationBinding,
                        range: 10...900
                    )
                    DurationPicker(
                        title: Localizations.Setup.restDuration,
                        duration: restDurationBinding,
                        range: 0...300
                    )
                    warningPicker
                    notificationNotice
                    startButton
                }
                .frame(maxWidth: 620)
                .frame(minHeight: proxy.size.height)
                .padding(.horizontal, Margin.screen)
                .padding(.vertical, Margin.section)
                .frame(maxWidth: .infinity)
            }
            .background(background)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Margin.compact) {
            Text(Localizations.App.name)
                .font(.system(size: 42, weight: .black, design: .rounded))
            Text(Localizations.Setup.tagline)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var roundsPicker: some View {
        HStack {
            Text(Localizations.Setup.rounds)
                .font(.title3.bold())
            Spacer()
            Picker(Localizations.Setup.rounds, selection: roundCountBinding) {
                ForEach(1...15, id: \.self) { count in
                    Text(count.formatted()).tag(count)
                }
            }
            .pickerStyle(.menu)
            .tint(.white)
        }
        .padding(Margin.standard)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
    }

    private var warningPicker: some View {
        VStack(alignment: .leading, spacing: Margin.compact) {
            Text(Localizations.Setup.Warning.title)
                .font(.title3.bold())
            Picker(Localizations.Setup.Warning.title, selection: roundWarningBinding) {
                Text(Localizations.Setup.Warning.disabled).tag(RoundWarning.disabled)
                Text(Localizations.Setup.Warning.tenSeconds).tag(RoundWarning.tenSeconds)
                Text(Localizations.Setup.Warning.thirtySeconds).tag(RoundWarning.thirtySeconds)
            }
            .pickerStyle(.segmented)
        }
        .padding(Margin.standard)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
    }

    @ViewBuilder
    private var notificationNotice: some View {
        if viewModel.notificationPermission != .allowed {
            VStack(alignment: .leading, spacing: Margin.compact) {
                Label(Localizations.Permission.title, systemImage: "bell.badge")
                    .font(.headline)
                Text(Localizations.Permission.explanation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if viewModel.notificationPermission == .notDetermined {
                    Button(Localizations.Permission.allow) {
                        Task { await viewModel.requestNotifications() }
                    }
                    .buttonStyle(.bordered)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var startButton: some View {
        Button {
            Task { await viewModel.start() }
        } label: {
            Text(Localizations.Action.start)
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, Margin.compact)
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .controlSize(.large)
        .accessibilityHint(Localizations.Accessibility.startHint)
    }

    private var background: some View {
        ZStack {
            Color(red: 0.04, green: 0.055, blue: 0.07)
            RadialGradient(
                colors: [.orange.opacity(0.22), .clear],
                center: .topTrailing,
                startRadius: 30,
                endRadius: 440
            )
        }
        .ignoresSafeArea()
    }

    private var roundCountBinding: Binding<Int> {
        Binding(get: { viewModel.roundCount }, set: { viewModel.update(roundCount: $0) })
    }

    private var roundDurationBinding: Binding<Int> {
        Binding(get: { viewModel.roundDuration }, set: { viewModel.update(roundDuration: $0) })
    }

    private var restDurationBinding: Binding<Int> {
        Binding(get: { viewModel.restDuration }, set: { viewModel.update(restDuration: $0) })
    }

    private var roundWarningBinding: Binding<RoundWarning> {
        Binding(get: { viewModel.roundWarning }, set: { viewModel.update(roundWarning: $0) })
    }
}

// MARK: - Preview

#Preview {
    SetupView(viewModel: AppDependencies().makeTimerViewModel())
        .preferredColorScheme(.dark)
}
