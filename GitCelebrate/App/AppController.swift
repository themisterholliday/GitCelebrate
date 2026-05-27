import Observation

@MainActor
@Observable
final class AppController {
    let appState: AppState
    let overlayManager: OverlayManager
    let eventEngine: EventEngine
    let audioManager = AudioManager()
    let statsTracker = StatsTracker()

    private let eventSourceManager = EventSourceManager()
    private let repoObserverSource: RepoObserverSource
    private let gitHookSource = GitHookEventSource()
    private let gitHookInstaller = GitHookInstaller()

    init() {
        let appState = AppState()
        let overlayManager = OverlayManager()
        let eventEngine = EventEngine(overlayManager: overlayManager)
        let repoObserverSource = RepoObserverSource {
            guard appState.repoObservationEnabled else {
                return []
            }

            return appState.repositories
        }

        self.appState = appState
        self.overlayManager = overlayManager
        self.eventEngine = eventEngine
        self.repoObserverSource = repoObserverSource

        restartEventSources()
    }

    func restartRepoObservation() {
        restartEventSources()
    }

    func restartEventSources() {
        var sources: [any EventSource] = []

        if appState.repoObservationEnabled {
            sources.append(repoObserverSource)
        }

        if appState.gitHooksEnabled {
            sources.append(gitHookSource)
        }

        eventSourceManager.configure(sources: sources) { [appState, eventEngine, audioManager, statsTracker, overlayManager] event in
            guard appState.isEnabled, appState.overlaysEnabled else {
                return
            }

            let reward = eventEngine.handle(event, animationStyle: appState.animationStyle)

            if appState.soundsEnabled, let reward {
                audioManager.playRewardSound(for: reward, volume: appState.soundVolume)
            }

            if let milestone = statsTracker.record(event) {
                overlayManager.enqueue(milestone.overlayScene())

                if appState.soundsEnabled {
                    audioManager.playRewardSound(for: milestone, volume: appState.soundVolume)
                }
            }
        }
        eventSourceManager.start()
    }

    func playTestSound() {
        audioManager.playTestSound(volume: appState.soundVolume)
    }

    func installGitHooks() throws {
        try gitHookInstaller.install()
        appState.gitHooksEnabled = true
        restartEventSources()
    }

    func removeGitHooks() throws {
        try gitHookInstaller.remove()
        appState.gitHooksEnabled = false
        restartEventSources()
    }
}
