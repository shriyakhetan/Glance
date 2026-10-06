import SwiftUI
import UIKit

/// The two type voices of the design system (`Typeface`, Surface Art Design
/// Library 2051:136).
/// Manrope is the UI voice — headlines, titles, body copy, labels, data, actions.
/// Playfair Display is the editorial voice — display roles, hero moments, quotes.
/// Italic belongs to the editorial voice alone: Manrope has no italic, and asking
/// it for one fails silently. Never mix voices inside one component.
enum GlanceTypeface {
    static let manropeLight = "Manrope-Light"
    static let manropeRegular = "Manrope-Regular"
    static let manropeMedium = "Manrope-Medium"
    static let manropeSemiBold = "Manrope-SemiBold"
    static let manropeBold = "Manrope-Bold"
    static let manropeExtraBold = "Manrope-ExtraBold"

    static let playfairRegular = "PlayfairDisplay-Regular"
    static let playfairMedium = "PlayfairDisplay-Medium"
    static let playfairBold = "PlayfairDisplay-Bold"
    static let playfairItalic = "PlayfairDisplay-Italic"
    static let playfairBoldItalic = "PlayfairDisplay-BoldItalic"
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

    // Display — Playfair Display, the editorial voice.

    /// Editorial hero moments — occasion titles, pull quotes (Date Night).
    static let displayFeature = GlanceTextStyle(GlanceTypeface.playfairBoldItalic, 24, lineHeight: 28.8, tracking: 0.48)
    /// Greetings and card headlines.
    static let displayL = GlanceTextStyle(GlanceTypeface.playfairMedium, 20)
    /// Section titles inside cards, brand names.
    static let displayM = GlanceTextStyle(GlanceTypeface.playfairRegular, 16)
    /// Supporting editorial lines, blurbs, small serif accents.
    static let displayS = GlanceTextStyle(GlanceTypeface.playfairRegular, 14, lineHeight: 19.6)
    /// Italic editorial accent (`3 Step ~ Morning Routine`).
    static let displaySItalic = GlanceTextStyle(GlanceTypeface.playfairItalic, 14)

    // Heading — Manrope.

    /// Light large numerals — secondary stats.
    static let headingXLRegular = GlanceTextStyle(GlanceTypeface.manropeRegular, 24)
    /// Large stats and hero numerals (4.2, 94%).
    static let headingXL = GlanceTextStyle(GlanceTypeface.manropeExtraBold, 24, lineHeight: 26.4)
    /// Screen titles and modal headers.
    static let headingL = GlanceTextStyle(GlanceTypeface.manropeSemiBold, 16, lineHeight: 22)
    /// Card titles, product names, strong inline emphasis.
    static let headingM = GlanceTextStyle(GlanceTypeface.manropeSemiBold, 14)
    /// Insight titles, callouts, emphasized rows.
    static let headingS = GlanceTextStyle(GlanceTypeface.manropeSemiBold, 12, lineHeight: 14.4)

    /// The tip card's headline (V7 `Headline/Small`, 8:1653). Regular rather
    /// than bold: at 18pt over flat colour the size alone carries it.
    static let headlineS = GlanceTextStyle(GlanceTypeface.manropeRegular, 18, lineHeight: 26)
    /// The phrase a tip headline leans on (14:244) — set a size up and in
    /// ExtraBold inside the `headlineS` sentence around it.
    static let headlineEmphasis = GlanceTextStyle(GlanceTypeface.manropeExtraBold, 20, lineHeight: 24)

    // Body — Manrope.

    /// The product card's own description line (V7, 9:588). Set at 60% white,
    /// which is what carries it back from the brand name above it.
    static let bodyL = GlanceTextStyle(GlanceTypeface.manropeRegular, 16, lineHeight: 20)
    /// Primary reading text, review bodies.
    static let bodyM = GlanceTextStyle(GlanceTypeface.manropeRegular, 14, lineHeight: 20)
    /// V7 `Body/Small` — supporting copy, fine print.
    static let bodyCaption = GlanceTextStyle(GlanceTypeface.manropeRegular, 12, lineHeight: 16, tracking: 0.4)
    /// Default UI text — descriptions, list rows.
    static let bodyS = GlanceTextStyle(GlanceTypeface.manropeRegular, 12)
    /// Chips, buttons, links, emphasized rows.
    static let bodySMedium = GlanceTextStyle(GlanceTypeface.manropeMedium, 12, lineHeight: 18)
    /// Airy editorial body inside feed cards.
    static let bodySLight = GlanceTextStyle(GlanceTypeface.manropeLight, 12)

    // Caption — Manrope.

    /// Metadata, timestamps, footnotes, delivery info.
    static let captionRegular = GlanceTextStyle(GlanceTypeface.manropeRegular, 10, lineHeight: 16)
    /// Small labels with mild emphasis.
    static let captionMedium = GlanceTextStyle(GlanceTypeface.manropeMedium, 10)
    /// Prices, percentages, and stats at small sizes.
    static let captionBold = GlanceTextStyle(GlanceTypeface.manropeBold, 10, lineHeight: 14, tracking: 4)

    // Price — Manrope. The three parts of a discounted price, which the V7
    // product card (8:1624) sets at one size with weight and colour carrying
    // the hierarchy.

    /// What it costs now.
    static let priceNow = GlanceTextStyle(GlanceTypeface.manropeBold, 14, lineHeight: 16, tracking: 0.5)
    /// What it cost before, struck through.
    static let priceWas = GlanceTextStyle(GlanceTypeface.manropeRegular, 14, lineHeight: 16, tracking: 0.4)
    /// The saving, a step down in size as well as colour.
    static let priceOff = GlanceTextStyle(GlanceTypeface.manropeRegular, 12, lineHeight: 16, tracking: 0.4)

    // Label — Manrope, auto-uppercased.

    /// V7 `Label/Medium` — the trending card's publisher and tool pills (2:827).
    static let labelMedium = GlanceTextStyle(GlanceTypeface.manropeSemiBold, 12, lineHeight: 16, tracking: 0.5)
    /// V7 `Label/Small` as authored — the tip card's kicker (8:1651) is set in
    /// sentence case, so this one does not uppercase.
    static let labelSmall = GlanceTextStyle(GlanceTypeface.manropeMedium, 9, lineHeight: 11, tracking: 0.25)
    /// V7 `Label/Small`, uppercased — the brand over a product card (8:1606)
    /// and the tip card's `TELL ME MORE` (8:1655).
    static let labelBrand = GlanceTextStyle(GlanceTypeface.manropeMedium, 9, lineHeight: 11, tracking: 0.25, uppercased: true)
    // V7 — the design system's own roles (`Typeface`, 2051:136), at the sizes
    // it gives them.

    /// V7 `Display/Small` — section titles on L2, product names on cards.
    static let displaySmall = GlanceTextStyle(GlanceTypeface.playfairRegular, 18, lineHeight: 22)
    /// V7 `Display/Medium` — an outfit's occasion.
    static let displayMedium = GlanceTextStyle(GlanceTypeface.playfairRegular, 22, lineHeight: 30)
    /// V7 `Headline/Large` — the match score.
    static let headlineL = GlanceTextStyle(GlanceTypeface.manropeRegular, 26, lineHeight: 34)
    /// V7 `Headline/Medium`'s 20/24, set in Regular — the tip card's sentence,
    /// whose bold phrase (`headlineEmphasis`, the same 20/24) carries the weight.
    static let headlineM = GlanceTextStyle(GlanceTypeface.manropeRegular, 20, lineHeight: 24)
    /// V7 `Title/Medium` — a price, a card's verdict.
    static let titleMedium = GlanceTextStyle(GlanceTypeface.manropeMedium, 16, lineHeight: 24, tracking: 0.15)
    /// V7 `Label/Large` — full-size button labels.
    static let labelLarge = GlanceTextStyle(GlanceTypeface.manropeMedium, 14, lineHeight: 20, tracking: 0.1)
    /// V7 `Body/Medium`.
    static let bodyMedium = GlanceTextStyle(GlanceTypeface.manropeRegular, 14, lineHeight: 20, tracking: 0.25)
    /// V7 `Body/Large` — the small look card's caption over its photograph.
    static let bodyLarge = GlanceTextStyle(GlanceTypeface.manropeRegular, 16, lineHeight: 22, tracking: 0.5)

    /// Uppercase section titles — MY VISUAL SOURCES, WHAT GLANCE KNOWS.
    static let labelSection = GlanceTextStyle(GlanceTypeface.manropeBold, 10, lineHeight: 14, tracking: 4, uppercased: true)
    /// Smallest tracked uppercase — card tags (BEAUTY, 95% MATCH).
    static let labelOverline = GlanceTextStyle(GlanceTypeface.manropeSemiBold, 8, lineHeight: 11.2, tracking: 0.4, uppercased: true)
}

// MARK: - Applying a style

private struct GlanceTextStyleModifier: ViewModifier {
    let style: GlanceTextStyle

    func body(content: Content) -> some View {
        let styled = content
            .font(style.font)
            .tracking(style.tracking)

        if #available(iOS 26.0, *), let lineHeight = style.lineHeight {
            // The style's line height exactly, as Figma sets it. Manrope and
            // Playfair carry more natural leading than most of the scale asks
            // for, and line spacing can only ever add to that.
            styled.lineHeight(.exact(points: lineHeight))
        } else {
            styled.lineSpacing(style.lineSpacing)
        }
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
