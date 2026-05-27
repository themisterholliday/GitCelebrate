import Foundation

struct SettingsStore {
    private let fileURL = URL.applicationSupportDirectory
        .appending(path: "GitCelebrate", directoryHint: .isDirectory)
        .appending(path: "settings.json")

    func load() -> AppSettings? {
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        return try? JSONDecoder().decode(AppSettings.self, from: data)
    }

    func save(_ settings: AppSettings) {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(settings)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            assertionFailure("Failed to save settings: \(error)")
        }
    }
}
