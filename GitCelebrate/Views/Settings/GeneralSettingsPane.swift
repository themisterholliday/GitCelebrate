import SwiftUI

struct GeneralSettingsPane: View {
    let appState: AppState

    var body: some View {
        Form {
            Toggle("Enable GitCelebrate", isOn: Bindable(appState).isEnabled)
            Toggle("Enable overlays", isOn: Bindable(appState).overlaysEnabled)
            Toggle("Enable sounds", isOn: Bindable(appState).soundsEnabled)
            Toggle("Launch at login", isOn: Bindable(appState).launchAtLogin)
        }
        .formStyle(.grouped)
    }
}
