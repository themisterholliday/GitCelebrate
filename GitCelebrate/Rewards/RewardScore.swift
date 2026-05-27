struct RewardScore: Equatable, Sendable {
    var points: Int
    var intensity: Int
    var summary: String?
}

struct RewardScorer: Sendable {
    func score(for event: GitEvent, fallbackIntensity: Int) -> RewardScore {
        guard let metadata = event.metadata else {
            return RewardScore(points: fallbackIntensity * 10, intensity: fallbackIntensity, summary: nil)
        }

        let churnPoints = min(metadata.churn, 300)
        let filePoints = min(metadata.filesChanged * 8, 80)
        let deletionBonus = min(metadata.deletions / 2, 40)
        let points = max(1, churnPoints + filePoints + deletionBonus)
        let intensity = intensity(for: points, fallback: fallbackIntensity)

        return RewardScore(points: points, intensity: intensity, summary: summary(for: metadata, points: points))
    }

    private func intensity(for points: Int, fallback: Int) -> Int {
        switch points {
        case 220...:
            4
        case 90...:
            3
        case 25...:
            2
        default:
            fallback
        }
    }

    private func summary(for metadata: GitCommitMetadata, points: Int) -> String {
        let net = metadata.netLines >= 0 ? "+\(metadata.netLines)" : "\(metadata.netLines)"
        return "\(points) pts | +\(metadata.insertions) -\(metadata.deletions) | \(net) net | \(metadata.churn) churn | \(metadata.filesChanged) files"
    }
}
