import SwiftUI

struct EventsSettingsPane: View {
    let appState: AppState

    var body: some View {
        Form {
            Toggle("Commits", isOn: Bindable(appState).commitsEnabled)
            Toggle("Pushes", isOn: Bindable(appState).pushesEnabled)
            Toggle("Merges", isOn: Bindable(appState).mergesEnabled)
            Toggle("Rebases", isOn: Bindable(appState).rebasesEnabled)
        }
        .formStyle(.grouped)
    }
}
