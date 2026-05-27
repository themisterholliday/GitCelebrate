import Foundation
import Testing
@testable import GitCelebrate

struct AppStatsTests {
    @Test
    func recordsCommitMilestone() {
        var stats = AppStats()

        for index in 1...10 {
            let event = AppEvent.git(
                .commit,
                repo: GitRepositoryContext(name: "SampleApp", path: "/tmp/sampleapp-\(index)")
            )
            _ = stats.record(event)
        }

        let reward = stats.record(
            .git(.commit, repo: GitRepositoryContext(name: "SampleApp", path: "/tmp/sampleapp"))
        )

        #expect(stats.totalCommits == 11)
        #expect(reward == nil)
    }

    @Test
    func tenthCommitReturnsMilestoneReward() {
        var stats = AppStats()
        var reward: RewardEvent?

        for _ in 1...10 {
            reward = stats.record(.git(.commit, repo: GitRepositoryContext(name: "SampleApp", path: "/tmp/sampleapp")))
        }

        #expect(reward?.title == "10 Commits")
        #expect(reward?.style == .loot)
    }
}
