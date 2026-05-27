import Testing
@testable import GitCelebrate

struct RewardGeneratorTests {
    @Test
    func commitEventCreatesGenericReward() {
        let event = AppEvent.git(.commit, repo: .sample)
        let rules = EventRule.defaults(animationStyle: .arcade)

        let reward = RewardGenerator().reward(for: event, rules: rules)

        #expect(reward?.title.isEmpty == false)
        #expect(reward?.subtitle?.localizedStandardContains("GitCelebrate") == true)
        #expect(reward?.style == .arcade)
        #expect(reward?.intensity == 1)
    }

    @Test
    func mergeUsesConfettiByDefault() {
        let event = AppEvent.git(.merge, repo: .sample)
        let rules = EventRule.defaults(animationStyle: .minimal)

        let reward = RewardGenerator().reward(for: event, rules: rules)

        #expect(reward?.style == .confetti)
        #expect(reward?.intensity == 3)
    }

    @Test
    func missingRuleReturnsNil() {
        let event = AppEvent.git(.push, repo: .sample)
        let rules = [EventRule(trigger: .commit, animation: .minimal, intensity: 1)]

        let reward = RewardGenerator().reward(for: event, rules: rules)

        #expect(reward == nil)
    }
}
