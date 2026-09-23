import SwiftUI

/// The `Glow` layer behind the profile hero (338:174).
///
/// It is not a purple gradient — it is a **dark arch lit only at its rim**. In
/// Figma: a 640pt-wide rectangle whose top corners are rounded 360 (clamped to
/// 320, half the width, so the crown is a true semicircle), filled `#0E0A19`,
/// with one outer shadow above the crown and three inner shadows spilling purple
/// down the inside of the top edge.
///
/// Sampling the comp shows the inner falloff is purely a function of distance
/// from the crown circle's centre — the same radius gives the same colour no
/// matter where you measure along the arc. So rather than fake three inset
/// shadows with blurred strokes, one `RadialGradient` centred on that circle
/// reproduces it, with stops read off the comp.
///
/// The comp is a still. The only motion is the scroll response — the layer dims
/// and drifts up as the page moves — plus a slow breath in the rim. It animates
/// opacity, offset and scale, which the render server handles on its own, so the
/// expensive blurred layers are never redrawn.
struct ArchGlow: View {
    /// The comp's 640pt arch. Wider than the screen on purpose: only the crown
    /// shows, and the straight sides fall outside the viewport.
    static let width: CGFloat = 640

    /// 0 at rest, growing as the page scrolls away. Dims the glow and lets it
    /// drift up behind the content.
    var scroll: CGFloat = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathing = false

    /// Figma asks for 360 but clamps to half the width.
    private let crown: CGFloat = 320
    /// Height of the band the rim glow is painted into. The glow dies well
    /// inside this, and bounding it keeps the gradient from repeating its final
    /// colour across the arch's deep interior.
    private let glowBand: CGFloat = 400

    private let rim = Color(hex: 0xBE8CFF)

    /// Full strength at the top of the page, easing to a floor as it scrolls —
    /// the hero's light shouldn't keep shouting over the cards below it.
    private var scrollDim: Double {
        let travel = max(0, min(1, scroll / 520))
        return 1 - 0.45 * travel
    }

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: crown,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: crown,
            style: .circular
        )
    }

    var body: some View {
        shape
            .fill(Color(hex: 0x0E0A19))
            // `shadow(0 -5px 50px -10px #b786ff)` — halo spilling above the crown.
            .shadow(color: Color(hex: 0xB786FF, opacity: 0.5 * (breathing ? 1 : 0.72)), radius: 18, x: 0, y: -5)
            .overlay(alignment: .top) { spill }
            .opacity(scrollDim)
            // A touch of parallax: the glow lags the content rather than being
            // pinned to the screen.
            .offset(y: -scroll * 0.08)
            .allowsHitTesting(false)
            .onAppear(perform: start)
    }

    /// The rim light itself, breathing very slightly in and out.
    private var spill: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    // Alphas measured off the comp at radii 212 / 246 /
                    // 282 / 320, mapped onto a 200…320 radius span.
                    stops: [
                        .init(color: rim.opacity(0), location: 0),
                        .init(color: rim.opacity(0.03), location: 0.10),
                        .init(color: rim.opacity(0.14), location: 0.383),
                        .init(color: rim.opacity(0.38), location: 0.683),
                        .init(color: rim.opacity(1), location: 1)
                    ],
                    center: UnitPoint(x: 0.5, y: crown / glowBand),
                    startRadius: 200,
                    endRadius: crown
                )
            )
            .frame(height: glowBand)
            .opacity(breathing ? 1 : 0.86)
            // Scaling from the crown's own centre keeps the arc's edge pinned
            // and moves only the light inside it.
            .scaleEffect(breathing ? 1.02 : 0.99, anchor: UnitPoint(x: 0.5, y: crown / glowBand))
            // A rounded-top rect has the same crown silhouette at any
            // height, so clipping within this band matches the arch.
            .clipShape(shape)
    }

    private func start() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 7.5).repeatForever(autoreverses: true)) {
            breathing = true
        }
    }
}
