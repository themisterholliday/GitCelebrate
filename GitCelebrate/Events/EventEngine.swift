import Foundation
import Observation

@MainActor
@Observable
final class EventEngine {
    private let overlayManager: OverlayManager
    private let rewardGenerator = RewardGenerator()

    init(overlayManager: OverlayManager) {
        self.overlayManager = overlayManager
    }

    @discardableResult
    func handle(_ event: AppEvent, animationStyle: AnimationStyle) -> RewardEvent? {
        let rules = EventRule.defaults(animationStyle: animationStyle)

        guard let reward = rewardGenerator.reward(for: event, rules: rules) else {
            return nil
        }

        overlayManager.enqueue(reward.overlayScene())
        return reward
    }

    func testGitEvent(_ type: GitEventType, animationStyle: AnimationStyle) {
        handle(.git(type, repo: .sample, metadata: .sample(subject: "Test overlay pipeline")), animationStyle: animationStyle)
    }

    func cancelAllAnimations() {
        overlayManager.cancelAll()
    }

    func testAnimationVariant(_ variant: AnimationVariant, animationStyle: AnimationStyle) {
        let sample = Self.debugCommit(for: variant)
        let event = GitEvent(type: .commit, repo: sample.repo, metadata: sample.metadata)
        let score = RewardScorer().score(for: event, fallbackIntensity: 3)
        let copy = CelebrationCopyGenerator().copy(for: event, score: score)

        // Mirror RewardGenerator's subtitle layout so the debug overlay previews
        // the same repo / commit subject / score detail a real commit would show.
        let subtitle = [copy.subtitlePrefix, event.repo.name, sample.metadata.subject, score.summary]
            .compactMap(\.self)
            .joined(separator: " - ")

        let scene = OverlayScene(
            title: variant.title,
            subtitle: subtitle,
            animationStyle: animationStyle,
            animationVariant: variant,
            duration: .seconds(5),
            priority: -10,
            count: 1,
            mergeKey: "debug-\(variant.rawValue)-\(UUID().uuidString)"
        )
        overlayManager.enqueue(scene)
    }

    /// Representative commit detail per variant so each debug overlay previews a
    /// distinct, realistic score / file / line breakdown.
    private static func debugCommit(for variant: AnimationVariant) -> (repo: GitRepositoryContext, metadata: GitCommitMetadata) {
        switch variant {
        case .levelUp:
            (GitRepositoryContext(name: "Arcade", path: "/Users/dev/Arcade"),
             GitCommitMetadata(subject: "Optimize frame scheduler", filesChanged: 6, insertions: 184, deletions: 42))
        case .fireworks:
            (GitRepositoryContext(name: "Checkout", path: "/Users/dev/Checkout"),
             GitCommitMetadata(subject: "Ship release 2.4.0", filesChanged: 12, insertions: 326, deletions: 95))
        case .rocketLaunch:
            (GitRepositoryContext(name: "Payments", path: "/Users/dev/Payments"),
             GitCommitMetadata(subject: "Launch payments service", filesChanged: 8, insertions: 240, deletions: 31))
        case .magicWand:
            (GitRepositoryContext(name: "AuthKit", path: "/Users/dev/AuthKit"),
             GitCommitMetadata(subject: "Refactor auth module", filesChanged: 5, insertions: 96, deletions: 88))
        case .crownFlash:
            (GitRepositoryContext(name: "Platform", path: "/Users/dev/Platform"),
             GitCommitMetadata(subject: "Merge feature/checkout-revamp", filesChanged: 18, insertions: 540, deletions: 120))
        case .confetti:
            (GitRepositoryContext(name: "GitCelebrate", path: "/Users/dev/GitCelebrate"),
             GitCommitMetadata(subject: "Fix flaky overlay test", filesChanged: 2, insertions: 14, deletions: 6))
        case .commitGraph:
            (GitRepositoryContext(name: "Graphene", path: "/Users/dev/Graphene"),
             GitCommitMetadata(subject: "Wire commit graph view", filesChanged: 4, insertions: 132, deletions: 18))
        case .coinShower:
            (GitRepositoryContext(name: "Treasury", path: "/Users/dev/Treasury"),
             GitCommitMetadata(subject: "Add rewards ledger", filesChanged: 9, insertions: 264, deletions: 22))
        case .aurora:
            (GitRepositoryContext(name: "Northern", path: "/Users/dev/Northern"),
             GitCommitMetadata(subject: "Rebase onto main", filesChanged: 3, insertions: 40, deletions: 40))
        case .hyperspace:
            (GitRepositoryContext(name: "Voyager", path: "/Users/dev/Voyager"),
             GitCommitMetadata(subject: "Push release branch", filesChanged: 7, insertions: 198, deletions: 27))
        }
    }

    func testAllAnimationVariants(animationStyle: AnimationStyle) {
        for (index, variant) in AnimationVariant.allCases.enumerated() {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(index * 700))
                testAnimationVariant(variant, animationStyle: animationStyle)
            }
        }
    }

    func testManyMessages(animationStyle: AnimationStyle) {
        let samples: [(GitEventType, GitCommitMetadata)] = [
            (.commit, .sample(subject: "Add reward score overlays", filesChanged: 3, insertions: 42, deletions: 8)),
            (.commit, .sample(subject: "Refactor event engine routing", filesChanged: 7, insertions: 94, deletions: 31)),
            (.commit, .sample(subject: "Delete stale menu state", filesChanged: 2, insertions: 4, deletions: 66)),
            (.push, .sample(subject: "Push branch for review", filesChanged: 5, insertions: 120, deletions: 12)),
            (.merge, .sample(subject: "Merge animation variants", filesChanged: 9, insertions: 210, deletions: 44)),
            (.commit, .sample(subject: "Fix tiny settings spacing", filesChanged: 1, insertions: 6, deletions: 2)),
            (.rebase, .sample(subject: "Rebase onto main", filesChanged: 4, insertions: 18, deletions: 18)),
            (.branch, .sample(subject: "Switch to overlay polish", filesChanged: 1, insertions: 1, deletions: 0))
        ]

        for (index, sample) in samples.enumerated() {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(index * 350))
                let repo = GitRepositoryContext(
                    name: "SampleRepo\(index + 1)",
                    path: "/tmp/gitcelebrate/sample-\(index + 1)"
                )
                handle(.git(sample.0, repo: repo, metadata: sample.1), animationStyle: animationStyle)
            }
        }
    }
}

private extension GitCommitMetadata {
    static func sample(
        subject: String,
        filesChanged: Int = 2,
        insertions: Int = 24,
        deletions: Int = 5
    ) -> GitCommitMetadata {
        GitCommitMetadata(
            subject: subject,
            filesChanged: filesChanged,
            insertions: insertions,
            deletions: deletions
        )
    }
}
