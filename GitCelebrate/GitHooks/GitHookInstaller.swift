import Foundation

struct GitHookInstaller {
    private let hooksDirectory = FileManager.default.homeDirectoryForCurrentUser
        .appending(path: ".git-hooks", directoryHint: .isDirectory)
    private let backupFileName = ".gitcelebrate-previous-hooks-path"

    func install() throws {
        try FileManager.default.createDirectory(at: hooksDirectory, withIntermediateDirectories: true)
        try backupCurrentHooksPathIfNeeded()

        try writeHook(named: "post-commit", type: .commit)
        try writeHook(named: "post-push", type: .push)
        try writeHook(named: "post-merge", type: .merge)
        try runGit(arguments: ["config", "--global", "core.hooksPath", hooksDirectory.path(percentEncoded: false)])
    }

    func remove() throws {
        for hook in ["post-commit", "post-push", "post-merge"] {
            let url = hooksDirectory.appending(path: hook)
            if FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) {
                try FileManager.default.removeItem(at: url)
            }
        }

        let current = try? currentHooksPath()
        guard current == hooksDirectory.path(percentEncoded: false) else {
            return
        }

        if let previous = try previousHooksPath(), !previous.isEmpty {
            try runGit(arguments: ["config", "--global", "core.hooksPath", previous])
        } else {
            try runGit(arguments: ["config", "--global", "--unset", "core.hooksPath"])
        }
    }

    func installedHooksPath() throws -> String? {
        try currentHooksPath()
    }

    private func writeHook(named name: String, type: GitEventType) throws {
        let url = hooksDirectory.appending(path: name)
        try hookScript(type: type).write(to: url, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: url.path(percentEncoded: false)
        )
    }

    func hookScript(type: GitEventType) -> String {
        """
        #!/bin/sh
        repo_path="$(git rev-parse --show-toplevel 2>/dev/null)"
        if [ -z "$repo_path" ]; then
          exit 0
        fi

        repo_name="$(basename "$repo_path")"
        subject="$(git log -1 --pretty=%s 2>/dev/null)"
        numstat="$(git show --numstat --format= HEAD 2>/dev/null)"
        files_changed="$(printf "%s\\n" "$numstat" | awk 'NF >= 3 { count++ } END { print count + 0 }')"
        insertions="$(printf "%s\\n" "$numstat" | awk 'NF >= 3 && $1 ~ /^[0-9]+$/ { sum += $1 } END { print sum + 0 }')"
        deletions="$(printf "%s\\n" "$numstat" | awk 'NF >= 3 && $2 ~ /^[0-9]+$/ { sum += $2 } END { print sum + 0 }')"
        payload="$(osascript -l JavaScript \\
          -e 'function run(argv) { return JSON.stringify({ type: argv[0], repo: argv[1], path: argv[2], subject: argv[3], filesChanged: Number(argv[4]), insertions: Number(argv[5]), deletions: Number(argv[6]) }); }' \\
          "\(type.rawValue)" "$repo_name" "$repo_path" "$subject" "$files_changed" "$insertions" "$deletions")"
        curl -fsS -m 1 -X POST -H 'Content-Type: application/json' --data "$payload" http://127.0.0.1:4545 >/dev/null 2>&1 || true
        exit 0
        """
    }

    private func backupCurrentHooksPathIfNeeded() throws {
        let current = try? currentHooksPath()
        let target = hooksDirectory.path(percentEncoded: false)
        guard let current, current != target else {
            return
        }

        let backupURL = hooksDirectory.appending(path: backupFileName)
        try current.write(to: backupURL, atomically: true, encoding: .utf8)
    }

    private func previousHooksPath() throws -> String? {
        let backupURL = hooksDirectory.appending(path: backupFileName)
        guard FileManager.default.fileExists(atPath: backupURL.path(percentEncoded: false)) else {
            return nil
        }

        return try String(contentsOf: backupURL, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func currentHooksPath() throws -> String? {
        let output = try runGit(arguments: ["config", "--global", "--get", "core.hooksPath"])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return output.isEmpty ? nil : output
    }

    @discardableResult
    private func runGit(arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(filePath: "/usr/bin/git")
        process.arguments = arguments

        let output = Pipe()
        let error = Pipe()
        process.standardOutput = output
        process.standardError = error

        try process.run()
        process.waitUntilExit()

        let outputData = output.fileHandleForReading.readDataToEndOfFile()
        let errorData = error.fileHandleForReading.readDataToEndOfFile()

        if process.terminationStatus != 0, arguments.contains("--unset") == false {
            let message = String(data: errorData, encoding: .utf8) ?? "git failed"
            throw GitHookInstallerError.gitFailed(message)
        }

        return String(data: outputData, encoding: .utf8) ?? ""
    }
}

enum GitHookInstallerError: LocalizedError {
    case gitFailed(String)

    var errorDescription: String? {
        switch self {
        case .gitFailed(let message):
            message
        }
    }
}
