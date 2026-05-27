struct CelebrationCopy: Equatable, Sendable {
    var title: String
    var subtitlePrefix: String?
}

struct CelebrationCopyGenerator: Sendable {
    func copy(for event: GitEvent, score: RewardScore) -> CelebrationCopy {
        let seed = "\(event.repo.path):\(event.type.rawValue):\(event.metadata?.subject ?? ""):\(score.points)"

        switch event.type {
        case .commit:
            return pick(commitCopies(for: score), seed: seed)
        case .push:
            return pick(pushCopies, seed: seed)
        case .merge:
            return pick(mergeCopies, seed: seed)
        case .rebase:
            return pick(rebaseCopies, seed: seed)
        case .branch:
            return pick(branchCopies, seed: seed)
        }
    }

    private func commitCopies(for score: RewardScore) -> [CelebrationCopy] {
        if score.points >= 220 {
            return [
                CelebrationCopy(title: "Legendary Commit", subtitlePrefix: "Big swing"),
                CelebrationCopy(title: "Code Meteor", subtitlePrefix: "Impact detected"),
                CelebrationCopy(title: "Massive Ship", subtitlePrefix: "The diff has weight"),
                CelebrationCopy(title: "Boss Fight Won", subtitlePrefix: "That was a chunk"),
                CelebrationCopy(title: "Diff Titan", subtitlePrefix: "Heavy lift"),
                CelebrationCopy(title: "Architecture Shift", subtitlePrefix: "Foundations moved"),
                CelebrationCopy(title: "Main Quest Cleared", subtitlePrefix: "Huge progress"),
                CelebrationCopy(title: "Mountain Moved", subtitlePrefix: "Serious lift"),
                CelebrationCopy(title: "Codequake", subtitlePrefix: "Massive change"),
                CelebrationCopy(title: "Ship Cannon", subtitlePrefix: "Major payload")
            ]
        }

        if score.points >= 90 {
            return [
                CelebrationCopy(title: "Chunky Commit", subtitlePrefix: "Solid work"),
                CelebrationCopy(title: "Diff Feast", subtitlePrefix: "Fresh code served"),
                CelebrationCopy(title: "Feature Fuel", subtitlePrefix: "Momentum up"),
                CelebrationCopy(title: "Big Save", subtitlePrefix: "Progress locked"),
                CelebrationCopy(title: "Code Combo", subtitlePrefix: "Streak energy"),
                CelebrationCopy(title: "Refactor Rumble", subtitlePrefix: "Clean moves"),
                CelebrationCopy(title: "Quest Progress", subtitlePrefix: "Objective advanced"),
                CelebrationCopy(title: "Diff Dash", subtitlePrefix: "Good pace"),
                CelebrationCopy(title: "Nice Slice", subtitlePrefix: "Clean chunk"),
                CelebrationCopy(title: "Momentum Burst", subtitlePrefix: "Flow state")
            ]
        }

        return [
            CelebrationCopy(title: "Commit Spark", subtitlePrefix: "Nice move"),
            CelebrationCopy(title: "Tiny Victory", subtitlePrefix: "Progress counts"),
            CelebrationCopy(title: "Code Nudge", subtitlePrefix: "Forward motion"),
            CelebrationCopy(title: "Diff Delivered", subtitlePrefix: "Clean little win"),
            CelebrationCopy(title: "Shiplet Launched", subtitlePrefix: "Small but real"),
            CelebrationCopy(title: "Checkpoint Saved", subtitlePrefix: "Work banked"),
            CelebrationCopy(title: "Syntax Snack", subtitlePrefix: "Tasty progress"),
            CelebrationCopy(title: "Clean Click", subtitlePrefix: "That landed"),
            CelebrationCopy(title: "Micro Ship", subtitlePrefix: "Tiny launch"),
            CelebrationCopy(title: "Code Pebble", subtitlePrefix: "Small win"),
            CelebrationCopy(title: "Patch Pop", subtitlePrefix: "Quick hit"),
            CelebrationCopy(title: "Green Tick Energy", subtitlePrefix: "Looks good")
        ]
    }

    private let pushCopies = [
        CelebrationCopy(title: "Pushed to Orbit", subtitlePrefix: "Remote updated"),
        CelebrationCopy(title: "Code Launched", subtitlePrefix: "Away it goes"),
        CelebrationCopy(title: "Branch Broadcast", subtitlePrefix: "Signal sent"),
        CelebrationCopy(title: "Upload Victory", subtitlePrefix: "Shared with the world"),
        CelebrationCopy(title: "Remote Powered", subtitlePrefix: "Cloud copy online"),
        CelebrationCopy(title: "Payload Sent", subtitlePrefix: "Branch in flight"),
        CelebrationCopy(title: "Signal Boost", subtitlePrefix: "Remote heard you"),
        CelebrationCopy(title: "Upstream Spark", subtitlePrefix: "Synced out")
    ]

    private let mergeCopies = [
        CelebrationCopy(title: "Branches United", subtitlePrefix: "Clean convergence"),
        CelebrationCopy(title: "Merge Magic", subtitlePrefix: "Lines aligned"),
        CelebrationCopy(title: "Timeline Restored", subtitlePrefix: "The graph approves"),
        CelebrationCopy(title: "Code Fusion", subtitlePrefix: "Two paths became one"),
        CelebrationCopy(title: "Graph Harmony", subtitlePrefix: "No loose ends"),
        CelebrationCopy(title: "Conflict Vanquished", subtitlePrefix: "Peace restored"),
        CelebrationCopy(title: "Merge Crown", subtitlePrefix: "Paths aligned"),
        CelebrationCopy(title: "Branch Bridge", subtitlePrefix: "Connection made")
    ]

    private let rebaseCopies = [
        CelebrationCopy(title: "Timeline Tidy", subtitlePrefix: "History polished"),
        CelebrationCopy(title: "Commit Stack Aligned", subtitlePrefix: "Clean footing"),
        CelebrationCopy(title: "Rebase Rhythm", subtitlePrefix: "Order restored"),
        CelebrationCopy(title: "History Lift", subtitlePrefix: "Stack cleaned"),
        CelebrationCopy(title: "Timeline Tuneup", subtitlePrefix: "Nice alignment")
    ]

    private let branchCopies = [
        CelebrationCopy(title: "New Timeline", subtitlePrefix: "Fresh lane"),
        CelebrationCopy(title: "Branch Hop", subtitlePrefix: "Context shifted"),
        CelebrationCopy(title: "Path Selected", subtitlePrefix: "Focus changed"),
        CelebrationCopy(title: "Focus Lane", subtitlePrefix: "New track"),
        CelebrationCopy(title: "Context Switch", subtitlePrefix: "Ready to move")
    ]

    private func pick(_ copies: [CelebrationCopy], seed: String) -> CelebrationCopy {
        guard !copies.isEmpty else {
            return CelebrationCopy(title: "Nice Work", subtitlePrefix: nil)
        }

        let index = abs(seed.hashValue) % copies.count
        return copies[index]
    }
}
