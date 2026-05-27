struct RewardGenerator: Sendable {
    private let scorer = RewardScorer()
    private let copyGenerator = CelebrationCopyGenerator()
    private let variantPicker = AnimationVariantPicker()

    func reward(for event: AppEvent, rules: [EventRule]) -> RewardEvent? {
        switch event.kind {
        case .git(let gitEvent):
            reward(for: gitEvent, rules: rules)
        }
    }

    private func reward(for event: GitEvent, rules: [EventRule]) -> RewardEvent? {
        guard let rule = rules.first(where: { $0.trigger == event.type }) else {
            return nil
        }

        let score = scorer.score(for: event, fallbackIntensity: rule.intensity)
        let copy = copyGenerator.copy(for: event, score: score)
        let variant = variantPicker.variant(for: event, score: score)
        let subtitle = [copy.subtitlePrefix, event.repo.name, event.metadata?.subject, score.summary]
            .compactMap(\.self)
            .joined(separator: " - ")

        return RewardEvent(
            title: copy.title,
            subtitle: subtitle.isEmpty ? event.repo.name : subtitle,
            style: rule.animation,
            intensity: score.intensity,
            mergeKey: "git:\(event.repo.path):\(event.type.rawValue)",
            score: score.points,
            animationVariant: variant
        )
    }
}
