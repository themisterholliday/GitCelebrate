# GitCelebrate Architecture

## Product

GitCelebrate is a local-first macOS menu bar app that adds game-feel to developer activity.

It is not a Git client, dashboard, or surveillance tool.

Core loop:

```text
Developer action
  -> Event detection
  -> Reward event
  -> Overlay, animation, sound
```

## Principles

- Git is one event source, not the product.
- Overlay system is generic and source-agnostic.
- Animation logic is modular.
- Defaults favor zero setup.
- Advanced precision comes from optional Git hooks.
- UX should feel lightweight, ambient, rewarding, and brief.

## System Shape

```text
Menu bar app
Settings
Event sources
Event engine
Reward generator
Overlay system
Animation system
Audio system
Persistence
Repo management
Stats
```

Pipeline:

```text
Git hooks -----+
               |
Repo observer -+-> EventSourceManager
                   -> EventEngine
                   -> RewardGenerator
                   -> OverlayManager
                   -> AnimationRenderer
```

## Event Sources

All sources emit normalized app events.

```swift
protocol EventSource {
    func start()
    func stop()
}
```

Initial sources:

- Repo observer: default, zero setup, watches repos with FSEvents.
- Git hook source: optional, precise, posts JSON to localhost.

Watch targets:

- `.git/logs/HEAD`
- `.git/index`
- `.git/HEAD`

Hook events:

- `post-commit`
- `post-push`
- `post-merge`

## Event Model

Git-specific input:

```swift
enum GitEventType {
    case commit
    case push
    case merge
    case rebase
    case branch
}
```

Generic reward output:

```swift
struct RewardEvent {
    let title: String
    let subtitle: String?
    let style: AnimationStyle
    let intensity: Int
    let score: Int?
    let animationVariant: AnimationVariant
}
```

Rule example:

```swift
struct EventRule {
    let trigger: GitEventType
    let animation: AnimationStyle
}
```

## Local Event Server

Use `Network.framework`.

Default bind:

```text
127.0.0.1:4545
```

Example payload:

```json
{
  "type": "commit",
  "repo": "SampleApp",
  "path": "/Users/dev/projects/SampleApp"
}
```

## Repo Management

Track repos and source preferences.

```swift
struct RepoConfiguration {
    let path: String
    let enabled: Bool
    let eventSources: Set<EventSourceType>
}
```

Discovery:

- Manual add.
- Scan common folders.
- Recursively find `.git`.

Filtering:

- Track all repos.
- Track selected repos.

## Overlay System

Generic. No Git coupling.

```text
OverlayManager
  -> OverlayWindow
  -> OverlayScene
  -> AnimationRenderer
```

Use AppKit window hosting SwiftUI content.

Window requirements:

- transparent
- above normal apps
- all spaces
- fullscreen auxiliary
- multi-display ready

Queue behavior:

- sequential rendering
- debounce bursts
- merge duplicates
- support priority

Example:

```text
5 commits quickly -> "5 COMMITS"
```

## Animation System

Animations are plugins behind a protocol.

```swift
protocol OverlayAnimationPlugin {
    var style: AnimationStyle { get }
    func presentation(for scene: OverlayScene) -> OverlayAnimationPresentation
}
```

Styles (palette + material, set in Appearance):

- Minimal
- Arcade
- Confetti
- Loot

Celebration variants (the background effect chosen per event by size/type):

- Level Up — rising chevron arrows
- Rocket Launch — vector rockets across the screen
- Fireworks — radial spark bursts
- Magic Wand — orbiting sparkles
- Crown Flash — golden god-rays and glints
- Confetti — geometric confetti burst
- Commit Graph — a self-drawing git graph
- Loot Drop — falling gold coins
- Aurora — flowing gradient ribbons
- Hyperspace — light-speed warp streaks

Rendering:

- SwiftUI first; `Canvas` + `TimelineView` drive the particle effects.
- Effects are vector / SF Symbol based (no emoji), frame-rate capped, and torn
  down when an overlay ends.
- Metal later only if needed.

## Audio

Optional `AudioManager` with sound themes.

Controls:

- enabled
- volume
- theme

## Settings

SwiftUI settings window:

- General: launch at login, overlays, sounds.
- Event Sources: repo observation, Git hooks, install/remove hooks.
- Events: commits, pushes, merges, rebases.
- Repositories: all or selected.
- Appearance: animation style.
- Testing: overlay, confetti, sound.

## Persistence

Initial storage can be JSON or SwiftData.

Persist:

- settings
- repo configs
- rules
- stats
- streaks
- achievements

## Default UX

1. Install app.
2. Scan common project folders.
3. User selects repos.
4. Repo observation enabled.
5. Offer optional Git hook install.

## Implementation Phases

### Phase 1: App Shell

- macOS menu bar app.
- Settings window.
- Test overlay action.
- Basic persistence.

### Phase 2: Overlay Engine

- Transparent AppKit overlay window.
- SwiftUI overlay scene.
- Sequential queue.
- Minimal animation.

### Phase 3: Event Engine

- App event model.
- Reward event model.
- Rule mapping.
- Test event injection.

### Phase 4: Repo Observation

- Repo configuration.
- Manual repo add.
- FSEvents observer.
- Debounce and parse Git changes.

### Phase 5: Git Hooks

- Local HTTP server.
- Hook install/remove.
- Hook payload parsing.

### Phase 6: Reward Polish

- Confetti.
- Arcade.
- Loot.
- Sounds.
- Stats and streak overlays.
