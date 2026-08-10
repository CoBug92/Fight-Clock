import Foundation

struct SystemDateProvider: DateProviding {
    func now() -> Date { Date() }
}
