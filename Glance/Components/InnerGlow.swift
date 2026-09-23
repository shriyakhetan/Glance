import SwiftUI

/// CSS-style `box-shadow: inset 0 0 <radius> <colour>`, which SwiftUI has no
/// native equivalent for.
///
/// The light has to peak **at** the edge and decay inward. `strokeBorder` sits
/// wholly inside the shape, so blurring it drags the peak inward and smears the
/// falloff over roughly twice the distance — the card then reads as a broad
/// vignette rather than a lit rim. Stroking *centred* on the path and clipping
/// back to the shape throws away the outer half, leaving the maximum on the
/// boundary, which is exactly what an inset shadow does.
///
/// Measured against `training-banner` (338:308) at `inset 0 0 34 #FFFFFF2B`:
/// the comp peaks just inside the border and reaches the flat fill ~28pt in.
struct InnerGlow<S: Shape>: ViewModifier {
    let shape: S
    /// The CSS blur radius.
    var radius: CGFloat
    var color: Color
    /// The CSS shadow offset, if the light is pushed off-centre.
    var offset: CGSize = .zero

    /// Once the outer half of the stroke is clipped away, the light reads
    /// stronger at the boundary than CSS does. Measured against 338:308, the
    /// comp's peak is ~60% of what the nominal alpha renders here.
    private let edgeFactor: Double = 0.6

    func body(content: Content) -> some View {
        content.overlay {
            shape
                .stroke(color.opacity(edgeFactor), lineWidth: radius * 0.88)
                .blur(radius: radius * 0.41)
                .offset(x: offset.width, y: offset.height)
                .clipShape(shape)
                .allowsHitTesting(false)
        }
    }
}

extension View {
    /// Applies an inset-shadow style glow just inside `shape`'s edge.
    func innerGlow<S: Shape>(_ shape: S, radius: CGFloat, color: Color, offset: CGSize = .zero) -> some View {
        modifier(InnerGlow(shape: shape, radius: radius, color: color, offset: offset))
    }
}
