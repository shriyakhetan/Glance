import SwiftUI

/// Color tokens, mapped 1:1 from the `Foundations / Color` frame in Figma.
/// Hierarchy in this system comes from white-opacity levels, not from separate greys.
enum GlanceColor {

    // MARK: Background
    static let bgBase = Color(hex: 0x0D0D0D)
    static let bgSurface = Color(hex: 0x111111)
    static let bgSurfaceElevated = Color(hex: 0x2A2A2A)
    static let bgOverlaySubtle = Color.white.opacity(0.04)
    static let bgOverlay = Color.white.opacity(0.08)
    static let bgOverlayStrong = Color.white.opacity(0.10)
    static let bgScrim = Color.black.opacity(0.24)
    static let bgInverse = Color.white

    // MARK: Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.70)
    static let textTertiary = Color.white.opacity(0.60)
    static let textMuted = Color.white.opacity(0.50)
    static let textDisabled = Color.white.opacity(0.40)
    static let textInverse = Color(hex: 0x111111)
    static let textAccent = Color(hex: 0xBD9EFF)

    // MARK: Border
    static let borderSubtle = Color.white.opacity(0.10)
    static let borderDefault = Color.white.opacity(0.20)

    // MARK: Accent
    static let accentPrimary = Color(hex: 0xA48AFF)
    static let accentBold = Color(hex: 0x6B38FB)
    /// V7 `secondary` — the lavender of the signal card's label and avatar ring.
    static let accentSecondary = Color(hex: 0xC2B0FF)

    // MARK: Outline
    /// V7 `outlineVariant` — hairlines on the darkest surfaces.
    static let outlineVariant = Color(hex: 0x262626)
    /// V7 `outlineVariant` as the L2 comp (32:2523) sets it — the hairline on
    /// tiles, dividers and outlined buttons.
    static let hairline = Color(hex: 0x333333)

    // MARK: V7 roles
    /// V7 `tertiary` — a good read: what matches, a price under its usual, looks
    /// that are ready.
    static let positive = Color(hex: 0x4DDB85)
    /// V7 `error` — what doesn't match.
    static let negative = Color(hex: 0xFF6B6B)
    /// The saving on every product card — `(20% OFF)`.
    static let discount = Color(hex: 0xFF8787)
    /// V7 `surfaceBright` — a box set into a card.
    static let surfaceBright = Color(hex: 0x1A1A1A)

    // MARK: Feedback
    static let feedbackRating = Color(hex: 0xEAB308)
    static let feedbackSuccess = Color(hex: 0x1E6E31)
    static let feedbackWarning = Color(hex: 0x855D01)
    static let feedbackHighlight = Color(hex: 0xF3971B)
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
