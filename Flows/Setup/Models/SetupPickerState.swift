import Foundation

struct SetupPickerState: Codable, Equatable, Sendable {
    var isRoundsExpanded: Bool
    var isPreparationExpanded: Bool
    var isRoundDurationExpanded: Bool
    var isRestExpanded: Bool
    var isWarningExpanded: Bool

    static let defaultValue = SetupPickerState(
        isRoundsExpanded: true,
        isPreparationExpanded: true,
        isRoundDurationExpanded: true,
        isRestExpanded: true,
        isWarningExpanded: true
    )

    init(
        isRoundsExpanded: Bool,
        isPreparationExpanded: Bool,
        isRoundDurationExpanded: Bool,
        isRestExpanded: Bool,
        isWarningExpanded: Bool
    ) {
        self.isRoundsExpanded = isRoundsExpanded
        self.isPreparationExpanded = isPreparationExpanded
        self.isRoundDurationExpanded = isRoundDurationExpanded
        self.isRestExpanded = isRestExpanded
        self.isWarningExpanded = isWarningExpanded
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            isRoundsExpanded: try container.decodeIfPresent(Bool.self, forKey: .isRoundsExpanded) ?? true,
            isPreparationExpanded: try container.decodeIfPresent(Bool.self, forKey: .isPreparationExpanded) ?? true,
            isRoundDurationExpanded: try container.decodeIfPresent(Bool.self, forKey: .isRoundDurationExpanded) ?? true,
            isRestExpanded: try container.decodeIfPresent(Bool.self, forKey: .isRestExpanded) ?? true,
            isWarningExpanded: try container.decodeIfPresent(Bool.self, forKey: .isWarningExpanded) ?? true
        )
    }
}
