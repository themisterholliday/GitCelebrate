import CoreServices
import Foundation

@MainActor
final class RepoObserverSource: EventSource {
    let type = EventSourceType.repoObserver

    private let repositories: () -> [RepoConfiguration]
    private let parser = GitActivityParser()
    private var stream: FSEventStreamRef?
    private var lastEventKeys: [String: String] = [:]
    @ObservationIgnored private var debounceTask: Task<Void, Never>?
    @ObservationIgnored private var send: (@MainActor (AppEvent) -> Void)?

    init(repositories: @escaping () -> [RepoConfiguration]) {
        self.repositories = repositories
    }

    func start(send: @escaping @MainActor (AppEvent) -> Void) {
        stop()
        self.send = send

        let paths = watchPaths()
        guard !paths.isEmpty else {
            return
        }

        var context = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        stream = FSEventStreamCreate(
            nil,
            repoObserverCallback,
            &context,
            paths as CFArray,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            1.0,
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents)
        )

        guard let stream else {
            return
        }

        FSEventStreamSetDispatchQueue(stream, .main)
        FSEventStreamStart(stream)
    }

    func stop() {
        debounceTask?.cancel()
        debounceTask = nil

        guard let stream else {
            return
        }

        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        self.stream = nil
    }

    private func watchPaths() -> [String] {
        repositories()
            .filter(\.enabled)
            .flatMap { repo in
                let gitDirectory = URL(filePath: repo.path, directoryHint: .isDirectory)
                    .appending(path: ".git", directoryHint: .isDirectory)

                return [
                    gitDirectory.appending(path: "logs/HEAD").path(percentEncoded: false),
                    gitDirectory.appending(path: "index").path(percentEncoded: false),
                    gitDirectory.appending(path: "HEAD").path(percentEncoded: false)
                ]
            }
    }

    fileprivate func handleChange() {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(750))
            guard !Task.isCancelled else {
                return
            }

            await emitLatestEvents()
        }
    }

    private func emitLatestEvents() async {
        guard let send else {
            return
        }

        let repos = repositories().filter(\.enabled)
        let parser = parser

        // Parsing spawns `/usr/bin/git` per repo. Run it off the main actor so a
        // large commit can't stall the UI, then resume on main to dedup and send.
        let events = await Task.detached(priority: .utility) {
            repos.compactMap { repo -> (path: String, event: AppEvent)? in
                parser.latestEvent(in: repo).map { (repo.path, $0) }
            }
        }.value

        guard !Task.isCancelled else {
            return
        }

        for (path, event) in events {
            let key = event.deduplicationKey
            guard lastEventKeys[path] != key else {
                continue
            }

            lastEventKeys[path] = key
            send(event)
        }
    }
}

private extension AppEvent {
    var deduplicationKey: String {
        switch kind {
        case .git(let event):
            [
                event.type.rawValue,
                event.repo.path,
                event.metadata?.subject ?? "",
                String(event.metadata?.insertions ?? 0),
                String(event.metadata?.deletions ?? 0)
            ].joined(separator: "|")
        }
    }
}

private let repoObserverCallback: FSEventStreamCallback = { _, context, _, _, _, _ in
    guard let context else {
        return
    }

    let source = Unmanaged<RepoObserverSource>.fromOpaque(context).takeUnretainedValue()
    Task { @MainActor in
        source.handleChange()
    }
}
