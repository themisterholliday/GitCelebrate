import AppKit
import SwiftUI

@MainActor
final class OverlayWindowController {
    private var windows: [NSWindow] = []

    func show(_ scene: OverlayScene) {
        let screens = NSScreen.screens.isEmpty ? [NSScreen.main].compactMap(\.self) : NSScreen.screens

        rebuildWindowsIfNeeded(for: screens)

        for (window, screen) in zip(windows, screens) {
            window.contentView = NSHostingView(rootView: OverlaySceneView(scene: scene))
            position(window, on: screen)
            window.alphaValue = 1
            window.orderFrontRegardless()
        }
    }

    /// Animates the visible overlay windows to transparent. Awaitable so callers
    /// can fully tear the windows down only after the fade completes.
    func fadeOut(seconds: TimeInterval) async {
        let visible = windows.filter(\.isVisible)
        guard !visible.isEmpty else {
            return
        }

        await NSAnimationContext.runAnimationGroup { context in
            context.duration = seconds
            for window in visible {
                window.animator().alphaValue = 0
            }
        }
    }

    func hide() {
        for window in windows {
            window.orderOut(nil)
            // Drop the hosting view so the Canvas/TimelineView animations stop and
            // the SwiftUI tree is freed while idle, instead of lingering off-screen.
            window.contentView = nil
        }
    }

    private func rebuildWindowsIfNeeded(for screens: [NSScreen]) {
        guard windows.count != screens.count else {
            return
        }

        for window in windows {
            window.close()
        }

        windows = screens.map { _ in makeWindow() }
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: .init(x: 0, y: 0, width: 980, height: 520),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        return window
    }

    private func position(_ window: NSWindow, on screen: NSScreen) {
        // Cover the whole display so content sits at true screen center and the
        // effects (rockets, confetti) can travel across the full screen.
        window.setFrame(screen.frame, display: false)
    }
}
