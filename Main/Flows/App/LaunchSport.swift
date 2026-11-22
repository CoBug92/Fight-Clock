import SwiftUI

// MARK: - LaunchSport

enum LaunchSport: Int, CaseIterable {
    case hiit
    case boxing
    case running
    case crossFit
    case rowing
    case cycling

    // MARK: - Properties

    private var rhythm: (period: Double, start: Double) {
        switch self {
        case .hiit: (0.68, 0.30)
        case .boxing: (0.72, 0.06)
        case .running: (0.54, 0.18)
        case .crossFit: (0.92, 0.12)
        case .rowing: (0.88, 0.10)
        case .cycling: (0.68, 0.24)
        }
    }

    // MARK: - Drawing

    func draw(in context: GraphicsContext, size: CGSize, elapsed: Double) {
        var context = context
        context.scaleBy(
            x: size.width / .launchArtSize,
            y: size.height / .launchArtSize
        )

        let drawing = FigureDrawing(context: context)
        let angle = 2 * Double.pi * (elapsed / rhythm.period + rhythm.start)
        switch self {
        case .hiit: drawJumpingJack(drawing, angle: angle)
        case .boxing: drawBoxer(drawing, angle: angle)
        case .running: drawRunner(drawing, angle: angle)
        case .crossFit: drawThruster(drawing, angle: angle)
        case .rowing: drawRower(drawing, angle: angle)
        case .cycling: drawCyclist(drawing, angle: angle)
        }
    }

    // MARK: - Poses

    private func drawJumpingJack(_ drawing: FigureDrawing, angle: Double) {
        let spread = rise(angle)
        let bounce = 3 * abs(sin(angle))
        let shoulder = CGPoint(32, 25 - bounce)
        let hip = CGPoint(32, 37 - bounce)

        for side: CGFloat in [-1, 1] {
            let elbow = CGPoint(32 + side * (7 + 9 * spread), 31 - 13 * spread - bounce)
            let hand = CGPoint(32 + side * (7 + 4 * sin(.pi * spread)), 40 - 32 * spread - bounce)
            let knee = CGPoint(32 + side * (3 + 7 * spread), 45 - bounce)
            let foot = CGPoint(32 + side * (4 + 14 * spread), 54 - bounce)
            drawing.line([shoulder, elbow, hand])
            drawing.line([hip, knee, foot])
        }
        drawing.line([shoulder, hip])
        drawing.head(CGPoint(32, 18 - bounce))
    }

    private func drawBoxer(_ drawing: FigureDrawing, angle: Double) {
        let nearPunch = pow(max(0, sin(angle)), 2)
        let farPunch = pow(max(0, -sin(angle)), 2)
        let shift = 4 * nearPunch + 2 * farPunch
        let shoulder = CGPoint(28 + shift, 25)
        let hip = CGPoint(25 + shift, 39)
        let farGlove = CGPoint(40 + 14 * farPunch, 22 - 2 * farPunch)
        let nearGlove = CGPoint(36 + 20 * nearPunch, 25 - 3 * nearPunch)

        drawing.line([hip, CGPoint(34, 45), CGPoint(43, 52), CGPoint(48, 52)], color: .rear)
        drawing.line([shoulder, CGPoint(34 + 7 * farPunch, 33 - 10 * farPunch), farGlove], color: .rear)
        drawing.dot(at: farGlove, radius: 3.2, color: .accent)
        drawing.line([hip, CGPoint(21 + shift, 46), CGPoint(14, 53), CGPoint(19, 53)])
        drawing.line([hip, shoulder])
        drawing.head(CGPoint(30 + shift, 17))
        drawing.line([shoulder, CGPoint(29 + 15 * nearPunch, 35 - 12 * nearPunch), nearGlove])
        drawing.dot(at: nearGlove, radius: 3.6, color: .accent)
    }

    private func drawRunner(_ drawing: FigureDrawing, angle: Double) {
        let bounce = 2 * abs(cos(angle))
        let shoulder = CGPoint(35, 24 - bounce)
        let hip = CGPoint(29, 37 - bounce)

        for side: Double in [-1, 1] {
            let stride = side * sin(angle)
            let lift = max(0, side * cos(angle))
            let color: FigureDrawing.Ink = side < 0 ? .rear : .figure
            let knee = CGPoint(29 + 12 * stride + 5 * lift, 45 - 5 * lift - bounce)
            let ankle = CGPoint(28 + 18 * stride - 6 * lift, 54 - 13 * lift - bounce)
            let elbow = CGPoint(33 - 12 * stride, 32 - 3 * stride - bounce)
            let hand = CGPoint(40 - 15 * stride, 27 - 4 * stride - bounce)

            drawing.line([hip, knee, ankle, CGPoint(ankle.x + 4, ankle.y)], color: color)
            drawing.line([shoulder, elbow, hand], color: color)
        }
        drawing.line([hip, shoulder])
        drawing.head(CGPoint(39, 17 - bounce))
    }

    private func drawThruster(_ drawing: FigureDrawing, angle: Double) {
        let squat = rise(angle)
        let press = max(0, 1 - 2 * squat)
        let hip = CGPoint(31 - 7 * squat, 34 + 9 * squat)
        let shoulder = CGPoint(32 + 2 * squat, 21 + 9 * squat)
        let barY = shoulder.y - 1 - 13 * press
        let leftGrip = CGPoint(shoulder.x - 9, barY)
        let rightGrip = CGPoint(shoulder.x + 9, barY)

        drawing.line([hip, CGPoint(35 + 7 * squat, 43 + 2 * squat), CGPoint(39, 54), CGPoint(44, 54)], color: .rear)
        drawing.line([hip, CGPoint(28 + 6 * squat, 43 + 3 * squat), CGPoint(23, 54), CGPoint(28, 54)])
        drawing.line([hip, shoulder])
        drawing.head(CGPoint(shoulder.x + 2, shoulder.y - 7))
        drawing.line([shoulder, CGPoint(shoulder.x - 10, shoulder.y + 6 - 14 * press), leftGrip])
        drawing.line([shoulder, CGPoint(shoulder.x + 10, shoulder.y + 6 - 14 * press), rightGrip])
        drawing.line([CGPoint(10, barY), CGPoint(55, barY)], color: .accent)
        drawing.line([CGPoint(14, barY - 3), CGPoint(14, barY + 3)], color: .accent, width: 4)
        drawing.line([CGPoint(51, barY - 3), CGPoint(51, barY + 3)], color: .accent, width: 4)
    }

    private func drawRower(_ drawing: FigureDrawing, angle: Double) {
        let drive = rise(angle)
        let pull = max(0, (drive - 0.45) / 0.55)
        let foot = CGPoint(17, 44)
        let hip = CGPoint(28 + 18 * drive, 41)
        let shoulder = CGPoint(23 + 25 * drive, 27)
        let knee = CGPoint(25 + 7 * drive, 30 + 12 * drive)
        let hand = CGPoint(12 + 25 * pull, 33)

        drawing.ring(at: CGPoint(10, 44), radius: 5, color: .accent)
        drawing.line([CGPoint(9, 49), CGPoint(57, 49)], color: .accent)
        drawing.line([CGPoint(12, 50), CGPoint(12, 54), CGPoint(7, 54)], color: .rear)
        drawing.line([CGPoint(54, 50), CGPoint(54, 54), CGPoint(59, 54)], color: .rear)
        drawing.line([CGPoint(13, 40), hand], color: .accent, width: 1.3)
        drawing.line([CGPoint(hip.x - 4, 46), CGPoint(hip.x + 4, 46)], color: .accent)
        drawing.line([hip, knee, foot, CGPoint(15, 41)])
        drawing.line([hip, shoulder])
        drawing.head(CGPoint(shoulder.x - 1, 19))
        drawing.line([shoulder, CGPoint(17 + 30 * drive, 31 + 7 * pull), hand])
    }

    private func drawCyclist(_ drawing: FigureDrawing, angle: Double) {
        let rearWheel = CGPoint(13, 45)
        let frontWheel = CGPoint(51, 45)
        let crank = CGPoint(31, 44)
        let saddle = CGPoint(24, 33)
        let fork = CGPoint(43, 31)
        let shoulder = CGPoint(36, 23)
        let bar = CGPoint(47, 29)

        for wheel in [rearWheel, frontWheel] {
            drawing.ring(at: wheel, radius: 9, color: .accent)
            let spoke = CGPoint(6 * cos(angle), 6 * sin(angle))
            drawing.line(
                [CGPoint(wheel.x - spoke.x, wheel.y - spoke.y), CGPoint(wheel.x + spoke.x, wheel.y + spoke.y)],
                color: .rear,
                width: 1.2
            )
        }

        drawing.line([rearWheel, saddle, crank, rearWheel], color: .accent, width: 2)
        drawing.line([saddle, fork, crank], color: .accent, width: 2)
        drawing.line([frontWheel, fork, bar], color: .accent, width: 2)

        for side: Double in [-1, 1] {
            let rotationX = side * cos(angle)
            let rotationY = side * sin(angle)
            let knee = CGPoint(35 + 5 * rotationX, 34 + 4 * rotationY)
            let pedal = CGPoint(crank.x + 5 * rotationX, crank.y + 5 * rotationY)
            drawing.line([saddle, knee, pedal, CGPoint(pedal.x + 3, pedal.y)], color: side < 0 ? .rear : .figure)
        }
        drawing.line([saddle, shoulder])
        drawing.head(CGPoint(42, 18))
        drawing.line([shoulder, CGPoint(40, 31), bar])
    }

    private func rise(_ angle: Double) -> Double {
        (1 - cos(angle)) / 2
    }
}

// MARK: - FigureDrawing

private struct FigureDrawing {
    enum Ink {
        case figure
        case rear
        case accent

        var shading: GraphicsContext.Shading {
            switch self {
            case .figure: .foreground
            case .rear: .color(.primary.opacity(0.50))
            case .accent: .color(.orange)
            }
        }
    }

    let context: GraphicsContext

    func line(_ points: [CGPoint], color: Ink = .figure, width: CGFloat = .launchArtStrokeWidth) {
        let path = Path { path in
            path.addLines(points)
        }
        context.stroke(
            path,
            with: color.shading,
            style: StrokeStyle(
                lineWidth: width,
                lineCap: .round,
                lineJoin: .round
            )
        )
    }

    func head(_ center: CGPoint) {
        dot(at: center, radius: .launchArtHeadRadius, color: .figure)
    }

    func dot(at center: CGPoint, radius: CGFloat, color: Ink) {
        context.fill(circle(at: center, radius: radius), with: color.shading)
    }

    func ring(at center: CGPoint, radius: CGFloat, color: Ink) {
        context.stroke(circle(at: center, radius: radius), with: color.shading, lineWidth: .launchArtEquipmentWidth)
    }

    private func circle(at center: CGPoint, radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: 2 * radius,
            height: 2 * radius
        ))
    }
}

// MARK: - Constants

private extension CGFloat {
    static let launchArtSize: CGFloat = 64
    static let launchArtStrokeWidth: CGFloat = 3
    static let launchArtHeadRadius: CGFloat = 4
    static let launchArtEquipmentWidth: CGFloat = 1.8
}

private extension CGPoint {
    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: x, y: y)
    }
}
