import SwiftUI

struct AppearanceSettingsPane: View {
    let appState: AppState
    let eventEngine: EventEngine
    let onTestSound: () -> Void

    var body: some View {
        Form {
            Picker("Animation style", selection: Bindable(appState).animationStyle) {
                ForEach(AnimationStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }

            Section("Sound") {
                Toggle("Enable sounds", isOn: Bindable(appState).soundsEnabled)
                Slider(value: Bindable(appState).soundVolume, in: 0...1) {
                    Text("Volume")
                }
            }

            Section("Testing") {
                Button("Test Overlay", systemImage: "sparkles") {
                    guard appState.isEnabled, appState.overlaysEnabled else {
                        return
                    }

                    eventEngine.testGitEvent(.commit, animationStyle: appState.animationStyle)
                }

                Button("Test Confetti", systemImage: "party.popper") {
                    guard appState.isEnabled, appState.overlaysEnabled else {
                        return
                    }

                    eventEngine.testGitEvent(.merge, animationStyle: appState.animationStyle)
                }

                Button("Test Many Messages", systemImage: "rectangle.stack.badge.play") {
                    guard appState.isEnabled, appState.overlaysEnabled else {
                        return
                    }

                    eventEngine.testManyMessages(animationStyle: appState.animationStyle)
                }

                Button("Test All Animations", systemImage: "play.rectangle.on.rectangle") {
                    guard appState.isEnabled, appState.overlaysEnabled else {
                        return
                    }

                    eventEngine.testAllAnimationVariants(animationStyle: appState.animationStyle)
                }

                Button("Cancel All Animations", systemImage: "xmark.circle") {
                    eventEngine.cancelAllAnimations()
                }

                Button("Test Sound", systemImage: "speaker.wave.2") {
                    onTestSound()
                }
                .disabled(!appState.soundsEnabled)
            }

            Section("Animation Debug") {
                ForEach(AnimationVariant.allCases, id: \.self) { variant in
                    Button(variant.title, systemImage: "sparkles") {
                        guard appState.isEnabled, appState.overlaysEnabled else {
                            return
                        }

                        eventEngine.testAnimationVariant(variant, animationStyle: appState.animationStyle)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}
