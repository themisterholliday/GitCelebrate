import Foundation

struct GitActivityParser {
    private let metadataReader = GitCommitMetadataReader()

    func latestEvent(in repo: RepoConfiguration) -> AppEvent? {
        let repoURL = URL(filePath: repo.path, directoryHint: .isDirectory)
        let headLog = repoURL
            .appending(path: ".git", directoryHint: .isDirectory)
            .appending(path: "logs", directoryHint: .isDirectory)
            .appending(path: "HEAD")

        guard
            let contents = try? String(contentsOf: headLog, encoding: .utf8),
            let latestLine = contents.split(separator: "\n").last,
            let gitEventType = eventType(from: String(latestLine))
        else {
            return nil
        }

        return .git(gitEventType, repo: GitRepositoryContext(name: repo.name, path: repo.path), metadata: metadata(for: gitEventType, repo: repo))
    }

    func eventType(from reflogLine: String) -> GitEventType? {
        let message = reflogLine.components(separatedBy: "\t").last ?? reflogLine

        if message.localizedStandardContains("rebase") {
            return .rebase
        }

        if message.localizedStandardContains("merge") {
            return .merge
        }

        if message.localizedStandardContains("checkout")
            || message.localizedStandardContains("moving from") {
            return .branch
        }

        if message.localizedStandardContains("commit") {
            return .commit
        }

        return nil
    }

    private func metadata(for type: GitEventType, repo: RepoConfiguration) -> GitCommitMetadata? {
        guard type == .commit else {
            return nil
        }

        return metadataReader.latestCommitMetadata(in: repo.path)
    }
}
