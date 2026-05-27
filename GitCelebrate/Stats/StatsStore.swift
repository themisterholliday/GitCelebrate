import Foundation

struct StatsStore {
    private let fileURL = URL.applicationSupportDirectory
        .appending(path: "GitCelebrate", directoryHint: .isDirectory)
        .appending(path: "stats.json")

    func load() -> AppStats {
        guard let data = try? Data(contentsOf: fileURL) else {
            return AppStats()
        }

        return (try? JSONDecoder().decode(AppStats.self, from: data)) ?? AppStats()
    }

    func save(_ stats: AppStats) {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(stats)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            assertionFailure("Failed to save stats: \(error)")
        }
    }
}
