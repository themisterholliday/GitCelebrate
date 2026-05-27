import Testing
@testable import GitCelebrate

struct RewardScorerTests {
    @Test
    func scoresCommitFromLineStats() {
        let event = GitEvent(
            type: .commit,
            repo: .sample,
            metadata: GitCommitMetadata(subject: "Add rewards", filesChanged: 3, insertions: 40, deletions: 10)
        )

        let score = RewardScorer().score(for: event, fallbackIntensity: 1)

        #expect(score.points == 79)
        #expect(score.intensity == 2)
        #expect(score.summary == "79 pts | +40 -10 | +30 net | 50 churn | 3 files")
    }
}
