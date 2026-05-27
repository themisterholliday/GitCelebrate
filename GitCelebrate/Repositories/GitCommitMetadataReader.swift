import Foundation

struct GitCommitMetadataReader {
    func latestCommitMetadata(in repoPath: String) -> GitCommitMetadata? {
        guard let output = try? runGit(
            arguments: ["show", "--format=%s", "--numstat", "--no-renames", "HEAD"],
            in: repoPath
        ) else {
            return nil
        }

        return parse(output)
    }

    func parse(_ output: String) -> GitCommitMetadata {
        let lines = output.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let subject = lines.first?.trimmingCharacters(in: .whitespacesAndNewlines)
        var filesChanged = 0
        var insertions = 0
        var deletions = 0

        for line in lines.dropFirst() {
            let fields = line.split(separator: "\t")
            guard fields.count >= 3 else {
                continue
            }

            filesChanged += 1
            insertions += Int(fields[0]) ?? 0
            deletions += Int(fields[1]) ?? 0
        }

        return GitCommitMetadata(
            subject: subject?.isEmpty == true ? nil : subject,
            filesChanged: filesChanged,
            insertions: insertions,
            deletions: deletions
        )
    }

    private func runGit(arguments: [String], in repoPath: String) throws -> String {
        let process = Process()
        process.executableURL = URL(filePath: "/usr/bin/git")
        process.arguments = arguments
        process.currentDirectoryURL = URL(filePath: repoPath, directoryHint: .isDirectory)

        let output = Pipe()
        process.standardOutput = output
        process.standardError = Pipe()

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            return ""
        }

        let data = output.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
