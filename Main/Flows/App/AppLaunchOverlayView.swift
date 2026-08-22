import SwiftUI

struct AppLaunchOverlayView: View {
    // MARK: - Observable properties

    @State private var isAnimating = false

    // MARK: - Layout

    var body: some View {
        ZStack {
            background
            animatedContent
        }
        .onAppear {
            guard !isAnimating else { return }
            isAnimating = true
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

            LinearGradient(
                colors: [
                    .clear,
                    Color.orange.opacity(isAnimating ? .launchGlowActiveOpacity : .launchGlowInactiveOpacity),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .rotationEffect(.degrees(isAnimating ? .launchGlowActiveAngle : -.launchGlowActiveAngle))
            .scaleEffect(isAnimating ? .launchGlowActiveScale : .launchGlowInactiveScale)
            .animation(
                .easeInOut(duration: .launchGlowAnimationDuration).repeatForever(autoreverses: true),
                value: isAnimating
            )
        }
        .ignoresSafeArea()
    }

    private var animatedContent: some View {
        ZStack {
            ring(
                size: .launchInnerRingSize,
                opacity: .launchInnerRingOpacity,
                lineWidth: .launchInnerRingLineWidth,
                delay: .zero
            )
            ring(
                size: .launchMiddleRingSize,
                opacity: .launchMiddleRingOpacity,
                lineWidth: .launchMiddleRingLineWidth,
                delay: .launchMiddleRingDelay
            )
            ring(
                size: .launchOuterRingSize,
                opacity: .launchOuterRingOpacity,
                lineWidth: .launchOuterRingLineWidth,
                delay: .launchOuterRingDelay
            )
            badge
        }
    }

    private var badge: some View {
        ZStack {
            Circle()
                .fill(Color.orange.opacity(.launchBadgeGlowOpacity))
                .frame(
                    width: .launchBadgeGlowSize,
                    height: .launchBadgeGlowSize
                )
                .blur(radius: isAnimating ? .launchBadgeActiveBlurRadius : .launchBadgeInactiveBlurRadius)
                .scaleEffect(isAnimating ? 1 : .launchBadgeInactiveScale)
                .animation(
                    .easeInOut(duration: .launchBadgeGlowAnimationDuration).repeatForever(autoreverses: true),
                    value: isAnimating
                )

            Circle()
                .fill(.ultraThinMaterial)
                .overlay {
                    Circle()
                        .stroke(
                            Color.orange.opacity(.launchBadgeStrokeOpacity),
                            lineWidth: .launchBadgeStrokeWidth
                        )
                }
                .frame(
                    width: .launchBadgeSize,
                    height: .launchBadgeSize
                )
                .shadow(
                    color: .black.opacity(.launchBadgeShadowOpacity),
                    radius: .launchBadgeShadowRadius,
                    y: .launchBadgeShadowOffsetY
                )

            Image(systemName: SFSymbol.figureBoxing)
                .font(
                    .system(
                        size: .launchIconSize,
                        weight: .black
                    )
                )
                .foregroundStyle(.primary)
                .rotationEffect(.degrees(isAnimating ? .launchIconActiveAngle : -.launchIconActiveAngle))
                .scaleEffect(isAnimating ? 1 : .launchIconInactiveScale)
                .animation(
                    .easeInOut(duration: .launchIconAnimationDuration).repeatForever(autoreverses: true),
                    value: isAnimating
                )

            Circle()
                .trim(
                    from: .launchArcStart,
                    to: .launchArcEnd
                )
                .stroke(
                    Color.orange,
                    style: StrokeStyle(
                        lineWidth: .launchArcLineWidth,
                        lineCap: .round
                    )
                )
                .frame(
                    width: .launchArcSize,
                    height: .launchArcSize
                )
                .rotationEffect(.degrees(isAnimating ? .launchArcActiveAngle : .zero))
                .animation(
                    .linear(duration: .launchArcAnimationDuration).repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
        .accessibilityHidden(true)
    }

    private func ring(size: CGFloat, opacity: Double, lineWidth: CGFloat, delay: Double) -> some View {
        Circle()
            .stroke(
                Color.orange.opacity(opacity),
                lineWidth: lineWidth
            )
            .frame(
                width: size,
                height: size
            )
            .scaleEffect(isAnimating ? .launchRingActiveScale : 1)
            .opacity(isAnimating ? .launchRingActiveOpacity : .launchRingInactiveOpacity)
            .animation(
                .easeOut(duration: .launchRingAnimationDuration)
                    .repeatForever(autoreverses: false)
                    .delay(delay),
                value: isAnimating
            )
    }
}

// MARK: - Constants

private extension CGFloat {
    static let launchGlowStartRadius: CGFloat = 40
    static let launchGlowEndRadius: CGFloat = 380
    static let launchInnerRingSize: CGFloat = 156
    static let launchInnerRingLineWidth: CGFloat = 2
    static let launchMiddleRingSize: CGFloat = 220
    static let launchMiddleRingLineWidth: CGFloat = 1.5
    static let launchOuterRingSize: CGFloat = 292
    static let launchOuterRingLineWidth: CGFloat = 1
    static let launchBadgeGlowSize: CGFloat = 138
    static let launchBadgeActiveBlurRadius: CGFloat = 6
    static let launchBadgeInactiveBlurRadius: CGFloat = 14
    static let launchBadgeSize: CGFloat = 112
    static let launchBadgeStrokeWidth: CGFloat = 1
    static let launchBadgeShadowRadius: CGFloat = 22
    static let launchBadgeShadowOffsetY: CGFloat = 8
    static let launchIconSize: CGFloat = 38
    static let launchArcLineWidth: CGFloat = 3
    static let launchArcSize: CGFloat = 126
    static let launchGlowActiveScale: CGFloat = 1.08
    static let launchGlowInactiveScale: CGFloat = 0.92
    static let launchBadgeInactiveScale: CGFloat = 0.9
    static let launchIconInactiveScale: CGFloat = 0.9
    static let launchRingActiveScale: CGFloat = 2
    static let launchArcStart: CGFloat = 0.1
    static let launchArcEnd: CGFloat = 0.3
}

private extension Double {
    static let launchGlowActiveOpacity = 0.12
    static let launchGlowInactiveOpacity = 0.04
    static let launchGlowActiveAngle = 8.0
    static let launchGlowAnimationDuration = 1.8
    static let launchInnerRingOpacity = 0.22
    static let launchMiddleRingOpacity = 0.16
    static let launchMiddleRingDelay = 0.18
    static let launchOuterRingOpacity = 0.10
    static let launchOuterRingDelay = 0.34
    static let launchBadgeGlowOpacity = 0.14
    static let launchBadgeGlowAnimationDuration = 1.0
    static let launchBadgeStrokeOpacity = 0.3
    static let launchBadgeShadowOpacity = 0.1
    static let launchIconActiveAngle = 3.0
    static let launchIconAnimationDuration = 0.9
    static let launchArcActiveAngle = 360.0
    static let launchArcAnimationDuration = 2.0
    static let launchRingActiveOpacity = 0.3
    static let launchRingInactiveOpacity = 0.9
    static let launchRingAnimationDuration = 1.0
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview {
    AppLaunchOverlayView()
}
#endif
