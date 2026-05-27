import SwiftUI

/// Full-screen celebration overlay.
///
/// The scene fades and springs in once with a single soft pop — no shake or
/// overshoot snap. Background flair is drawn entirely from vector shapes and
/// SF Symbols — no emoji glyphs.
struct OverlaySceneView: View {
    let scene: OverlayScene

    @State private var appeared = false

    private let registry = OverlayAnimationRegistry()

    var body: some View {
        let presentation = registry.presentation(for: scene)
        let detail = OverlayDetail(subtitle: scene.subtitle)

        ZStack {
            OverlayCelebrationEffectsView(presentation: presentation)

            // Soft dark pool behind the text so it stays legible over any
            // background, however bright (aurora, hyperspace, coins).
            RadialGradient(
                gradient: Gradient(colors: [.black.opacity(0.45), .black.opacity(0)]),
                center: .center,
                startRadius: 0,
                endRadius: 480
            )
            .allowsHitTesting(false)

            content(detail: detail)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
        .task {
            // One soft spring on appear — gentle pop, no shake or overshoot snap.
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                appeared = true
            }
        }
    }

    @ViewBuilder
    private func content(detail: OverlayDetail) -> some View {
        VStack(spacing: 18) {
            Text(scene.displayTitle)
                .font(.system(size: 58, weight: .black, design: .rounded))
                .textCase(.uppercase)
                .multilineTextAlignment(.center)
                .readableOverlayText(fill: AnyShapeStyle(.white), outlineWidth: 2.5, shadowRadius: 14)

            if let subject = detail.subject {
                Text(subject)
                    .font(.system(.title, design: .rounded))
                    .bold()
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .readableOverlayText(fill: AnyShapeStyle(.white), outlineWidth: 1.6, shadowRadius: 10)
            }

            if let metadata = detail.metadata {
                Text(metadata)
                    .font(.headline)
                    .bold()
                    .multilineTextAlignment(.center)
                    .readableOverlayText(fill: AnyShapeStyle(.white), outlineWidth: 1.4, shadowRadius: 8)
            }

            if let repoLine = detail.repoLine {
                Text(repoLine)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .readableOverlayText(fill: AnyShapeStyle(.white.opacity(0.92)), outlineWidth: 1.2, shadowRadius: 7)
            }
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: 900)
    }
}

private extension View {
    func readableOverlayText(fill: AnyShapeStyle, outlineWidth: CGFloat, shadowRadius: CGFloat) -> some View {
        modifier(ReadableOverlayText(fill: fill, outlineWidth: outlineWidth, shadowRadius: shadowRadius))
    }
}

/// Renders text with a solid black outline (eight offset copies), a chosen fill,
/// and a soft drop shadow — so overlay text reads clearly over any background.
/// Apply to a `Text` that sets font/case/alignment but no foreground style.
private struct ReadableOverlayText: ViewModifier {
    let fill: AnyShapeStyle
    let outlineWidth: CGFloat
    let shadowRadius: CGFloat

    private let offsets: [CGSize] = [
        CGSize(width: -1, height: -1), CGSize(width: 0, height: -1), CGSize(width: 1, height: -1),
        CGSize(width: -1, height: 0), CGSize(width: 1, height: 0),
        CGSize(width: -1, height: 1), CGSize(width: 0, height: 1), CGSize(width: 1, height: 1)
    ]

    func body(content: Content) -> some View {
        ZStack {
            ForEach(Array(offsets.enumerated()), id: \.offset) { _, offset in
                content
                    .foregroundStyle(.black)
                    .offset(x: offset.width * outlineWidth, y: offset.height * outlineWidth)
            }

            content
                .foregroundStyle(fill)
        }
        .shadow(color: .black.opacity(0.5), radius: shadowRadius * 0.8, x: 0, y: 2)
    }
}

private struct OverlayCelebrationEffectsView: View {
    let presentation: OverlayAnimationPresentation

    var body: some View {
        ZStack {
            switch presentation.backgroundEffect {
            case .confettiCannon:
                ConfettiCannonCanvasView(primary: presentation.accent, secondary: presentation.secondaryAccent)
            case .fireworks:
                FireworksCanvasView(primary: presentation.accent, secondary: presentation.secondaryAccent)
            case .orbitalRings:
                OrbitingSparkleView(primary: presentation.accent, secondary: presentation.secondaryAccent)
            case .rocketLaunch:
                RocketLaunchCanvasView(primary: presentation.accent, secondary: presentation.secondaryAccent)
            case .levelUpArrows:
                LevelUpArrowCanvasView(primary: presentation.accent, secondary: presentation.secondaryAccent)
            case .crownShine:
                CrownShineCanvasView(primary: presentation.accent, secondary: presentation.secondaryAccent)
            case .commitGraph:
                CommitGraphCanvasView(primary: presentation.accent, secondary: presentation.secondaryAccent)
            case .coinShower:
                CoinShowerCanvasView(primary: presentation.accent, secondary: presentation.secondaryAccent)
            case .auroraRibbon:
                AuroraRibbonCanvasView(primary: presentation.accent, secondary: presentation.secondaryAccent)
            case .hyperspace:
                HyperspaceCanvasView(primary: presentation.accent, secondary: presentation.secondaryAccent)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Confetti

/// Projectile confetti fired from three ground cannons. Pieces are geometric
/// shapes that flutter (rotate) and drift on a gentle wind as they fall.
private struct ConfettiCannonCanvasView: View {
    let primary: Color
    let secondary: Color

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 50.0)) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                let origins = [
                    CGPoint(x: size.width * 0.20, y: size.height * 0.94),
                    CGPoint(x: size.width * 0.50, y: size.height * 0.98),
                    CGPoint(x: size.width * 0.80, y: size.height * 0.94)
                ]

                for (burstIndex, origin) in origins.enumerated() {
                    for index in 0..<40 {
                        let progress = (elapsed * 0.36 + Double(index) * 0.012 + Double(burstIndex) * 0.22)
                            .truncatingRemainder(dividingBy: 1)
                        let direction = Double(index % 21) - 10
                        let xVelocity = CGFloat(direction * 22 + Double(burstIndex - 1) * 80)
                        let yVelocity = CGFloat(-1080 - Double(index % 9) * 52)
                        let gravity: CGFloat = 980
                        let wind = CGFloat(sin(elapsed * 0.8 + Double(index)) * 34) * CGFloat(progress)
                        let point = CGPoint(
                            x: origin.x + xVelocity * CGFloat(progress) + wind,
                            y: origin.y + yVelocity * CGFloat(progress) + gravity * CGFloat(progress * progress) * 0.5
                        )
                        let opacity = min(1, (1 - progress) * 1.7)
                        guard opacity > 0.02 else {
                            continue
                        }

                        var piece = context
                        piece.translateBy(x: point.x, y: point.y)
                        piece.rotate(by: .radians(elapsed * 6 + Double(index)))

                        let width = CGFloat(8 + index % 4 * 2)
                        let height = index.isMultiple(of: 3) ? width * 1.9 : width
                        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
                        let color = celebrationColor(index: index + burstIndex, primary: primary, secondary: secondary)
                        piece.fill(confettiPath(index: index, rect: rect), with: .color(color.opacity(opacity)))
                    }
                }
            }
        }
    }
}

// MARK: - Fireworks

/// Radial spark bursts. Each ray draws a short fading trail and droops under
/// gravity, with a bright flash at the moment of detonation.
private struct FireworksCanvasView: View {
    let primary: Color
    let secondary: Color

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 40.0)) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                let centers = [
                    CGPoint(x: size.width * 0.24, y: size.height * 0.26),
                    CGPoint(x: size.width * 0.74, y: size.height * 0.30),
                    CGPoint(x: size.width * 0.58, y: size.height * 0.70)
                ]

                for (burstIndex, center) in centers.enumerated() {
                    let phase = (elapsed * 0.5 + Double(burstIndex) * 0.31).truncatingRemainder(dividingBy: 1)
                    let expansion = 1 - pow(1 - phase, 2)
                    let maxRadius: CGFloat = 200

                    if phase < 0.12 {
                        let flashRadius = CGFloat(phase / 0.12) * 64
                        let flash = CGRect(
                            x: center.x - flashRadius,
                            y: center.y - flashRadius,
                            width: flashRadius * 2,
                            height: flashRadius * 2
                        )
                        context.fill(Path(ellipseIn: flash), with: .color(.white.opacity((1 - phase / 0.12) * 0.9)))
                    }

                    let rayCount = 26
                    for ray in 0..<rayCount {
                        let angle = Double(ray) / Double(rayCount) * Double.pi * 2
                        for trail in 0..<5 {
                            let trailPhase = max(0, expansion - Double(trail) * 0.045)
                            let radius = CGFloat(trailPhase) * maxRadius
                            let droop = CGFloat(phase * phase) * 150
                            let point = CGPoint(
                                x: center.x + cos(angle) * radius,
                                y: center.y + sin(angle) * radius + droop
                            )
                            let opacity = (1 - phase) * (1 - Double(trail) * 0.18)
                            guard opacity > 0.02 else {
                                continue
                            }

                            let dotSize = max(2, 5 - CGFloat(trail))
                            let rect = CGRect(
                                x: point.x - dotSize,
                                y: point.y - dotSize,
                                width: dotSize * 2,
                                height: dotSize * 2
                            )
                            let color = celebrationColor(index: ray + burstIndex * 7, primary: primary, secondary: secondary)
                            context.fill(Path(ellipseIn: rect), with: .color(color.opacity(opacity)))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Rocket launch

/// Vector rockets flying across the screen along a shallow arc, each trailing a
/// flickering flame, a hot exhaust plume, and a fading smoke tail.
private struct RocketLaunchCanvasView: View {
    let primary: Color
    let secondary: Color

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                let laneCount = 6

                for lane in 0..<laneCount {
                    let laneFraction = Double(lane) / Double(laneCount - 1)
                    let speed = 0.26 + Double(lane) * 0.045
                    let progress = (elapsed * speed + Double(lane) * 0.37).truncatingRemainder(dividingBy: 1)
                    let baseY = size.height * (0.14 + 0.72 * laneFraction)
                    let arc = size.height * 0.14

                    let point = rocketPoint(progress: progress, width: size.width, baseY: baseY, arc: arc)
                    let ahead = rocketPoint(progress: progress + 0.001, width: size.width, baseY: baseY, arc: arc)
                    let angle = atan2(Double(ahead.y - point.y), Double(ahead.x - point.x))
                    let travel = CGVector(dx: cos(angle), dy: sin(angle))

                    drawExhaust(in: context, from: point, travel: travel, elapsed: elapsed, lane: lane)
                    drawRocket(
                        in: context,
                        at: point,
                        angle: angle,
                        scale: 0.8 + CGFloat(lane % 3) * 0.16,
                        elapsed: elapsed,
                        seed: lane,
                        primary: primary,
                        secondary: secondary
                    )
                }
            }
        }
    }

    private func rocketPoint(progress: Double, width: CGFloat, baseY: CGFloat, arc: CGFloat) -> CGPoint {
        let x = -width * 0.15 + width * 1.3 * CGFloat(progress)
        let y = baseY - arc * sin(CGFloat(progress) * .pi)
        return CGPoint(x: x, y: y)
    }

    private func drawExhaust(in context: GraphicsContext, from point: CGPoint, travel: CGVector, elapsed: Double, lane: Int) {
        for step in 1...16 {
            let back = CGFloat(step) * 11
            let jitter = CGFloat(sin(elapsed * 18 + Double(step) + Double(lane))) * 3.5
            let centre = CGPoint(
                x: point.x - travel.dx * back - travel.dy * jitter,
                y: point.y - travel.dy * back + travel.dx * jitter
            )
            let fade = 1 - CGFloat(step) / 17
            let radius = 3 + CGFloat(step) * 1.0
            let rect = CGRect(x: centre.x - radius, y: centre.y - radius, width: radius * 2, height: radius * 2)

            let color: Color
            let opacity: Double
            switch step {
            case 0..<4:
                color = .orange
                opacity = 0.8 * Double(fade)
            case 4..<7:
                color = .yellow
                opacity = 0.6 * Double(fade)
            default:
                color = .gray
                opacity = 0.18 * Double(fade)
            }
            context.fill(Path(ellipseIn: rect), with: .color(color.opacity(opacity)))
        }
    }

    /// Draws a rocket pointing along +x in local space, rotated to `angle`.
    private func drawRocket(
        in context: GraphicsContext,
        at point: CGPoint,
        angle: Double,
        scale: CGFloat,
        elapsed: Double,
        seed: Int,
        primary: Color,
        secondary: Color
    ) {
        var rocket = context
        rocket.translateBy(x: point.x, y: point.y)
        rocket.rotate(by: .radians(angle))
        rocket.scaleBy(x: scale, y: scale)

        let length: CGFloat = 60
        let girth: CGFloat = 22

        // Flame behind the tail, length flickering over time.
        let flicker = 1.1 + 0.45 * sin(elapsed * 26 + Double(seed))
        let flameLength = girth * CGFloat(flicker)
        rocket.fill(
            triangle(
                CGPoint(x: -length * 0.5, y: -girth * 0.34),
                CGPoint(x: -length * 0.5 - flameLength, y: 0),
                CGPoint(x: -length * 0.5, y: girth * 0.34)
            ),
            with: .color(.orange.opacity(0.95))
        )
        rocket.fill(
            triangle(
                CGPoint(x: -length * 0.5, y: -girth * 0.2),
                CGPoint(x: -length * 0.5 - flameLength * 0.6, y: 0),
                CGPoint(x: -length * 0.5, y: girth * 0.2)
            ),
            with: .color(.yellow)
        )

        // Tail fins.
        rocket.fill(
            triangle(
                CGPoint(x: -length * 0.36, y: -girth * 0.5),
                CGPoint(x: -length * 0.52, y: -girth),
                CGPoint(x: -length * 0.12, y: -girth * 0.5)
            ),
            with: .color(secondary)
        )
        rocket.fill(
            triangle(
                CGPoint(x: -length * 0.36, y: girth * 0.5),
                CGPoint(x: -length * 0.52, y: girth),
                CGPoint(x: -length * 0.12, y: girth * 0.5)
            ),
            with: .color(secondary)
        )

        // Body and accent stripe at the tail.
        let body = CGRect(x: -length * 0.5, y: -girth * 0.5, width: length * 0.85, height: girth)
        rocket.fill(Path(roundedRect: body, cornerRadius: girth * 0.45), with: .color(.white))
        let stripe = CGRect(x: -length * 0.5, y: -girth * 0.5, width: length * 0.2, height: girth)
        rocket.fill(Path(roundedRect: stripe, cornerRadius: girth * 0.45), with: .color(primary))

        // Nose cone.
        rocket.fill(
            triangle(
                CGPoint(x: length * 0.35, y: -girth * 0.5),
                CGPoint(x: length * 0.5, y: 0),
                CGPoint(x: length * 0.35, y: girth * 0.5)
            ),
            with: .color(primary)
        )

        // Window.
        let window = CGRect(x: length * 0.04, y: -girth * 0.22, width: girth * 0.44, height: girth * 0.44)
        rocket.fill(Path(ellipseIn: window), with: .color(secondary.opacity(0.9)))
        rocket.stroke(Path(ellipseIn: window), with: .color(.white), lineWidth: 2)
    }
}

// MARK: - Level-up arrows

/// Streams of chevron arrows accelerating upward.
private struct LevelUpArrowCanvasView: View {
    let primary: Color
    let secondary: Color

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate

                for index in 0..<52 {
                    let progress = (elapsed * 0.26 + Double(index) * 0.018).truncatingRemainder(dividingBy: 1)
                    let rise = pow(progress, 1.4) // ease-in: accelerate as they climb
                    let baseX = size.width * CGFloat((index * 37) % 100) / 100
                    let wobble = CGFloat(sin(elapsed * 2 + Double(index)) * 26)
                    let centre = CGPoint(
                        x: baseX + wobble,
                        y: size.height * (1.08 - CGFloat(rise) * 1.2)
                    )

                    let fadeIn = min(1, progress * 6)
                    let fadeOut = 1 - max(0, (progress - 0.7) / 0.3)
                    let opacity = Double(fadeIn) * Double(fadeOut)
                    guard opacity > 0.02 else {
                        continue
                    }

                    let span = CGFloat(12 + index % 5 * 4)
                    let color = (index.isMultiple(of: 3) ? primary : Color.green).opacity(opacity)
                    context.stroke(
                        chevronUp(centre: centre, span: span),
                        with: .color(color),
                        style: StrokeStyle(lineWidth: span * 0.34, lineCap: .round, lineJoin: .round)
                    )
                }
            }
        }
    }
}

// MARK: - Sparkle / magic

/// Orbiting, twinkling SF Symbol sparkles for the magic-wand variant.
private struct OrbitingSparkleView: View {
    let primary: Color
    let secondary: Color

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            ForEach(0..<16, id: \.self) { index in
                Image(systemName: orbitSymbol(for: index))
                    .font(.system(size: index.isMultiple(of: 3) ? 46 : 32, weight: .bold, design: .rounded))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(index.isMultiple(of: 2) ? primary : secondary)
                    .offset(y: CGFloat(-250 - (index % 3) * 64))
                    .rotationEffect(.degrees(Double(index) * (360.0 / 16.0)))
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .scaleEffect(isAnimating ? 1 : 0.4)
                    .opacity(isAnimating ? 1 : 0.35)
                    .animation(
                        .linear(duration: Double(3 + index % 3)).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                    .animation(
                        .easeInOut(duration: 0.9 + Double(index % 4) * 0.2)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .frame(width: 980, height: 980)
        .task {
            isAnimating = true
        }
    }

    private func orbitSymbol(for index: Int) -> String {
        ["sparkle", "star.fill", "plus", "diamond.fill"][index % 4]
    }
}

// MARK: - Crown shine

/// Regal shimmer for the crown variant: slow rotating golden god-rays behind the
/// title, a soft central glow, and drifting twinkling gold glints. Deliberately
/// calmer and more luxurious than the explosive fireworks burst.
private struct CrownShineCanvasView: View {
    let primary: Color   // gold
    let secondary: Color // royal accent

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 40.0)) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                let center = CGPoint(x: size.width / 2, y: size.height * 0.46)
                let rayLength = min(size.width, size.height) * 0.95

                // Rotating god-rays radiating from behind the headline.
                let rayCount = 16
                for ray in 0..<rayCount {
                    let angle = Double(ray) / Double(rayCount) * .pi * 2 + elapsed * 0.22
                    let spread = 0.07
                    let shimmer = 0.06 + 0.1 * (0.5 + 0.5 * sin(elapsed * 1.4 + Double(ray)))
                    let tip = CGPoint(x: center.x + cos(angle) * rayLength, y: center.y + sin(angle) * rayLength)
                    let left = CGPoint(
                        x: center.x + cos(angle - spread) * rayLength,
                        y: center.y + sin(angle - spread) * rayLength
                    )
                    let right = CGPoint(
                        x: center.x + cos(angle + spread) * rayLength,
                        y: center.y + sin(angle + spread) * rayLength
                    )
                    let color = ray.isMultiple(of: 4) ? secondary : primary
                    context.fill(triangle(left, tip, right), with: .color(color.opacity(shimmer)))
                }

                // Soft central glow.
                let glowRadius = rayLength * 0.5
                let glowRect = CGRect(
                    x: center.x - glowRadius,
                    y: center.y - glowRadius,
                    width: glowRadius * 2,
                    height: glowRadius * 2
                )
                context.fill(
                    Path(ellipseIn: glowRect),
                    with: .radialGradient(
                        Gradient(colors: [primary.opacity(0.35), primary.opacity(0)]),
                        center: center,
                        startRadius: 0,
                        endRadius: glowRadius
                    )
                )

                // Drifting, twinkling gold glints.
                for index in 0..<46 {
                    let progress = (elapsed * 0.06 + Double(index) * 0.041).truncatingRemainder(dividingBy: 1)
                    let x = size.width * CGFloat((index * 53) % 100) / 100
                    let sway = CGFloat(sin(elapsed * 0.8 + Double(index)) * 22)
                    let y = size.height * CGFloat(progress)
                    let twinkle = 0.25 + 0.75 * abs(sin(elapsed * 3 + Double(index)))
                    let edgeFade = min(1, min(progress, 1 - progress) * 5)
                    let opacity = twinkle * Double(edgeFade)
                    guard opacity > 0.03 else {
                        continue
                    }

                    let outer = CGFloat(6 + index % 5 * 2)
                    let color = index.isMultiple(of: 5) ? secondary : primary
                    context.fill(
                        sparkleStar(centre: CGPoint(x: x + sway, y: y), outer: outer, inner: outer * 0.4),
                        with: .color(color.opacity(opacity))
                    )
                }
            }
        }
    }
}

// MARK: - Commit graph

/// A git graph that draws itself left-to-right: a main branch line with commit
/// nodes that pop in as a sweep passes, plus a side branch that splits off and
/// merges back. The most on-theme effect for a git celebration.
private struct CommitGraphCanvasView: View {
    let primary: Color
    let secondary: Color

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 40.0)) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                let sweep = (elapsed * 0.22).truncatingRemainder(dividingBy: 1)
                let leftX = size.width * 0.12
                let rightX = size.width * 0.88
                let sweepX = leftX + (rightX - leftX) * CGFloat(sweep)
                let mainY = size.height * 0.5
                let branchY = size.height * 0.34
                let nodeCount = 6

                func nodeX(_ index: Int) -> CGFloat {
                    leftX + (rightX - leftX) * CGFloat(index) / CGFloat(nodeCount - 1)
                }

                // Main branch line, revealed up to the sweep.
                var mainLine = Path()
                mainLine.move(to: CGPoint(x: leftX, y: mainY))
                mainLine.addLine(to: CGPoint(x: min(sweepX, rightX), y: mainY))
                context.stroke(mainLine, with: .color(primary.opacity(0.85)), style: StrokeStyle(lineWidth: 5, lineCap: .round))

                // Side branch: split at node 1, run along branchY, merge back at node 4.
                let splitX = nodeX(1)
                let mergeX = nodeX(4)
                var branch = Path()
                branch.move(to: CGPoint(x: splitX, y: mainY))
                branch.addCurve(
                    to: CGPoint(x: nodeX(2), y: branchY),
                    control1: CGPoint(x: splitX + 36, y: mainY),
                    control2: CGPoint(x: nodeX(2) - 36, y: branchY)
                )
                branch.addLine(to: CGPoint(x: nodeX(3), y: branchY))
                branch.addCurve(
                    to: CGPoint(x: mergeX, y: mainY),
                    control1: CGPoint(x: nodeX(3) + 36, y: branchY),
                    control2: CGPoint(x: mergeX - 36, y: mainY)
                )
                if sweepX > splitX {
                    var clipped = context
                    clipped.clip(to: Path(CGRect(x: 0, y: 0, width: sweepX, height: size.height)))
                    clipped.stroke(
                        branch,
                        with: .color(secondary.opacity(0.9)),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                    )
                }

                // Nodes pop in as the sweep reaches them.
                for index in 0..<nodeCount {
                    drawNode(context, x: nodeX(index), y: mainY, sweepX: sweepX, color: primary, baseRadius: 9)
                }
                for index in [2, 3] {
                    drawNode(context, x: nodeX(index), y: branchY, sweepX: sweepX, color: secondary, baseRadius: 8)
                }
            }
        }
    }

    private func drawNode(_ context: GraphicsContext, x: CGFloat, y: CGFloat, sweepX: CGFloat, color: Color, baseRadius: CGFloat) {
        guard x <= sweepX + 6 else {
            return
        }

        let settle = min(1, max(0, Double((sweepX - x) / 44)))
        let radius = baseRadius * (1 + 0.6 * (1 - settle))
        let point = CGPoint(x: x, y: y)

        let glowRadius = radius * 1.9
        let glow = CGRect(x: point.x - glowRadius, y: point.y - glowRadius, width: glowRadius * 2, height: glowRadius * 2)
        context.fill(
            Path(ellipseIn: glow),
            with: .radialGradient(
                Gradient(colors: [color.opacity(0.5), color.opacity(0)]),
                center: point,
                startRadius: 0,
                endRadius: glowRadius
            )
        )

        let dot = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        context.fill(Path(ellipseIn: dot), with: .color(color))
        context.stroke(Path(ellipseIn: dot), with: .color(.white), lineWidth: 2)
    }
}

// MARK: - Coin shower

/// Drawn gold coins falling and spinning (the ellipse width oscillates to fake a
/// 3D flip), each with a shine highlight. Treasure flair for the loot variant.
private struct CoinShowerCanvasView: View {
    let primary: Color   // gold
    let secondary: Color // bright accent

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 50.0)) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate

                for index in 0..<40 {
                    let progress = (elapsed * 0.3 + Double(index) * 0.05).truncatingRemainder(dividingBy: 1)
                    let x = size.width * CGFloat((index * 61) % 100) / 100
                    let drift = CGFloat(sin(elapsed * 0.6 + Double(index)) * 18)
                    let y = -40 + (size.height + 80) * CGFloat(progress)
                    let spin = elapsed * 4 + Double(index)
                    let squash = abs(sin(spin)) // 1 = face-on, 0 = edge-on
                    let radius = CGFloat(12 + index % 4 * 2)
                    let centre = CGPoint(x: x + drift, y: y)
                    let opacity = min(1, min(progress, 1 - progress) * 6)
                    guard opacity > 0.03 else {
                        continue
                    }

                    let width = max(2, radius * 2 * CGFloat(squash))
                    let face = CGRect(x: centre.x - width / 2, y: centre.y - radius, width: width, height: radius * 2)
                    let faceColor = sin(spin) >= 0 ? primary : secondary
                    context.fill(Path(ellipseIn: face), with: .color(faceColor.opacity(opacity)))
                    context.stroke(Path(ellipseIn: face), with: .color(.white.opacity(opacity * 0.7)), lineWidth: 1.5)

                    if squash > 0.45 {
                        let inner = CGRect(
                            x: centre.x - width * 0.28,
                            y: centre.y - radius * 0.5,
                            width: width * 0.56,
                            height: radius
                        )
                        context.stroke(Path(ellipseIn: inner), with: .color(.white.opacity(opacity * 0.45)), lineWidth: 1)

                        let shine = CGRect(
                            x: centre.x - width * 0.2,
                            y: centre.y - radius * 0.6,
                            width: width * 0.3,
                            height: radius * 0.5
                        )
                        context.fill(Path(ellipseIn: shine), with: .color(.white.opacity(opacity * 0.6)))
                    }
                }
            }
        }
    }
}

// MARK: - Aurora ribbon

/// Soft translucent gradient bands undulating across the top. Calm and premium
/// — a gentle signature for the minimal/ambient styles.
private struct AuroraRibbonCanvasView: View {
    let primary: Color
    let secondary: Color

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                let ribbonCount = 4
                let steps = 60

                for ribbon in 0..<ribbonCount {
                    let baseY = size.height * CGFloat(0.26 + Double(ribbon) * 0.13)
                    let amplitude = size.height * CGFloat(0.05 + Double(ribbon) * 0.015)
                    let thickness = size.height * 0.06
                    let phase = elapsed * (0.5 + Double(ribbon) * 0.12) + Double(ribbon)

                    func edgeY(_ t: CGFloat, offset: CGFloat) -> CGFloat {
                        baseY + amplitude * CGFloat(sin(Double(t) * .pi * 3 + phase)) + offset
                    }

                    var path = Path()
                    for step in 0...steps {
                        let t = CGFloat(step) / CGFloat(steps)
                        let point = CGPoint(x: size.width * t, y: edgeY(t, offset: 0))
                        step == 0 ? path.move(to: point) : path.addLine(to: point)
                    }
                    for step in stride(from: steps, through: 0, by: -1) {
                        let t = CGFloat(step) / CGFloat(steps)
                        path.addLine(to: CGPoint(x: size.width * t, y: edgeY(t, offset: thickness)))
                    }
                    path.closeSubpath()

                    let color = ribbon.isMultiple(of: 2) ? primary : secondary
                    context.fill(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [color.opacity(0.04), color.opacity(0.42), color.opacity(0.04)]),
                            startPoint: CGPoint(x: 0, y: baseY - amplitude),
                            endPoint: CGPoint(x: 0, y: baseY + amplitude + thickness)
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Hyperspace

/// Points of light streaking outward from a central vanishing point, getting
/// longer and brighter as they accelerate — a light-speed jump for push events.
private struct HyperspaceCanvasView: View {
    let primary: Color
    let secondary: Color

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let maxRadius = hypot(size.width, size.height) / 2

                for index in 0..<90 {
                    let progress = (elapsed * 0.6 + Double(index) * 0.0137).truncatingRemainder(dividingBy: 1)
                    let accel = progress * progress
                    let angle = Double(index) * 2.39996 // golden angle, even spread
                    let direction = CGVector(dx: cos(angle), dy: sin(angle))
                    let near = CGFloat(max(0, accel - 0.06)) * maxRadius
                    let far = CGFloat(accel) * maxRadius

                    var streak = Path()
                    streak.move(to: CGPoint(x: center.x + direction.dx * near, y: center.y + direction.dy * near))
                    streak.addLine(to: CGPoint(x: center.x + direction.dx * far, y: center.y + direction.dy * far))

                    let opacity = min(1, accel * 2)
                    let color: Color = index.isMultiple(of: 7) ? secondary : (index.isMultiple(of: 3) ? primary : .white)
                    context.stroke(
                        streak,
                        with: .color(color.opacity(opacity * 0.9)),
                        style: StrokeStyle(lineWidth: 1 + CGFloat(accel) * 2.5, lineCap: .round)
                    )
                }
            }
        }
    }
}

// MARK: - Drawing helpers

private func triangle(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Path {
    var path = Path()
    path.move(to: a)
    path.addLine(to: b)
    path.addLine(to: c)
    path.closeSubpath()
    return path
}

private func chevronUp(centre: CGPoint, span: CGFloat) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: centre.x - span, y: centre.y + span * 0.6))
    path.addLine(to: CGPoint(x: centre.x, y: centre.y - span * 0.6))
    path.addLine(to: CGPoint(x: centre.x + span, y: centre.y + span * 0.6))
    return path
}

/// A four-point sparkle (8 vertices: outer points on the axes, inner on the diagonals).
private func sparkleStar(centre: CGPoint, outer: CGFloat, inner: CGFloat) -> Path {
    var path = Path()
    for vertex in 0..<8 {
        let angle = Double(vertex) / 8 * .pi * 2 - .pi / 2
        let radius = vertex.isMultiple(of: 2) ? outer : inner
        let point = CGPoint(x: centre.x + CGFloat(cos(angle)) * radius, y: centre.y + CGFloat(sin(angle)) * radius)
        vertex == 0 ? path.move(to: point) : path.addLine(to: point)
    }
    path.closeSubpath()
    return path
}

private func celebrationColor(index: Int, primary: Color, secondary: Color) -> Color {
    switch index % 12 {
    case 0:
        primary
    case 1:
        secondary
    case 2:
        .yellow
    case 3:
        .mint
    case 4:
        .pink
    case 5:
        .green
    case 6:
        .orange
    case 7:
        .cyan
    case 8:
        .red
    case 9:
        .purple
    case 10:
        .blue
    default:
        .white
    }
}

private func confettiPath(index: Int, rect: CGRect) -> Path {
    switch index % 5 {
    case 0:
        return Path(ellipseIn: rect)
    case 1:
        return Path(roundedRect: rect, cornerRadius: 3)
    case 2:
        return triangle(
            CGPoint(x: rect.midX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.maxY)
        )
    case 3:
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    default:
        return Path(roundedRect: CGRect(x: rect.midX - 2, y: rect.minY, width: 4, height: rect.height * 1.6), cornerRadius: 2)
    }
}

private struct OverlayDetail {
    var repoLine: String?
    var subject: String?
    var metadata: String?

    init(subtitle: String?) {
        let parts = subtitle?.components(separatedBy: " - ") ?? []

        repoLine = parts.prefix(2).joined(separator: " - ")
        subject = parts.count > 2 ? parts[2] : nil
        metadata = parts.first(where: { $0.localizedStandardContains("pts") })
    }
}
