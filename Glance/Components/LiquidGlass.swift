import SwiftUI

extension View {
    /// The system's Liquid Glass on iOS 26 and later, which refracts and tints
    /// whatever scrolls beneath it and reacts to touch when `interactive`.
    /// `tint` darkens or colours it where the comp's control was a scrim —
    /// over a white tile, say, where clear glass would lose a white glyph.
    ///
    /// Earlier releases have no glass material, so they get `fallback` instead —
    /// handed the view itself, so a caller can keep the comp's flat treatment
    /// exactly as it was, overlays and all.
    @ViewBuilder
    func liquidGlass<S: Shape, Fallback: View>(
        in shape: S,
        tint: Color? = nil,
        interactive: Bool = false,
        otherwise fallback: (Self) -> Fallback
    ) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular.tint(tint).interactive(interactive), in: shape)
        } else {
            fallback(self)
        }
    }

    /// V7's secondary button, `CTA (New Project)`: a faint sheen inside a white
    /// hairline. With Liquid Glass it becomes the interactive glass Apple's
    /// secondary `.glass` button style draws — applied to the comp's own label,
    /// since that style would replace its type and padding with the system's.
    func secondaryGlass<S: InsettableShape>(
        in shape: S,
        hairline: Color = Color.white.opacity(0.2)
    ) -> some View {
        liquidGlass(in: shape, interactive: true) { view in
            view
                .background { shape.fill(LinearGradient.secondarySheen) }
                .overlay { shape.strokeBorder(hairline, lineWidth: 1) }
        }
    }
}

extension LinearGradient {
    /// `linear-gradient(rgba(255,231,231,0.005) 5%, rgba(255,255,255,0.08) 98%)`,
    /// run leading to trailing — the fill behind every V7 secondary button.
    static let secondarySheen = LinearGradient(
        stops: [
            .init(color: Color(red: 1, green: 231 / 255, blue: 231 / 255, opacity: 0.005), location: 0.049),
            .init(color: Color.white.opacity(0.08), location: 0.984)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}

/// Neighbouring glass, rendered together: glass can't sample other glass, so
/// the system draws a group from one shared read of what's beneath it.
/// Earlier releases just get the content.
struct GlassGroup<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer { content }
        } else {
            content
        }
    }
}
