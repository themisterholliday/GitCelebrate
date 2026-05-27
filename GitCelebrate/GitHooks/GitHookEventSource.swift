import Foundation
import Network

@MainActor
final class GitHookEventSource: EventSource {
    let type = EventSourceType.gitHook

    private var listener: NWListener?
    private var send: (@MainActor (AppEvent) -> Void)?
    private let port: NWEndpoint.Port
    private let queue = DispatchQueue(label: "GitCelebrate.GitHookEventSource")

    init(port: UInt16 = 4545) {
        self.port = NWEndpoint.Port(rawValue: port) ?? 4545
    }

    func start(send: @escaping @MainActor (AppEvent) -> Void) {
        stop()
        self.send = send

        do {
            let listener = try NWListener(using: .tcp, on: port)
            listener.newConnectionHandler = { [weak self] connection in
                Task { @MainActor in
                    self?.handle(connection)
                }
            }
            listener.start(queue: queue)
            self.listener = listener
        } catch {
            assertionFailure("Failed to start hook listener: \(error)")
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func handle(_ connection: NWConnection) {
        connection.start(queue: queue)
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65_536) { [weak self] data, _, _, _ in
            Task { @MainActor in
                self?.handle(data: data, connection: connection)
            }
        }
    }

    private func handle(data: Data?, connection: NWConnection) {
        defer {
            connection.cancel()
        }

        guard
            let data,
            let payload = GitHookHTTPParser().payload(from: data)
        else {
            respond(status: "400 Bad Request", connection: connection)
            return
        }

        send?(payload.appEvent())
        respond(status: "204 No Content", connection: connection)
    }

    private func respond(status: String, connection: NWConnection) {
        let response = """
        HTTP/1.1 \(status)\r
        Connection: close\r
        Content-Length: 0\r
        \r
        """

        connection.send(content: Data(response.utf8), completion: .contentProcessed { _ in })
    }
}

struct GitHookHTTPParser {
    func payload(from data: Data) -> GitHookPayload? {
        guard
            let request = String(data: data, encoding: .utf8),
            let bodyRange = request.range(of: "\r\n\r\n")
        else {
            return nil
        }

        let body = request[bodyRange.upperBound...]
        return try? JSONDecoder().decode(GitHookPayload.self, from: Data(body.utf8))
    }
}
