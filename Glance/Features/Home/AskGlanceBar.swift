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
    /// Layout room a scroll view should leave so its last item clears the bar.
    static var reservedHeight: CGFloat { bottomGap + pillHeight + Space.xl }
}

/// `Before Onboarding` (V7, 2:1149) — the Glance composer, pinned to the foot
/// of a screen: a dark pill reading like an empty text field, with the attach
/// control at its leading end.
///
/// Shared by the home feed and the product screen; the latter passes its
/// suggestion chips as an `accessory` row above the pill.
struct AskGlanceBar<Accessory: View>: View {
    var onAsk: () -> Void
    var onAttach: () -> Void
    /// Optional row shown above the pill, full-bleed so chips can scroll to the edge.
    @ViewBuilder var accessory: () -> Accessory

    /// The comp's 364pt pill on a 412pt screen; capped on wider canvases.
    private let pillWidth: CGFloat = 390

    var body: some View {
        VStack(spacing: Space.lg) {
            // Full-bleed within the content column, so chips still scroll to
            // the edge of the column on a wide screen instead of to the edge
            // of an iPad.
            accessory()
                .glanceContentColumn()
            pill
                .frame(maxWidth: pillWidth)
                .padding(.horizontal, Space.xl)
        }
        .padding(.bottom, AskGlanceBarMetrics.bottomGap)
        .frame(maxWidth: .infinity)
        // A background costs no layout, so the band bleeds up over the content.
        .background(alignment: .bottom) { band }
    }

    // MARK: Band

    /// Clear at the top, solid black from 80% of the way down — a plain ramp,
    /// with no blur under it.
    private var band: some View {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(0), location: 0),
                .init(color: .black, location: 0.8)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .padding(.top, -AskGlanceBarMetrics.gradeRun)
        .allowsHitTesting(false)
    }

    // MARK: Pill

    private var pill: some View {
        let shape = Capsule()

        return HStack(spacing: 0) {
            Button(action: onAttach) {
                // The exported icon is the whole 48pt target, the glyph centred
                // in it, so it needs no padding of its own.
                Image("ic-plus-composer")
                    .resizable()
                    .frame(width: AskGlanceBarMetrics.pillHeight, height: AskGlanceBarMetrics.pillHeight)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add an image")

            Button(action: onAsk) {
                // The bar stands in for a text field, and the leading bar is
                // its idle caret — it is part of the placeholder in the comp.
                Text("| Ask Glance")
                    .font(.custom(GlanceTypeface.interMedium, size: 12))
                    .foregroundStyle(GlanceColor.textTertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.trailing, Space.lg)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Ask Glance")
        }
        .frame(height: AskGlanceBarMetrics.pillHeight)
        .background {
            shape
                .fill(GlanceColor.bgBase)
                // `Inner Glow/Soft` — 20pt of white at 15% inside the edge.
                .innerGlow(shape, radius: 20, color: Color.white.opacity(0.15))
        }
        .overlay { shape.strokeBorder(Color.white.opacity(0.05), lineWidth: 1) }
    }
}

extension AskGlanceBar where Accessory == EmptyView {
    init(onAsk: @escaping () -> Void, onAttach: @escaping () -> Void) {
        self.init(onAsk: onAsk, onAttach: onAttach) { EmptyView() }
    }
}
