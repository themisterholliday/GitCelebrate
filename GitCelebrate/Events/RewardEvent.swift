import Foundation

struct RewardEvent: Equatable, Sendable {
    var title: String
    var subtitle: String?
    var style: AnimationStyle
    var intensity: Int
    var mergeKey: String
    var score: Int?
    var animationVariant: AnimationVariant

    func overlayScene() -> OverlayScene {
        OverlayScene(
            title: title,
            subtitle: subtitle,
            animationStyle: style,
            animationVariant: animationVariant,
            duration: .seconds(durationSeconds),
            priority: priority,
            count: 1,
            mergeKey: mergeKey
        )
    }

    private var durationSeconds: Int64 {
        switch intensity {
        case 4...:
            6
        case 3...:
            5
        case 2:
            4
        default:
            4
        }
    }

    private var priority: Int {
        -intensity
    }
}
