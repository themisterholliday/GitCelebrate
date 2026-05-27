import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    var isEnabled = true {
        didSet { save() }
    }

    var overlaysEnabled = true {
        didSet { save() }
    }

    var soundsEnabled = false {
        didSet { save() }
    }

    var soundVolume = 0.55 {
        didSet { save() }
    }

    var launchAtLogin = false {
        didSet { save() }
    }

    var gitHooksEnabled = false {
        didSet { save() }
    }

    var repoObservationEnabled = true {
        didSet { save() }
    }

    var commitsEnabled = true {
        didSet { save() }
    }

    var pushesEnabled = true {
        didSet { save() }
    }

    var mergesEnabled = true {
        didSet { save() }
    }

    var rebasesEnabled = true {
        didSet { save() }
    }

    var trackAllRepositories = false {
        didSet { save() }
    }

    var animationStyle = AnimationStyle.minimal {
        didSet { save() }
    }

    var repositories: [RepoConfiguration] = [] {
        didSet { save() }
    }

    private let store = SettingsStore()
    private let repoDiscovery = RepoDiscovery()
    private var isLoading = false

    init() {
        load()
    }

    func pause() {
        isEnabled = false
    }

    func resume() {
        isEnabled = true
    }

    private func load() {
        isLoading = true
        defer { isLoading = false }

        guard let settings = store.load() else {
            return
        }

        isEnabled = settings.isEnabled
        overlaysEnabled = settings.overlaysEnabled
        soundsEnabled = settings.soundsEnabled
        soundVolume = settings.soundVolume
        launchAtLogin = settings.launchAtLogin
        gitHooksEnabled = settings.gitHooksEnabled
        repoObservationEnabled = settings.repoObservationEnabled
        commitsEnabled = settings.commitsEnabled
        pushesEnabled = settings.pushesEnabled
        mergesEnabled = settings.mergesEnabled
        rebasesEnabled = settings.rebasesEnabled
        trackAllRepositories = settings.trackAllRepositories
        animationStyle = settings.animationStyle
        repositories = settings.repositories
    }

    func addRepository(at url: URL) {
        let path = url.resolvingSymlinksInPath().standardizedFileURL.path(percentEncoded: false)
        guard !repositories.contains(where: { $0.path == path }) else {
            return
        }

        repositories.append(RepoConfiguration(path: path))
        repositories.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    func removeRepositories(at offsets: IndexSet) {
        repositories.remove(atOffsets: offsets)
    }

    func scanDefaultRepositories() {
        let discovered = repoDiscovery.discover(in: repoDiscovery.defaultRoots())
        mergeRepositories(discovered)
    }

    private func mergeRepositories(_ discovered: [RepoConfiguration]) {
        let existingPaths = Set(repositories.map(\.path))
        let newRepositories = discovered.filter { !existingPaths.contains($0.path) }

        guard !newRepositories.isEmpty else {
            return
        }

        repositories.append(contentsOf: newRepositories)
        repositories.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private func save() {
        guard !isLoading else {
            return
        }

        store.save(
            AppSettings(
                isEnabled: isEnabled,
                overlaysEnabled: overlaysEnabled,
                soundsEnabled: soundsEnabled,
                soundVolume: soundVolume,
                launchAtLogin: launchAtLogin,
                gitHooksEnabled: gitHooksEnabled,
                repoObservationEnabled: repoObservationEnabled,
                commitsEnabled: commitsEnabled,
                pushesEnabled: pushesEnabled,
                mergesEnabled: mergesEnabled,
                rebasesEnabled: rebasesEnabled,
                trackAllRepositories: trackAllRepositories,
                animationStyle: animationStyle,
                repositories: repositories
            )
        )
    }
}
