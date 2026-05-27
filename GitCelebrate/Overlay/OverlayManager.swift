import AppKit
import Observation

@MainActor
@Observable
final class OverlayManager {
    private var queue: [OverlayScene] = []
    private var isPlaying = false
    private let windowController = OverlayWindowController()
    @ObservationIgnored private var debounceTask: Task<Void, Never>?
    @ObservationIgnored private var playbackTask: Task<Void, Never>?
    private let debounceDuration: Duration = .milliseconds(180)

    func enqueue(_ scene: OverlayScene) {
        merge(scene)

        guard !isPlaying else {
            return
        }

        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            try? await Task.sleep(for: debounceDuration)
            guard !Task.isCancelled else {
                return
            }

            playNextIfNeeded()
        }
    }

    func testOverlay(style: AnimationStyle) {
        enqueue(.test(style: style))
    }

    func cancelAll() {
        debounceTask?.cancel()
        playbackTask?.cancel()
        debounceTask = nil
        playbackTask = nil
        queue.removeAll()
        isPlaying = false
        windowController.hide()
    }

    private func merge(_ scene: OverlayScene) {
        if let index = queue.firstIndex(where: { $0.mergeKey == scene.mergeKey }) {
            var merged = queue[index]
            merged.count += scene.count
            merged.priority = min(merged.priority, scene.priority)
            queue[index] = merged
        } else {
            queue.append(scene)
        }

        queue.sort { lhs, rhs in
            lhs.priority == rhs.priority ? lhs.id.uuidString < rhs.id.uuidString : lhs.priority < rhs.priority
        }
    }

    private func playNextIfNeeded() {
        guard !isPlaying, !queue.isEmpty else {
            return
        }

        isPlaying = true
        let scene = queue.removeFirst()
        windowController.show(scene)

        playbackTask?.cancel()
        playbackTask = Task { @MainActor in
            try? await Task.sleep(for: scene.duration)
            guard !Task.isCancelled else {
                return
            }

            await windowController.fadeOut(seconds: 0.35)
            guard !Task.isCancelled else {
                return
            }

            windowController.hide()
            isPlaying = false
            playNextIfNeeded()
        }
    }
}
