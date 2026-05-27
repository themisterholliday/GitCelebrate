import Foundation

struct OverlayScene: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var subtitle: String?
    var animationStyle: AnimationStyle
    var animationVariant: AnimationVariant
    var duration: Duration
    var priority: Int
    var count: Int
    var mergeKey: String

    var displayTitle: String {
        count > 1 ? "\(count)x \(title)" : title
    }

    static func test(style: AnimationStyle) -> OverlayScene {
        OverlayScene(
            title: "Commit Complete",
            subtitle: "GitCelebrate is running",
            animationStyle: style,
            animationVariant: .confetti,
            duration: .seconds(2),
            priority: 0,
            count: 1,
            mergeKey: "test-overlay"
        )
    }
}
