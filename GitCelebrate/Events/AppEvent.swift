import Foundation

struct AppEvent: Equatable, Sendable {
    var id: UUID
    var source: EventSourceType
    var kind: AppEventKind
    var date: Date

    init(
        id: UUID = UUID(),
        source: EventSourceType,
        kind: AppEventKind,
        date: Date = .now
    ) {
        self.id = id
        self.source = source
        self.kind = kind
        self.date = date
    }

    static func git(
        _ type: GitEventType,
        repo: GitRepositoryContext,
        metadata: GitCommitMetadata? = nil
    ) -> AppEvent {
        AppEvent(source: .git, kind: .git(GitEvent(type: type, repo: repo, metadata: metadata)))
    }
}

enum AppEventKind: Equatable, Sendable {
    case git(GitEvent)
}
