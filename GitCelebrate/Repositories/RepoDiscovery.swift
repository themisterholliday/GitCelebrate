import Foundation

struct RepoDiscovery {
    func discover(in roots: [URL]) -> [RepoConfiguration] {
        let fileManager = FileManager.default
        var paths = Set<String>()

        for root in roots where fileManager.fileExists(atPath: root.path(percentEncoded: false)) {
            if isGitRepository(root) {
                paths.insert(normalizedPath(for: root))
                continue
            }

            guard let enumerator = fileManager.enumerator(
                at: root,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsPackageDescendants]
            ) else {
                continue
            }

            for case let candidate as URL in enumerator {
                guard isGitRepository(candidate) else {
                    continue
                }

                paths.insert(normalizedPath(for: candidate))
                enumerator.skipDescendants()
            }
        }

        return paths
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
            .map { RepoConfiguration(path: $0) }
    }

    func defaultRoots() -> [URL] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return [
            home.appending(path: "Projects", directoryHint: .isDirectory),
            home.appending(path: "Development", directoryHint: .isDirectory),
            home.appending(path: "Work", directoryHint: .isDirectory)
        ]
    }

    private func isGitRepository(_ url: URL) -> Bool {
        let gitDirectory = url.appending(path: ".git", directoryHint: .isDirectory)
        var isDirectory: ObjCBool = false

        return FileManager.default.fileExists(
            atPath: gitDirectory.path(percentEncoded: false),
            isDirectory: &isDirectory
        ) && isDirectory.boolValue
    }

    private func normalizedPath(for url: URL) -> String {
        url.resolvingSymlinksInPath().standardizedFileURL.path(percentEncoded: false)
    }
}
