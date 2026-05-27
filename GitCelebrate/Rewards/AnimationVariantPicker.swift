struct AnimationVariantPicker: Sendable {
    func variant(for event: GitEvent, score: RewardScore) -> AnimationVariant {
        let variants = variants(for: event.type, score: score)
        let seed = "\(event.repo.path):\(event.type.rawValue):\(event.metadata?.subject ?? ""):\(score.points):variant"
        return variants[abs(seed.hashValue) % variants.count]
    }

    private func variants(for type: GitEventType, score: RewardScore) -> [AnimationVariant] {
        switch type {
        case .commit:
            score.points >= 220
                ? [.levelUp, .fireworks, .rocketLaunch, .crownFlash, .coinShower, .commitGraph]
                : [.confetti, .levelUp, .magicWand, .rocketLaunch, .commitGraph]
        case .push:
            [.rocketLaunch, .hyperspace, .confetti, .fireworks]
        case .merge:
            [.fireworks, .magicWand, .crownFlash, .commitGraph]
        case .rebase:
            [.magicWand, .levelUp, .aurora]
        case .branch:
            [.confetti, .rocketLaunch, .aurora, .commitGraph]
        }
    }
}
