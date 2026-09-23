import SwiftUI

/// Shared metrics, kept off the generic view so callers can read them without
/// naming a concrete `Accessory`.
enum AskGlanceBarMetrics {
    /// Distance from the pill to the physical bottom edge.
    static let bottomGap: CGFloat = Space.xl
    static let pillHeight: CGFloat = 56
    /// How far the blur reaches above the bar's own content.
    static let gradeRun: CGFloat = 70
    /// Layout room a scroll view should leave so its last item clears the bar.
    static var reservedHeight: CGFloat { bottomGap + pillHeight + Space.xl }
}

/// `Bottom New` (406:1419) — the Glance composer, pinned to the foot of a screen.
///
/// Shared by the home feed and the product screen; the latter passes its
/// suggestion chips as an `accessory` row above the pill. The band behind it is
/// `EdgeScrim`, the same progressive blur and ramp to `#000000` the pinned
/// headers use, mirrored to the bottom.
struct AskGlanceBar<Accessory: View>: View {
    var onAsk: () -> Void
    var onAttach: () -> Void
    /// Optional row shown above the pill, full-bleed so chips can scroll to the edge.
    @ViewBuilder var accessory: () -> Accessory

    private let pillWidth: CGFloat = 390

    var body: some View {
        VStack(spacing: Space.lg) {
            accessory()
            pill
                .frame(maxWidth: pillWidth)
                .padding(.horizontal, Space.lg)
        }
        .padding(.bottom, AskGlanceBarMetrics.bottomGap)
        .frame(maxWidth: .infinity)
        // A background costs no layout, so the band bleeds up over the content.
        .background(alignment: .bottom) { band }
    }

    // MARK: Band

    /// Bottom-anchored twin of the headers' scrim: same progressive blur, same
    /// ramp to `#000000`, mirrored.
    private var band: some View {
        EdgeScrim(edge: .bottom)
            .padding(.top, -AskGlanceBarMetrics.gradeRun)
    }

    // MARK: Pill

    private var pill: some View {
        let shape = RoundedRectangle(cornerRadius: 50, style: .continuous)
        return HStack(spacing: 0) {
            Button(action: onAsk) {
                HStack(spacing: 9) {
                    Image("ic-mascot-m")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 17.57)
                        .frame(width: 22, height: 22)
                    Text("Ask Glance")
                        .glanceText(.bodySMedium)
                        .foregroundStyle(GlanceColor.textSecondary)
                }
                .padding(.horizontal, Space.md)
                .frame(height: 22)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: Space.sm)

            Button(action: onAttach) {
                Image("ic-plus-thin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14.5, height: 14.5)
                    .padding(12)
                    .background(Circle().fill(GlanceColor.bgOverlay))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add an image")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .frame(height: AskGlanceBarMetrics.pillHeight)
        .background {
            shape
                .fill(Color(hex: 0x111111, opacity: 0.8))
                // `shadow(inset 0 4px 20px rgba(255,255,255,0.08))`
                .innerGlow(
                    shape,
                    radius: 20,
                    color: Color.white.opacity(0.08),
                    offset: CGSize(width: 0, height: 4)
                )
        }
        .overlay { shape.strokeBorder(Color.white.opacity(0.05), lineWidth: 1) }
        // `shadow(0 0 36px 8px #111)` — grounds the pill against the feed.
        .shadow(color: Color(hex: 0x111111), radius: 18)
    }
}

extension AskGlanceBar where Accessory == EmptyView {
    init(onAsk: @escaping () -> Void, onAttach: @escaping () -> Void) {
        self.init(onAsk: onAsk, onAttach: onAttach) { EmptyView() }
    }
}
