import SwiftUI

struct SettingsView: View {
    let appState: AppState
    let eventEngine: EventEngine
    let onTestSound: () -> Void
    let onSourcesChanged: () -> Void
    let onRepositoriesChanged: () -> Void
    let onInstallGitHooks: () throws -> Void
    let onRemoveGitHooks: () throws -> Void

    var body: some View {
        TabView {
            Tab("General", systemImage: "switch.2") {
                GeneralSettingsPane(appState: appState)
            }

            Tab("Sources", systemImage: "dot.radiowaves.left.and.right") {
                EventSourcesSettingsPane(
                    appState: appState,
                    onSourcesChanged: onSourcesChanged,
                    onInstallGitHooks: onInstallGitHooks,
                    onRemoveGitHooks: onRemoveGitHooks
                )
            }

            Tab("Events", systemImage: "bolt") {
                EventsSettingsPane(appState: appState)
            }

            Tab("Repos", systemImage: "folder") {
                RepositoriesSettingsPane(
                    appState: appState,
                    onRepositoriesChanged: onRepositoriesChanged
                )
            }

            Tab("Appearance", systemImage: "paintpalette") {
                AppearanceSettingsPane(
                    appState: appState,
                    eventEngine: eventEngine,
                    onTestSound: onTestSound
                )
            }
        }
        .padding()
    }
}
