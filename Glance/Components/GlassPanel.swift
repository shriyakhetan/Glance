import SwiftUI

/// The recurring panel treatment on the product screen: a near-black translucent
/// fill lit by an inset rim of white — `rgba(33,32,32,0.2)` plus
/// `shadow(inset 0 0 20 rgba(255,255,255,0.15))` in Figma.
struct GlassPanel: ViewModifier {
    var cornerRadius: CGFloat = Radius.xl
    var rimOpacity: Double = 0.15
    /// The CSS blur radius of the inset shadow.
    var rimRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background {
                let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                shape
                    .fill(Color(hex: 0x212020, opacity: 0.2))
                    .innerGlow(shape, radius: rimRadius, color: Color.white.opacity(rimOpacity))
            }
    }
}

extension View {
    func glassPanel(cornerRadius: CGFloat = Radius.xl, rimOpacity: Double = 0.15, rimRadius: CGFloat = 20) -> some View {
        modifier(GlassPanel(cornerRadius: cornerRadius, rimOpacity: rimOpacity, rimRadius: rimRadius))
    }
}

/// Page dots for the review and image carousels.
struct PageDots: View {
    let count: Int
    let index: Int

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<count, id: \.self) { position in
                Capsule()
                    .fill(position == index ? GlanceColor.textPrimary : Color.white.opacity(0.25))
                    .frame(width: position == index ? 16 : 5, height: 5)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: index)
            }
        }
    }
}
