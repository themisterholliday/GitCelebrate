import Foundation

@MainActor
protocol EventSource: AnyObject {
    var type: EventSourceType { get }
    func start(send: @escaping @MainActor (AppEvent) -> Void)
    func stop()
}

enum EventSourceType: String, Codable, CaseIterable, Sendable {
    case git
    case repoObserver
    case gitHook
}
