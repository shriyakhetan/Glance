import SwiftUI

/// Blurred bar backing that dissolves downward instead of ending on a hard edge.
///
/// A plain `.background(.bar)` stops dead at the bar's bottom, drawing a crisp
/// line across the screen. `EdgeScrim` fades it out instead, and a negative
/// bottom padding bleeds the tail over the content below without reserving any
/// layout space for it.
struct FadingBarBackground: ViewModifier {
    /// How far the fade reaches past the bar.
    var fade: CGFloat = 40
    /// Where the scrim starts losing strength, as a fraction of total height.
    /// Short, so the black eases off almost immediately rather than sitting as
    /// a slab across the top of the screen.
    var hold: CGFloat = 0.18
    /// The ramp is `#000000` at full strength — the softness comes from how
    /// quickly it falls away, not from watering the colour down, which only
    /// leaves the material's grey showing through.
    var tint: Double = 1

    func body(content: Content) -> some View {
        content
            .background(alignment: .top) {
                EdgeScrim(edge: .top, hold: hold, tint: tint)
                    .padding(.bottom, -fade)
                    .ignoresSafeArea(edges: .top)
            }
    }
}

extension View {
    /// Pins a header's blurred backing and fades it out below the bar.
    func fadingBarBackground(fade: CGFloat = 40) -> some View {
        modifier(FadingBarBackground(fade: fade))
    }
}
