import SwiftUI

/// Spacing — 4px base grid, from `Foundations / Spacing & Radius`.
enum Space {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 6
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

/// Corner radius scale.
enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    /// Full-round; use with `Capsule()` where possible.
    static let pill: CGFloat = 999
}

/// Named effects from the Figma styles.
enum GlanceShadow {
    /// `Shadow/Card` — 0 0 16 #00000014
    static func card<V: View>(_ view: V) -> some View {
        view.shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 0)
    }

    /// `Shadow/Floating` — 0 0 20 #00000066
    static func floating<V: View>(_ view: V) -> some View {
        view.shadow(color: .black.opacity(0.40), radius: 10, x: 0, y: 0)
    }
}

extension View {
    func glanceCardShadow() -> some View { GlanceShadow.card(self) }
    func glanceFloatingShadow() -> some View { GlanceShadow.floating(self) }
}

/// `Gradient/Image Scrim` — the fade that lets text sit on a photo.
struct ImageScrim: View {
    var height: CGFloat = 90
    var body: some View {
        LinearGradient(
            colors: [Color(hex: 0x111111, opacity: 0), Color(hex: 0x111111, opacity: 0.4)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: height)
    }
}

/// The bottom-anchored fade used on `Rational` cards, tinted to the card's own colour.
struct CardScrim: View {
    let tint: Color
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: tint.opacity(0), location: 0.7),
                .init(color: tint, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
