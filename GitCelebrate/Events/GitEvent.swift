import Foundation

struct GitEvent: Equatable, Sendable {
    var type: GitEventType
    var repo: GitRepositoryContext
    var metadata: GitCommitMetadata?
}

enum GitEventType: String, Codable, CaseIterable, Sendable {
    case commit
    case push
    case merge
    case rebase
    case branch

    var title: String {
        switch self {
        case .commit:
            "Commit Complete"
        case .push:
            "Push Complete"
        case .merge:
            "Merge Complete"
        case .rebase:
            "Rebase Complete"
        case .branch:
            "Branch Changed"
        }
    }
}

struct GitRepositoryContext: Equatable, Sendable {
    var name: String
    var path: String

    static let sample = GitRepositoryContext(
        name: "GitCelebrate",
        path: "/Users/dev/projects/GitCelebrate"
    )
}

struct GitCommitMetadata: Codable, Equatable, Sendable {
    var subject: String?
    var filesChanged: Int
    var insertions: Int
    var deletions: Int

    var netLines: Int {
        insertions - deletions
    }

    var churn: Int {
        insertions + deletions
    }

    static let empty = GitCommitMetadata(
        subject: nil,
        filesChanged: 0,
        insertions: 0,
        deletions: 0
    )
}
