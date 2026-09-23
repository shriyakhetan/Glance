import SwiftUI

/// Progressive blur plus a black gradient, anchored to one edge and falling away
/// from it. Shared by the pinned headers and the bottom composer so the two
/// cannot drift apart.
///
/// A single uniform blur ends on a hard line across the content. Stacking masked
/// material layers — each reaching a little less far than the last — makes the
/// softening deepen toward the edge instead of switching on.
struct EdgeScrim: View {
    var edge: VerticalEdge = .top
    /// Fraction of the height held at full strength before the fade begins.
    /// A header holds through its own bar row; a bottom band holds nothing.
    var hold: CGFloat = 0
    /// Strength of the black ramp. The bottom band grades to solid `#000000`
    /// as the comp asks; a header only wants enough tint to keep its glyphs
    /// legible, and leaves the rest to the blur — which is what the system's
    /// own bars do.
    var tint: Double = 1

    /// How far each blur layer reaches, as a fraction of the height measured
    /// from the anchored edge.
    private let layerReach: [CGFloat] = [1, 0.66, 0.38]

    var body: some View {
        ZStack {
            ForEach(layerReach, id: \.self) { reach in
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .mask(ramp(to: reach))
            }
            // `linear-gradient(#000000 → transparent)` away from the edge.
            ramp(to: 1)
                .opacity(tint)
        }
        .allowsHitTesting(false)
    }

    /// Opaque black from the edge out to `hold`, clear by `reach`.
    private func ramp(to reach: CGFloat) -> LinearGradient {
        let stops: [Gradient.Stop] = [
            .init(color: .black, location: 0),
            .init(color: .black, location: min(hold, reach)),
            .init(color: .clear, location: reach)
        ]
        return LinearGradient(stops: oriented(stops), startPoint: .top, endPoint: .bottom)
    }

    /// Stops are authored as distance from the anchored edge, so a bottom-anchored
    /// scrim mirrors them before handing them to a top-to-bottom gradient.
    private func oriented(_ stops: [Gradient.Stop]) -> [Gradient.Stop] {
        switch edge {
        case .top:
            return stops
        case .bottom:
            return stops
                .reversed()
                .map { Gradient.Stop(color: $0.color, location: 1 - $0.location) }
        }
    }
}
