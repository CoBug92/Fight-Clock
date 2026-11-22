import SwiftUI

// MARK: - AppLaunchOverlayView

struct AppLaunchOverlayView: View {
    // MARK: - Properties

    static let displayDuration: Duration = .seconds(.launchDisplaySeconds)

    private let columns = Array(
        repeating: GridItem(.fixed(.launchTileSize), spacing: Margin.x3),
        count: .launchGridColumns
    )

    // MARK: - Observable properties

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startedAt = ContinuousClock.now

    // MARK: - Layout

    var body: some View {
        ZStack {
            background

            if reduceMotion {
                dial(elapsed: .zero, progress: 1)
            } else {
                TimelineView(.animation) { _ in
                    let elapsed = startedAt.duration(to: .now).components
                    let seconds = Double(elapsed.seconds) + Double(elapsed.attoseconds) / .launchAttosecondsPerSecond
                    dial(
                        elapsed: seconds,
                        progress: min(1, seconds / .launchDisplaySeconds)
                    )
                }
            }
        }
        .accessibilityHidden(true)
        .onAppear {
            startedAt = .now
        }
    }

    // MARK: - Private methods

    private var background: some View {
        ZStack {
            Color(.Background.launchBackground)

            RadialGradient(
                colors: [Color(.Effect.setupGlow), .clear],
                center: .topTrailing,
                startRadius: .launchGlowStartRadius,
                endRadius: .launchGlowEndRadius
            )
        }
        .ignoresSafeArea()
    }

    private func dial(elapsed: Double, progress: Double) -> some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay {
                    Circle().strokeBorder(.primary.opacity(.launchDialBorderOpacity))
                }
                .frame(
                    width: .launchDialFaceSize,
                    height: .launchDialFaceSize
                )

            ForEach(LaunchSport.allCases, id: \.self) { sport in
                dialSegment(sport, progress: progress)
            }
            .frame(
                width: .launchDialSize,
                height: .launchDialSize
            )

            LazyVGrid(columns: columns, spacing: Margin.x3) {
                ForEach(LaunchSport.allCases, id: \.self) { sport in
                    Canvas { context, size in
                        sport.draw(in: context, size: size, elapsed: elapsed)
                    }
                    .frame(
                        width: .launchTileSize,
                        height: .launchTileSize
                    )
                    .background(
                        .primary.opacity(.launchTileOpacity),
                        in: RoundedRectangle(cornerRadius: .launchTileCornerRadius)
                    )
                }
            }
            .fixedSize()
        }
    }

    private func dialSegment(_ sport: LaunchSport, progress: Double) -> some View {
        let count = Double(LaunchSport.allCases.count)
        let lit = min(1, max(.zero, progress * count - Double(sport.rawValue)))

        return Circle()
            .trim(
                from: .zero,
                to: .launchSegmentFill / count
            )
            .stroke(
                Color.primary.opacity(.launchTrackOpacity),
                style: .launchTrackStroke
            )
            .overlay {
                Circle()
                    .trim(
                        from: .zero,
                        to: .launchSegmentFill / count * lit
                    )
                    .stroke(
                        .orange,
                        style: .launchTrackStroke
                    )
            }
            .rotationEffect(.degrees(.launchTrackStartAngle + .launchFullTurn * Double(sport.rawValue) / count))
    }
}

// MARK: - Constants

private extension CGFloat {
    static let launchGlowStartRadius: CGFloat = 40
    static let launchGlowEndRadius: CGFloat = 380
    static let launchDialSize: CGFloat = 286
    static let launchDialFaceSize: CGFloat = 272
    static let launchTileSize: CGFloat = 70
    static let launchTileCornerRadius: CGFloat = 14
}

private extension Double {
    static let launchDisplaySeconds = 1.45
    static let launchAttosecondsPerSecond = 1.0e18
    static let launchSegmentFill = 0.8
    static let launchTrackStartAngle = -90.0
    static let launchFullTurn = 360.0
    static let launchTrackOpacity = 0.12
    static let launchDialBorderOpacity = 0.10
    static let launchTileOpacity = 0.06
}

private extension Int {
    static let launchGridColumns = 3
}

private extension StrokeStyle {
    static let launchTrackStroke = StrokeStyle(
        lineWidth: 4,
        lineCap: .round
    )
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview {
    AppLaunchOverlayView()
}
#endif
