import Foundation

struct RepoConfiguration: Codable, Equatable, Identifiable, Sendable {
    var path: String
    var enabled: Bool
    var eventSources: Set<EventSourceType>

    var id: String { path }

    var name: String {
        URL(filePath: path).lastPathComponent
    }

    init(
        path: String,
        enabled: Bool = true,
        eventSources: Set<EventSourceType> = [.repoObserver]
    ) {
        self.path = path
        self.enabled = enabled
        self.eventSources = eventSources
    }
}
