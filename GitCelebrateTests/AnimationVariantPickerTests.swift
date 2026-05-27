import Testing
@testable import GitCelebrate

struct AnimationVariantPickerTests {
    @Test
    func returnsDeterministicVariantForSameEvent() {
        let event = GitEvent(
            type: .commit,
            repo: .sample,
            metadata: GitCommitMetadata(subject: "Add variants", filesChanged: 1, insertions: 12, deletions: 1)
        )
        let score = RewardScore(points: 21, intensity: 1, summary: nil)
        let picker = AnimationVariantPicker()

        #expect(picker.variant(for: event, score: score) == picker.variant(for: event, score: score))
    }
}
