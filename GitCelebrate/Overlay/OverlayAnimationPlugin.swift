import SwiftUI

protocol OverlayAnimationPlugin {
    var style: AnimationStyle { get }
    func presentation(for scene: OverlayScene) -> OverlayAnimationPresentation
}

struct OverlayAnimationPresentation {
    var symbolName: String
    var accent: Color
    var secondaryAccent: Color
    var material: Material
    var showsParticles: Bool
    var usesImpactMotion: Bool
    var symbolEffect: OverlaySymbolEffect
    var showsRings: Bool
    var showsOrbit: Bool
    var showsFireworks: Bool
    var backgroundEffect: OverlayBackgroundEffect

    static let minimal = OverlayAnimationPresentation(
        symbolName: "sparkles",
        accent: .primary,
        secondaryAccent: .secondary,
        material: .regularMaterial,
        showsParticles: false,
        usesImpactMotion: false,
        symbolEffect: .pulse,
        showsRings: true,
        showsOrbit: false,
        showsFireworks: false,
        backgroundEffect: .confettiCannon
    )
}

enum OverlaySymbolEffect {
    case pulse
    case variableColor
    case scale
    case bounce
    case breathe
}

enum OverlayBackgroundEffect {
    case confettiCannon
    case fireworks
    case orbitalRings
    case rocketLaunch
    case levelUpArrows
    case crownShine
    case commitGraph
    case coinShower
    case auroraRibbon
    case hyperspace
}

struct OverlayAnimationRegistry {
    private let plugins: [AnimationStyle: any OverlayAnimationPlugin]

    init(plugins: [any OverlayAnimationPlugin] = [
        MinimalOverlayAnimationPlugin(),
        ArcadeOverlayAnimationPlugin(),
        ConfettiOverlayAnimationPlugin(),
        LootOverlayAnimationPlugin()
    ]) {
        self.plugins = Dictionary(uniqueKeysWithValues: plugins.map { ($0.style, $0) })
    }

    func presentation(for scene: OverlayScene) -> OverlayAnimationPresentation {
        var presentation = plugins[scene.animationStyle]?.presentation(for: scene) ?? .minimal
        presentation.apply(scene.animationVariant)
        return presentation
    }
}

private extension OverlayAnimationPresentation {
    mutating func apply(_ variant: AnimationVariant) {
        switch variant {
        case .levelUp:
            symbolName = "arrow.up.circle.fill"
            accent = .green
            showsParticles = true
            symbolEffect = .scale
            showsRings = true
            backgroundEffect = .levelUpArrows
        case .fireworks:
            symbolName = "party.popper.fill"
            showsParticles = true
            symbolEffect = .bounce
            showsFireworks = true
            backgroundEffect = .fireworks
        case .rocketLaunch:
            symbolName = "paperplane.fill"
            accent = .cyan
            secondaryAccent = .blue
            usesImpactMotion = true
            symbolEffect = .scale
            showsOrbit = true
            backgroundEffect = .rocketLaunch
        case .magicWand:
            symbolName = "wand.and.stars"
            accent = .purple
            secondaryAccent = .pink
            showsParticles = true
            symbolEffect = .variableColor
            showsOrbit = true
            backgroundEffect = .orbitalRings
        case .crownFlash:
            symbolName = "crown.fill"
            accent = .yellow
            secondaryAccent = .purple
            showsParticles = true
            symbolEffect = .breathe
            showsFireworks = true
            backgroundEffect = .crownShine
        case .confetti:
            symbolName = "party.popper.fill"
            accent = .pink
            secondaryAccent = .yellow
            usesImpactMotion = true
            symbolEffect = .variableColor
            showsFireworks = true
            backgroundEffect = .confettiCannon
        case .commitGraph:
            symbolName = "point.3.connected.trianglepath.dotted"
            accent = .green
            secondaryAccent = .mint
            showsParticles = true
            symbolEffect = .scale
            backgroundEffect = .commitGraph
        case .coinShower:
            symbolName = "dollarsign.circle.fill"
            accent = .orange
            secondaryAccent = .yellow
            showsParticles = true
            symbolEffect = .bounce
            backgroundEffect = .coinShower
        case .aurora:
            symbolName = "sparkles"
            accent = .teal
            secondaryAccent = .purple
            showsParticles = true
            symbolEffect = .breathe
            backgroundEffect = .auroraRibbon
        case .hyperspace:
            symbolName = "sparkles"
            accent = .cyan
            secondaryAccent = .blue
            usesImpactMotion = true
            symbolEffect = .scale
            backgroundEffect = .hyperspace
        }
    }
}

struct MinimalOverlayAnimationPlugin: OverlayAnimationPlugin {
    let style = AnimationStyle.minimal

    func presentation(for scene: OverlayScene) -> OverlayAnimationPresentation {
        .minimal
    }
}

struct ArcadeOverlayAnimationPlugin: OverlayAnimationPlugin {
    let style = AnimationStyle.arcade

    func presentation(for scene: OverlayScene) -> OverlayAnimationPresentation {
        OverlayAnimationPresentation(
            symbolName: "bolt.fill",
            accent: .cyan,
            secondaryAccent: .mint,
            material: .ultraThickMaterial,
            showsParticles: false,
            usesImpactMotion: true,
            symbolEffect: .pulse,
            showsRings: true,
            showsOrbit: false,
            showsFireworks: false,
            backgroundEffect: .confettiCannon
        )
    }
}

struct ConfettiOverlayAnimationPlugin: OverlayAnimationPlugin {
    let style = AnimationStyle.confetti

    func presentation(for scene: OverlayScene) -> OverlayAnimationPresentation {
        OverlayAnimationPresentation(
            symbolName: "party.popper.fill",
            accent: .pink,
            secondaryAccent: .yellow,
            material: .regularMaterial,
            showsParticles: true,
            usesImpactMotion: true,
            symbolEffect: .variableColor,
            showsRings: false,
            showsOrbit: true,
            showsFireworks: true,
            backgroundEffect: .confettiCannon
        )
    }
}

struct LootOverlayAnimationPlugin: OverlayAnimationPlugin {
    let style = AnimationStyle.loot

    func presentation(for scene: OverlayScene) -> OverlayAnimationPresentation {
        OverlayAnimationPresentation(
            symbolName: "diamond.fill",
            accent: .orange,
            secondaryAccent: .purple,
            material: .thickMaterial,
            showsParticles: true,
            usesImpactMotion: true,
            symbolEffect: .breathe,
            showsRings: true,
            showsOrbit: true,
            showsFireworks: false,
            backgroundEffect: .confettiCannon
        )
    }
}
