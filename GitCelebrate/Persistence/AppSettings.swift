import Foundation

struct AppSettings: Codable {
    var isEnabled: Bool
    var overlaysEnabled: Bool
    var soundsEnabled: Bool
    var soundVolume: Double
    var launchAtLogin: Bool
    var gitHooksEnabled: Bool
    var repoObservationEnabled: Bool
    var commitsEnabled: Bool
    var pushesEnabled: Bool
    var mergesEnabled: Bool
    var rebasesEnabled: Bool
    var trackAllRepositories: Bool
    var animationStyle: AnimationStyle
    var repositories: [RepoConfiguration]

    init(
        isEnabled: Bool,
        overlaysEnabled: Bool,
        soundsEnabled: Bool,
        soundVolume: Double = 0.55,
        launchAtLogin: Bool,
        gitHooksEnabled: Bool,
        repoObservationEnabled: Bool,
        commitsEnabled: Bool,
        pushesEnabled: Bool,
        mergesEnabled: Bool,
        rebasesEnabled: Bool,
        trackAllRepositories: Bool,
        animationStyle: AnimationStyle,
        repositories: [RepoConfiguration] = []
    ) {
        self.isEnabled = isEnabled
        self.overlaysEnabled = overlaysEnabled
        self.soundsEnabled = soundsEnabled
        self.soundVolume = soundVolume
        self.launchAtLogin = launchAtLogin
        self.gitHooksEnabled = gitHooksEnabled
        self.repoObservationEnabled = repoObservationEnabled
        self.commitsEnabled = commitsEnabled
        self.pushesEnabled = pushesEnabled
        self.mergesEnabled = mergesEnabled
        self.rebasesEnabled = rebasesEnabled
        self.trackAllRepositories = trackAllRepositories
        self.animationStyle = animationStyle
        self.repositories = repositories
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        overlaysEnabled = try container.decodeIfPresent(Bool.self, forKey: .overlaysEnabled) ?? true
        soundsEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundsEnabled) ?? false
        soundVolume = try container.decodeIfPresent(Double.self, forKey: .soundVolume) ?? 0.55
        launchAtLogin = try container.decodeIfPresent(Bool.self, forKey: .launchAtLogin) ?? false
        gitHooksEnabled = try container.decodeIfPresent(Bool.self, forKey: .gitHooksEnabled) ?? false
        repoObservationEnabled = try container.decodeIfPresent(Bool.self, forKey: .repoObservationEnabled) ?? true
        commitsEnabled = try container.decodeIfPresent(Bool.self, forKey: .commitsEnabled) ?? true
        pushesEnabled = try container.decodeIfPresent(Bool.self, forKey: .pushesEnabled) ?? true
        mergesEnabled = try container.decodeIfPresent(Bool.self, forKey: .mergesEnabled) ?? true
        rebasesEnabled = try container.decodeIfPresent(Bool.self, forKey: .rebasesEnabled) ?? true
        trackAllRepositories = try container.decodeIfPresent(Bool.self, forKey: .trackAllRepositories) ?? false
        animationStyle = try container.decodeIfPresent(AnimationStyle.self, forKey: .animationStyle) ?? .minimal
        repositories = try container.decodeIfPresent([RepoConfiguration].self, forKey: .repositories) ?? []
    }
}
