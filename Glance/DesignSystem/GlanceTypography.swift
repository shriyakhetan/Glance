import SwiftUI
import UIKit

/// The two type voices from `Foundations / Typography`.
/// Inter is the UI voice — labels, data, actions.
/// Libre Caslon Text is the editorial voice — headlines, quotes, occasion moments.
/// Never mix voices inside one component.
enum GlanceTypeface {
    static let interLight = "Inter-Light"
    static let interRegular = "Inter-Regular"
    static let interMedium = "Inter-Medium"
    static let interSemiBold = "Inter-SemiBold"
    static let interBold = "Inter-Bold"
    static let interExtraBold = "Inter-ExtraBold"

    static let serifRegular = "LibreCaslonText-Regular"
    static let serifMedium = "LibreCaslonText-Medium"
    static let serifBold = "LibreCaslonText-Bold"
    static let serifItalic = "LibreCaslonText-Italic"
    static let serifBoldItalic = "LibreCaslonText-BoldItalic"
}

/// A resolved text style: face, size, target line height and tracking.
struct GlanceTextStyle {
    let face: String
    let size: CGFloat
    /// Target line height in points. `nil` means "use the font's natural leading".
    let lineHeight: CGFloat?
    /// Letter spacing in points.
    let tracking: CGFloat
    let uppercased: Bool

    init(_ face: String, _ size: CGFloat, lineHeight: CGFloat? = nil, tracking: CGFloat = 0, uppercased: Bool = false) {
        self.face = face
        self.size = size
        self.lineHeight = lineHeight
        self.tracking = tracking
        self.uppercased = uppercased
    }

    var font: Font { .custom(face, size: size) }

    /// Extra spacing SwiftUI must add between lines to reach `lineHeight`.
    var lineSpacing: CGFloat {
        guard let lineHeight else { return 0 }
        let natural = UIFont(name: face, size: size)?.lineHeight ?? size * 1.2
        return max(0, lineHeight - natural)
    }
}

// MARK: - The scale

extension GlanceTextStyle {

    // Display — Libre Caslon Text, the editorial voice.

    /// Editorial hero moments — occasion titles, pull quotes (Date Night).
    static let displayFeature = GlanceTextStyle(GlanceTypeface.serifBoldItalic, 24, lineHeight: 28.8, tracking: 0.48)
    /// Greetings and card headlines.
    static let displayL = GlanceTextStyle(GlanceTypeface.serifMedium, 20)
    /// Section titles inside cards, brand names.
    static let displayM = GlanceTextStyle(GlanceTypeface.serifRegular, 16)
    /// Supporting editorial lines, blurbs, small serif accents.
    static let displayS = GlanceTextStyle(GlanceTypeface.serifRegular, 14, lineHeight: 19.6)
    /// Italic editorial accent (`3 Step ~ Morning Routine`).
    static let displaySItalic = GlanceTextStyle(GlanceTypeface.serifItalic, 14)

    // Heading — Inter.

    /// Light large numerals — secondary stats.
    static let headingXLRegular = GlanceTextStyle(GlanceTypeface.interRegular, 24)
    /// Large stats and hero numerals (4.2, 94%).
    static let headingXL = GlanceTextStyle(GlanceTypeface.interExtraBold, 24, lineHeight: 26.4)
    /// Screen titles and modal headers.
    static let headingL = GlanceTextStyle(GlanceTypeface.interSemiBold, 16, lineHeight: 22)
    /// Card titles, product names, strong inline emphasis.
    static let headingM = GlanceTextStyle(GlanceTypeface.interSemiBold, 14)
    /// Insight titles, callouts, emphasized rows.
    static let headingS = GlanceTextStyle(GlanceTypeface.interSemiBold, 12, lineHeight: 14.4)

    // Body — Inter.

    /// Primary reading text, review bodies.
    static let bodyM = GlanceTextStyle(GlanceTypeface.interRegular, 14, lineHeight: 20)
    /// Default UI text — descriptions, list rows.
    static let bodyS = GlanceTextStyle(GlanceTypeface.interRegular, 12)
    /// Chips, buttons, links, emphasized rows.
    static let bodySMedium = GlanceTextStyle(GlanceTypeface.interMedium, 12, lineHeight: 18)
    /// Airy editorial body inside feed cards.
    static let bodySLight = GlanceTextStyle(GlanceTypeface.interLight, 12)

    // Caption — Inter.

    /// Metadata, timestamps, footnotes, delivery info.
    static let captionRegular = GlanceTextStyle(GlanceTypeface.interRegular, 10, lineHeight: 16)
    /// Small labels with mild emphasis.
    static let captionMedium = GlanceTextStyle(GlanceTypeface.interMedium, 10)
    /// Prices, percentages, and stats at small sizes.
    static let captionBold = GlanceTextStyle(GlanceTypeface.interBold, 10, lineHeight: 14, tracking: 4)

    // Label — Inter, auto-uppercased.

    /// Uppercase section titles — MY VISUAL SOURCES, WHAT GLANCE KNOWS.
    static let labelSection = GlanceTextStyle(GlanceTypeface.interBold, 10, lineHeight: 14, tracking: 4, uppercased: true)
    /// Smallest tracked uppercase — card tags (BEAUTY, 95% MATCH).
    static let labelOverline = GlanceTextStyle(GlanceTypeface.interSemiBold, 8, lineHeight: 11.2, tracking: 0.4, uppercased: true)
}

// MARK: - Applying a style

private struct GlanceTextStyleModifier: ViewModifier {
    let style: GlanceTextStyle

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing)
    }
}

extension View {
    func glanceText(_ style: GlanceTextStyle) -> some View {
        modifier(GlanceTextStyleModifier(style: style))
    }
}

extension Text {
    /// Builds a `Text` in the given style. Label styles uppercase automatically —
    /// type naturally, the style does the shouting.
    init(_ string: String, style: GlanceTextStyle) {
        self.init(style.uppercased ? string.uppercased() : string)
    }
}
