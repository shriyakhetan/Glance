import SwiftUI

/// Shared metrics, kept off the generic view so callers can read them without
/// naming a concrete `Accessory`.
enum AskGlanceBarMetrics {
    /// Distance from the pill to the physical bottom edge.
    static let bottomGap: CGFloat = Space.xl
    static let pillHeight: CGFloat = 48
    /// How far the band reaches above the bar's own content — the comp's
    /// 140pt frame less the pill and the gap beneath it.
    static let gradeRun: CGFloat = 68
    /// `Chat options` on L2 (32:1700): 24pt chips, 12pt above the pill.
    static let chipHeight: CGFloat = 24
    static let chipGap: CGFloat = Space.md
    /// Layout room a scroll view should leave so its last item clears the bar.
    static var reservedHeight: CGFloat { bottomGap + pillHeight + Space.xl }
    /// The same, with the L2 chips riding above the pill.
    static var reservedHeightWithChips: CGFloat { reservedHeight + chipHeight + chipGap }
}

/// The composer's states (V7, 32:1614): one for each point in the journey the
/// bar is seen at, named as Figma names them.
enum AskGlanceStage: Equatable {
    /// `Before Onboarding` (32:1615) — the pill alone.
    case beforeOnboarding
    /// `Feed Ready` (32:1623) — the selfie is in: the mascot leads, calling out
    /// what it unlocked.
    case feedReady
    /// `1st Time Generation` (32:1644) — the first looks are being made, with
    /// the time left until `until`.
    case firstGeneration(until: Date)
    /// `Feed is Ready` (32:1656) — they're done, with a callout to refresh.
    case feedIsReady
    /// `After Onboarding` (32:1680) — My Looks ahead of the pill.
    case afterOnboarding
    /// `on L2` (32:1692) — the bare pill, with a product's chips above it.
    case onL2
}

extension AskGlanceStage {
    /// For `--askStage`: the case names above. `firstGeneration` starts on the
    /// comp's 2:59.
    init?(debugName: String) {
        switch debugName {
        case "beforeOnboarding": self = .beforeOnboarding
        case "feedReady": self = .feedReady
        case "firstGeneration": self = .firstGeneration(until: .now.addingTimeInterval(179))
        case "feedIsReady": self = .feedIsReady
        case "afterOnboarding": self = .afterOnboarding
        case "onL2": self = .onL2
        default: return nil
        }
    }
}

/// The Glance composer, pinned to the foot of a screen: a dark pill reading
/// like an empty text field, with the attach control at its leading end, and a
/// round control ahead of it once there are looks to show.
///
/// That control is the way into My Looks in every stage that has one — the
/// mascot, the countdown, the check, the My Looks glyph — so a stage changes
/// what it shows, never where it goes.
struct AskGlanceBar<Accessory: View>: View {
    var stage: AskGlanceStage
    var onAsk: () -> Void
    var onAttach: () -> Void
    var onMyLooks: () -> Void
    /// `TAP TO REFRESH` on the `Feed is Ready` callout.
    var onRefresh: () -> Void
    /// Optional row shown above the pill, full-bleed so chips can scroll to the edge.
    var accessory: Accessory

    /// A callout stays closed once dismissed, until the bar moves on.
    @State private var dismissedCallout: AskGlanceStage?

    /// The comp's 364pt row on a 412pt screen; capped on wider canvases.
    private let rowWidth: CGFloat = 390
    private let side = AskGlanceBarMetrics.pillHeight

    init(
        stage: AskGlanceStage = .beforeOnboarding,
        onAsk: @escaping () -> Void,
        onAttach: @escaping () -> Void,
        onMyLooks: @escaping () -> Void = {},
        onRefresh: @escaping () -> Void = {},
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.stage = stage
        self.onAsk = onAsk
        self.onAttach = onAttach
        self.onMyLooks = onMyLooks
        self.onRefresh = onRefresh
        self.accessory = accessory()
    }

    var body: some View {
        VStack(spacing: AskGlanceBarMetrics.chipGap) {
            // Full-bleed within the content column, so chips still scroll to
            // the edge of the column on a wide screen instead of to the edge
            // of an iPad.
            accessory
                .glanceContentColumn()

            // The comp hangs a callout 10pt over the row, 8pt proud of it.
            VStack(alignment: .leading, spacing: 10) {
                if showsCallout {
                    callout
                        .offset(x: -8)
                        .transition(.scale(scale: 0.85, anchor: .bottomLeading).combined(with: .opacity))
                }
                controls
            }
            .frame(maxWidth: rowWidth)
            .padding(.horizontal, Space.xl)
        }
        .padding(.bottom, AskGlanceBarMetrics.bottomGap)
        .frame(maxWidth: .infinity)
        // A background costs no layout, so the band bleeds up over the content.
        .background(alignment: .bottom) { band }
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: stage)
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: dismissedCallout)
        .onChange(of: stage) { dismissedCallout = nil }
    }

    // MARK: Band

    /// Before Liquid Glass: clear at the top, solid black from 80% of the way
    /// down — a plain ramp, with no blur under it.
    ///
    /// With it, a black floor would leave the glass nothing to refract and the
    /// pill would read as a flat dark capsule, so the band softens to the blur
    /// and light tint the system's own bars sit on, and the feed shows through.
    private var band: some View {
        Group {
            if #available(iOS 26.0, *) {
                EdgeScrim(edge: .bottom, tint: 0.5)
            } else {
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0), location: 0),
                        .init(color: .black, location: 0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .padding(.top, -AskGlanceBarMetrics.gradeRun)
        .allowsHitTesting(false)
    }

    // MARK: Row

    /// `Nav Options` — the leading control, 12pt, then the pill.
    private var controls: some View {
        GlassGroup {
            HStack(spacing: Space.md) {
                leading
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
                pill
            }
        }
    }

    @ViewBuilder
    private var leading: some View {
        switch stage {
        case .beforeOnboarding, .onL2:
            EmptyView()
        case .feedReady:
            roundControl(label: "My Looks") { FillerMascot(side: 30) }
        case .firstGeneration(let until):
            generationCountdown(until: until)
        case .feedIsReady:
            roundControl(label: "My Looks, ready") { ReadyCheck() }
        case .afterOnboarding:
            roundControl(label: "My Looks") { myLooksGlyph }
        }
    }

    /// A 48pt round control in the pill's own finish.
    private func roundControl<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        Button(action: onMyLooks) {
            content()
                .frame(width: side, height: side)
                .composerSurface(in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    /// `My Looks` (32:1682).
    private var myLooksGlyph: some View {
        Image("ic-my-looks")
            .resizable()
            .frame(width: 19.41, height: 20.27)
            // Where the glyph sits in its 24pt box (32:1749): a little left of
            // centre and just over a point low.
            .offset(x: -0.6, y: 1.13)
    }

    /// `Create My Looks` (32:1646) — the star loader and the time left, in a
    /// capsule of the pill's finish.
    private func generationCountdown(until: Date) -> some View {
        Button(action: onMyLooks) {
            HStack(spacing: Space.xxs) {
                StarLoader()
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    CountdownText(remaining: until.timeIntervalSince(context.date))
                }
            }
            .padding(.leading, 9)
            .padding(.trailing, 13)
            .frame(height: side)
            .composerSurface(in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: Pill

    private var pill: some View {
        HStack(spacing: 0) {
            Button(action: onAttach) {
                // The exported icon is the whole 48pt target, the glyph centred
                // in it, so it needs no padding of its own.
                Image("ic-plus-composer")
                    .resizable()
                    .frame(width: side, height: side)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add an image")

            Button(action: onAsk) {
                // The bar stands in for a text field, and the leading bar is
                // its idle caret — it is part of the placeholder in the comp.
                Text("| Ask Glance")
                    .font(.custom(GlanceTypeface.manropeMedium, size: 12))
                    .foregroundStyle(GlanceColor.textTertiary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.trailing, Space.lg)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Ask Glance")
        }
        .frame(height: side)
        .composerSurface(in: Capsule())
    }

    // MARK: Callouts

    private var showsCallout: Bool {
        (stage == .feedReady || stage == .feedIsReady) && dismissedCallout != stage
    }

    @ViewBuilder
    private var callout: some View {
        switch stage {
        case .feedReady: unlockedCallout
        case .feedIsReady: readyCallout
        default: EmptyView()
        }
    }

    /// `t1` (32:1634). The comp frosts it — a backdrop blur under a faint fill
    /// and a hairline — so it is glass here.
    private var unlockedCallout: some View {
        let shape = Callout.shape

        return HStack(spacing: 7) {
            Text("Your selfie unlocked something special !")
                .glanceText(.bodyCaption)
                .foregroundStyle(GlanceColor.textPrimary)
                .lineLimit(1)
            GiftGlyph()
        }
        .padding(.leading, 15)
        .padding(.trailing, 9)
        .frame(height: Callout.bodyHeight)
        .padding(.bottom, shape.tailHeight)
        .fixedSize()
        .background(alignment: .topLeading) { CalloutSheen() }
        .clipShape(shape)
        .liquidGlass(in: shape) { callout in
            callout
                .background { shape.fill(Color.white.opacity(0.1)) }
                .background(.ultraThinMaterial, in: shape)
                .overlay { shape.strokeBorder(Color.white.opacity(0.2), lineWidth: 1) }
        }
    }

    /// `Your look is ready` (32:1668) — solid white, with the refresh as a
    /// black pill and a close button hung on its corner.
    private var readyCallout: some View {
        let shape = Callout.shape

        return HStack(spacing: 18) {
            Text("Your looks are ready.")
                .glanceText(.bodyCaption)
                .foregroundStyle(Color.black)
                .lineLimit(1)
            Button(action: onRefresh) {
                Text("TAP TO REFRESH")
                    .font(.custom(GlanceTypeface.manropeSemiBold, size: 8))
                    .tracking(0.4)
                    .foregroundStyle(Color.white)
                    .padding(.leading, 10)
                    .padding(.trailing, 9)
                    .frame(height: 24)
                    .background(Color.black, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 13)
        .padding(.trailing, 17)
        .frame(height: Callout.bodyHeight)
        .padding(.bottom, shape.tailHeight)
        .fixedSize()
        .background { shape.fill(Color.white) }
        .overlay { shape.strokeBorder(GlanceColor.hairline, lineWidth: 1) }
        .overlay(alignment: .topTrailing) {
            Button { dismissedCallout = stage } label: {
                Image("ic-callout-close")
                    .resizable()
                    .frame(width: 18, height: 18)
                    // A 44pt target around the 18pt disc.
                    .padding(13)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")
            // Centred on the right edge, a point below the top, as the comp
            // hangs it — less the target's padding.
            .offset(x: 9 + 13, y: -8 - 13)
        }
    }
}

extension AskGlanceBar where Accessory == EmptyView {
    init(
        stage: AskGlanceStage = .beforeOnboarding,
        onAsk: @escaping () -> Void,
        onAttach: @escaping () -> Void,
        onMyLooks: @escaping () -> Void = {},
        onRefresh: @escaping () -> Void = {}
    ) {
        self.init(stage: stage, onAsk: onAsk, onAttach: onAttach, onMyLooks: onMyLooks, onRefresh: onRefresh) {
            EmptyView()
        }
    }
}

/// `Chat options` (32:1700) — the prompts that ride above the pill on L2. They
/// are V7's secondary buttons, so on iOS 26 they're the system's secondary glass.
struct AskGlanceChips: View {
    let titles: [String]
    var action: (String) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            GlassGroup {
                HStack(spacing: Space.sm) {
                    ForEach(titles, id: \.self) { title in
                        Button { action(title) } label: {
                            Text(title)
                                .glanceText(.labelSmall)
                                .foregroundStyle(GlanceColor.textPrimary)
                                .padding(.horizontal, Space.md)
                                .frame(height: AskGlanceBarMetrics.chipHeight)
                                .secondaryGlass(in: Capsule())
                                .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Space.xl)
            }
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Parts

/// Both callouts' outline (32:1635, 32:1670): an 8pt body over a tail that
/// points down at the leading control.
private enum Callout {
    static let shape = PointerBubble(cornerRadius: Radius.sm, tailX: 35.68, tailWidth: 18.28, tailHeight: 7.98)
    static let bodyHeight: CGFloat = 42
}

private extension View {
    /// The composer's own finish: glass, or the comp's near-black lit by
    /// `Inner Glow/Soft` — 20pt of white at 15% inside the edge.
    func composerSurface<S: InsettableShape>(in shape: S) -> some View {
        liquidGlass(in: shape, interactive: true) { control in
            control
                .background {
                    shape
                        .fill(GlanceColor.bgBase)
                        .innerGlow(shape, radius: 20, color: Color.white.opacity(0.15))
                }
                .overlay { shape.strokeBorder(Color.white.opacity(0.05), lineWidth: 1) }
        }
    }
}

/// The `Feed is Ready` check (32:1658): a 24pt disc in V7 `tertiary`, lit by
/// its own green, with the tick drawn where the comp draws it.
private struct ReadyCheck: View {
    var body: some View {
        Circle()
            .fill(GlanceColor.positive)
            .frame(width: 24, height: 24)
            .shadow(color: GlanceColor.positive.opacity(0.2), radius: 6)
            .overlay {
                Tick()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 1.66, lineCap: .round, lineJoin: .round))
            }
    }

    /// `Vector 9893`, in the disc's own 24pt space.
    private struct Tick: Shape {
        func path(in rect: CGRect) -> Path {
            let unit = rect.width / 24
            var path = Path()
            path.move(to: CGPoint(x: 8.61 * unit, y: 12.73 * unit))
            path.addLine(to: CGPoint(x: 10.60 * unit, y: 14.73 * unit))
            path.addLine(to: CGPoint(x: 16.17 * unit, y: 9.39 * unit))
            return path
        }
    }
}

/// `Star Loader 2` (32:1647). The comp's loader is an animation Figma can't
/// export, so the composer's sparkle stands in, breathing while it works.
private struct StarLoader: View {
    var body: some View {
        Image("ic-style-me")
            .resizable()
            .frame(width: 18, height: 18)
            .phaseAnimator([false, true]) { star, lit in
                star
                    .scaleEffect(lit ? 1 : 0.82)
                    .opacity(lit ? 1 : 0.55)
            } animation: { _ in
                .easeInOut(duration: 0.9)
            }
            .frame(width: 20, height: 20)
            .accessibilityHidden(true)
    }
}

/// `02:59` — minutes and colon in bold, seconds a weight down, as the comp sets
/// them, on tabular figures so the count doesn't jitter.
private struct CountdownText: View {
    let remaining: TimeInterval

    var body: some View {
        let seconds = max(0, Int(remaining.rounded(.up)))
        let minutes = String(format: "%02d:", seconds / 60)
        let rest = String(format: "%02d", seconds % 60)

        Text("\(Text(minutes).font(.custom(GlanceTypeface.manropeBold, size: 13)))\(Text(rest).font(.custom(GlanceTypeface.manropeSemiBold, size: 13)))")
            .monospacedDigit()
            .foregroundStyle(GlanceColor.textPrimary)
            .accessibilityLabel("Creating your looks, \(seconds / 60) minutes \(seconds % 60) seconds left")
    }
}

/// `image 5472/5473` — the gift, over a blurred copy of itself for its glow.
private struct GiftGlyph: View {
    var body: some View {
        ZStack {
            Image("ic-gift").resizable().blur(radius: 4.2)
            Image("ic-gift").resizable()
        }
        .frame(width: 18, height: 18)
        .accessibilityHidden(true)
    }
}

/// `Frame 2147239012` — the lavender wash in the `Feed Ready` callout's top
/// left: an ellipse at 60%, blurred almost to nothing.
private struct CalloutSheen: View {
    var body: some View {
        Ellipse()
            .fill(GlanceColor.accentSecondary.opacity(0.6))
            .frame(width: 110, height: 40)
            .rotationEffect(.degrees(50.12))
            .position(x: 112, y: -30)
            .blur(radius: 50)
            .frame(width: 229, height: 41)
            .allowsHitTesting(false)
    }
}
