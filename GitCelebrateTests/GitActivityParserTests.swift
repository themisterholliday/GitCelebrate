import Foundation
import Testing
@testable import GitCelebrate

struct GitActivityParserTests {
    @Test
    func parsesCommitReflogLine() {
        let line = "old new Craig <c@example.com> 0 -0600\tcommit: Add shell"

        #expect(GitActivityParser().eventType(from: line) == .commit)
    }

    @Test
    func parsesMergeBeforeCommitText() {
        let line = "old new Craig <c@example.com> 0 -0600\tmerge feature: Merge made by ort."

        #expect(GitActivityParser().eventType(from: line) == .merge)
    }

    @Test
    func parsesLatestRepoEvent() throws {
        let root = URL.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        let repo = root.appending(path: "ParserRepo", directoryHint: .isDirectory)
        let logs = repo
            .appending(path: ".git", directoryHint: .isDirectory)
            .appending(path: "logs", directoryHint: .isDirectory)
        let head = logs.appending(path: "HEAD")

        try FileManager.default.createDirectory(at: logs, withIntermediateDirectories: true)
        try "old new Craig <c@example.com> 0 -0600\tcommit: Test\n"
            .write(to: head, atomically: true, encoding: .utf8)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        let configuration = RepoConfiguration(path: repo.resolvingSymlinksInPath().path(percentEncoded: false))
        let event = GitActivityParser().latestEvent(in: configuration)

        guard case .git(let gitEvent) = event?.kind else {
            Issue.record("Expected Git event")
            return
        }

        #expect(gitEvent.type == .commit)
        #expect(gitEvent.repo == .init(name: "ParserRepo", path: configuration.path))
    }
}
