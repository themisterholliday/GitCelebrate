enum AnimationStyle: String, CaseIterable, Codable, Identifiable, Sendable {
    case minimal
    case arcade
    case confetti
    case loot

    var id: Self { self }

    var title: String {
        switch self {
        case .minimal:
            "Minimal"
        case .arcade:
            "Arcade"
        case .confetti:
            "Confetti"
        case .loot:
            "Loot"
        }
    }
}
