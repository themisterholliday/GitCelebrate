import Observation

@MainActor
@Observable
final class EventSourceManager {
    private var sources: [any EventSource] = []
    private var send: (@MainActor (AppEvent) -> Void)?

    func configure(sources: [any EventSource], send: @escaping @MainActor (AppEvent) -> Void) {
        stop()
        self.sources = sources
        self.send = send
    }

    func start() {
        guard let send else {
            return
        }

        for source in sources {
            source.start(send: send)
        }
    }

    func stop() {
        for source in sources {
            source.stop()
        }
    }
}
