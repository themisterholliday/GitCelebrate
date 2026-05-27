import Foundation

struct GitHookPayload: Codable, Equatable, Sendable {
    var type: GitEventType
    var repo: String
    var path: String
    var subject: String?
    var filesChanged: Int?
    var insertions: Int?
    var deletions: Int?

    func appEvent() -> AppEvent {
        .git(
            type,
            repo: GitRepositoryContext(name: repo, path: path),
            metadata: metadata()
        )
    }

    private func metadata() -> GitCommitMetadata? {
        if subject == nil, filesChanged == nil, insertions == nil, deletions == nil {
            return type == .commit ? GitCommitMetadataReader().latestCommitMetadata(in: path) : nil
        }

        return GitCommitMetadata(
            subject: subject,
            filesChanged: filesChanged ?? 0,
            insertions: insertions ?? 0,
            deletions: deletions ?? 0
        )
    }
}
