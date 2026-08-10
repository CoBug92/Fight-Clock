import Foundation

struct SessionBoundary: Equatable, Sendable {
    let date: Date
    let signal: SessionSignal
    let round: Int
}
