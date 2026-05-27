import AppKit
import SwiftUI

struct RepositoriesSettingsPane: View {
    let appState: AppState
    let onRepositoriesChanged: () -> Void

    var body: some View {
        Form {
            Toggle("Track all repositories", isOn: Bindable(appState).trackAllRepositories)
                .onChange(of: appState.trackAllRepositories) { _, isEnabled in
                    if isEnabled {
                        appState.scanDefaultRepositories()
                    }

                    onRepositoriesChanged()
                }

            Section("Repositories") {
                if appState.repositories.isEmpty {
                    ContentUnavailableView(
                        "No Repositories",
                        systemImage: "folder.badge.plus",
                        description: Text("Add a repo or scan common folders.")
                    )
                } else {
                    List {
                        ForEach(appState.repositories) { repo in
                            RepoConfigurationRow(repo: repo)
                        }
                        .onDelete { offsets in
                            appState.removeRepositories(at: offsets)
                            onRepositoriesChanged()
                        }
                    }
                }
            }

            Section {
                Button("Add Repo", systemImage: "plus") {
                    addRepo()
                }

                Button("Scan Default Folders", systemImage: "folder.badge.gearshape") {
                    appState.scanDefaultRepositories()
                    onRepositoriesChanged()
                }
            }
        }
        .formStyle(.grouped)
    }

    private func addRepo() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Add"

        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }

        appState.addRepository(at: url)
        onRepositoriesChanged()
    }
}

private struct RepoConfigurationRow: View {
    let repo: RepoConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(repo.name)
                .bold()
            Text(repo.path)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.vertical, 4)
    }
}
