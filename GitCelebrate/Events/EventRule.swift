struct EventRule: Equatable, Sendable {
    var trigger: GitEventType
    var animation: AnimationStyle
    var intensity: Int

    static func defaults(animationStyle: AnimationStyle) -> [EventRule] {
        [
            EventRule(trigger: .commit, animation: animationStyle, intensity: 1),
            EventRule(trigger: .push, animation: animationStyle, intensity: 2),
            EventRule(trigger: .merge, animation: .confetti, intensity: 3),
            EventRule(trigger: .rebase, animation: .minimal, intensity: 2),
            EventRule(trigger: .branch, animation: .minimal, intensity: 1)
        ]
    }
}
