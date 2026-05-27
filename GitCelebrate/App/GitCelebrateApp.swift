import SwiftUI

@main
struct GitCelebrateApp: App {
    @State private var controller = AppController()

    var body: some Scene {
        MenuBarExtra("GitCelebrate", systemImage: controller.appState.isEnabled ? "party.popper" : "pause.circle") {
            MenuBarContentView(
                appState: controller.appState,
                eventEngine: controller.eventEngine
            )
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView(
                appState: controller.appState,
                eventEngine: controller.eventEngine,
                onTestSound: controller.playTestSound,
                onSourcesChanged: controller.restartEventSources,
                onRepositoriesChanged: controller.restartRepoObservation,
                onInstallGitHooks: controller.installGitHooks,
                onRemoveGitHooks: controller.removeGitHooks
            )
                .frame(width: 560, height: 460)
        }
    }
}
