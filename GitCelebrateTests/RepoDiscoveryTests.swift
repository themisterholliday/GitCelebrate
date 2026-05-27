import Foundation
import Testing
@testable import GitCelebrate

struct RepoDiscoveryTests {
    @Test
    func discoversNestedGitRepositories() throws {
        let root = URL.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        let repo = root
            .appending(path: "Example", directoryHint: .isDirectory)
        let gitDirectory = repo
            .appending(path: ".git", directoryHint: .isDirectory)

        try FileManager.default.createDirectory(at: gitDirectory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        let repositories = RepoDiscovery().discover(in: [root])

        #expect(repositories.map(\.path) == [repo.resolvingSymlinksInPath().path(percentEncoded: false)])
    }
}
