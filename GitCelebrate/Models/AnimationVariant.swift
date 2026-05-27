enum AnimationVariant: String, CaseIterable, Codable, Sendable {
    case levelUp
    case fireworks
    case rocketLaunch
    case magicWand
    case crownFlash
    case confetti
    case commitGraph
    case coinShower
    case aurora
    case hyperspace

    var title: String {
        switch self {
        case .levelUp:
            "Level Up"
        case .fireworks:
            "Fireworks"
        case .rocketLaunch:
            "Rocket Launch"
        case .magicWand:
            "Magic Wand"
        case .crownFlash:
            "Crown Flash"
        case .confetti:
            "Confetti"
        case .commitGraph:
            "Commit Graph"
        case .coinShower:
            "Loot Drop"
        case .aurora:
            "Aurora"
        case .hyperspace:
            "Hyperspace"
        }
    }
}
