import AppKit
import SwiftUI

struct MenuBarContentView: View {
    let appState: AppState
    let eventEngine: EventEngine

    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Toggle("Enabled", isOn: Bindable(appState).isEnabled)

        Button("Test Overlay", systemImage: "sparkles") {
            guard appState.isEnabled, appState.overlaysEnabled else {
                return
            }

            eventEngine.testGitEvent(.commit, animationStyle: appState.animationStyle)
        }

        Divider()

        Button("Open Settings", systemImage: "gear") {
            openSettings()
            NSApp.activate()
        }

        Button("Quit", systemImage: "power") {
            NSApp.terminate(nil)
        }
    }
}
