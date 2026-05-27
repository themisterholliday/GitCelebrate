import Testing
@testable import GitCelebrate

struct CelebrationCopyGeneratorTests {
    @Test
    func returnsDeterministicCopyForSameEvent() {
        let event = GitEvent(
            type: .commit,
            repo: .sample,
            metadata: GitCommitMetadata(subject: "Add scoring", filesChanged: 2, insertions: 20, deletions: 5)
        )
        let score = RewardScore(points: 41, intensity: 2, summary: nil)
        let generator = CelebrationCopyGenerator()

        #expect(generator.copy(for: event, score: score) == generator.copy(for: event, score: score))
    }

    @Test
    func highScoreUsesBigCommitCopyBank() {
        let event = GitEvent(
            type: .commit,
            repo: .sample,
            metadata: GitCommitMetadata(subject: "Rewrite engine", filesChanged: 20, insertions: 300, deletions: 80)
        )
        let copy = CelebrationCopyGenerator().copy(
            for: event,
            score: RewardScore(points: 250, intensity: 4, summary: nil)
        )

        #expect([
            "Legendary Commit",
            "Code Meteor",
            "Massive Ship",
            "Boss Fight Won",
            "Diff Titan",
            "Architecture Shift",
            "Main Quest Cleared",
            "Mountain Moved",
            "Codequake",
            "Ship Cannon"
        ].contains(copy.title))
    }
}
