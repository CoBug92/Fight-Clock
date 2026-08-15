import Foundation

protocol SetupPickerStateRepository: Sendable {
    func load() -> SetupPickerState
    func save(_ state: SetupPickerState)
}
