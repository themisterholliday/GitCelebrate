import Foundation

struct AppStats: Codable, Equatable, Sendable {
    var totalCommits = 0
    var totalPushes = 0
    var repoTotals: [String: Int] = [:]
    var currentStreak = 0
    var lastCommitDay: String?

    mutating func record(_ event: AppEvent, calendar: Calendar = .current) -> RewardEvent? {
        guard case .git(let gitEvent) = event.kind else {
            return nil
        }

        repoTotals[gitEvent.repo.path, default: 0] += 1

        switch gitEvent.type {
        case .commit:
            totalCommits += 1
            updateStreak(on: event.date, calendar: calendar)
            return commitMilestoneReward(repoName: gitEvent.repo.name)
        case .push:
            totalPushes += 1
            return pushMilestoneReward(repoName: gitEvent.repo.name)
        case .merge, .rebase, .branch:
            return nil
        }
    }

    private mutating func updateStreak(on date: Date, calendar: Calendar) {
        let day = dayKey(for: date, calendar: calendar)

        guard lastCommitDay != day else {
            return
        }

        if let lastCommitDay, isYesterday(lastCommitDay, before: date, calendar: calendar) {
            currentStreak += 1
        } else {
            currentStreak = 1
        }

        lastCommitDay = day
    }

    private func commitMilestoneReward(repoName: String) -> RewardEvent? {
        guard totalCommits > 0, totalCommits.isMultiple(of: 10) else {
            return nil
        }

        return RewardEvent(
            title: "\(totalCommits) Commits",
            subtitle: repoName,
            style: .loot,
            intensity: 3,
            mergeKey: "stats:commits:\(totalCommits)",
            score: nil,
            animationVariant: .crownFlash
        )
    }

    private func pushMilestoneReward(repoName: String) -> RewardEvent? {
        guard totalPushes > 0, totalPushes.isMultiple(of: 5) else {
            return nil
        }

        return RewardEvent(
            title: "\(totalPushes) Pushes",
            subtitle: repoName,
            style: .confetti,
            intensity: 3,
            mergeKey: "stats:pushes:\(totalPushes)",
            score: nil,
            animationVariant: .fireworks
        )
    }

    private func isYesterday(_ day: String, before date: Date, calendar: Calendar) -> Bool {
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: date) else {
            return false
        }

        return day == dayKey(for: yesterday, calendar: calendar)
    }

    private func dayKey(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }
}
