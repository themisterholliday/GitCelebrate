import Observation

@MainActor
@Observable
final class StatsTracker {
    private let store = StatsStore()
    private(set) var stats: AppStats

    init() {
        stats = store.load()
    }

    func record(_ event: AppEvent) -> RewardEvent? {
        let reward = stats.record(event)
        store.save(stats)
        return reward
    }
}
