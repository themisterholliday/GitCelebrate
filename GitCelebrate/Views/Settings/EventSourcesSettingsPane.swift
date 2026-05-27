import SwiftUI

struct EventSourcesSettingsPane: View {
    let appState: AppState
    let onSourcesChanged: () -> Void
    let onInstallGitHooks: () throws -> Void
    let onRemoveGitHooks: () throws -> Void

    @State private var statusMessage: String?

    var body: some View {
        Form {
            Section("Sources") {
                Toggle("Repo observation", isOn: Bindable(appState).repoObservationEnabled)
                    .onChange(of: appState.repoObservationEnabled) { _, _ in
                        onSourcesChanged()
                    }
                Toggle("Git hooks", isOn: Bindable(appState).gitHooksEnabled)
                    .onChange(of: appState.gitHooksEnabled) { _, _ in
                        onSourcesChanged()
                    }
            }

            Section("Git Hooks") {
                Button("Install Hooks", systemImage: "arrow.down.doc") {
                    runHookAction("Hooks installed") {
                        try onInstallGitHooks()
                    }
                }

                Button("Remove Hooks", systemImage: "trash") {
                    runHookAction("Hooks removed") {
                        try onRemoveGitHooks()
                    }
                }

                if let statusMessage {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }

    private func runHookAction(_ successMessage: String, action: () throws -> Void) {
        do {
            try action()
            statusMessage = successMessage
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}
