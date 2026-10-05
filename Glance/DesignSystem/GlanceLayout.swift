import SwiftUI

/// The app is drawn on a 402pt iPhone frame, and the design system is tuned to
/// that measure: `ArchGlow` is sized in absolute points, feed cards crop their
/// photography to a fixed box, and the two-column feed divides a known width
/// into 24 / n / 24 / n / 24.
///
/// On a wider canvas — iPad, or an iPhone in landscape — the content is
/// therefore kept at its intended size and centred rather than stretched. A
/// 1024pt-wide feed row would put two cards at 470pt each, which no card in the
/// library is cropped for, and a line of body copy that long is past the point
/// where it stays comfortable to read.
enum GlanceLayout {
    /// Widest the content column is allowed to grow.
    ///
    /// 440 gives the 402pt design a little air on a large screen without
    /// letting the feed's paired cards drift far from the width their imagery
    /// is cropped to.
    static let maxContentWidth: CGFloat = 440

    // MARK: - Feed grid

    /// An 8pt gutter at the screen edges, 16pt between cards both across and
    /// down — the mosaic runs nearly edge to edge while each card keeps room
    /// around it.
    static let feedGutter: CGFloat = Space.sm
    static let feedColumnGap: CGFloat = Space.lg
    static let feedRowGap: CGFloat = Space.lg

    /// Three columns at most.
    ///
    /// Apple's own grids step between a small number of arrangements at
    /// size-class boundaries and let the content *grow* to fill the step, rather
    /// than packing in another column every time a few more points appear. Past
    /// three the cards fall back towards the phone's 165pt measure and the feed
    /// stops reading as an editorial surface and starts reading as a contact
    /// sheet.
    static let maxFeedColumns = 3

    /// Where the grid steps from the comp's two columns to three. Below it sit
    /// every iPhone, iPad Slide Over and a narrow split view — all the places
    /// the phone layout is still the right answer.
    static let feedThreeColumnWidth: CGFloat = 640

    /// Cards scale with the canvas, but not without limit: beyond this the
    /// photography is enlarged well past what it was composed for. The grid
    /// stops growing here and the extra room becomes margin instead — what
    /// Apple's readable content width does for running text.
    static let maxFeedColumnWidth: CGFloat = 320

    /// Widest the grid can be: three full columns, plus its gaps and gutters.
    static var maxFeedWidth: CGFloat {
        maxFeedColumnWidth * CGFloat(maxFeedColumns)
            + feedColumnGap * CGFloat(maxFeedColumns - 1)
            + feedGutter * 2
    }

    /// Two columns or three — a step, not a sliding scale.
    static func feedColumnCount(for width: CGFloat) -> Int {
        guard width > 0 else { return 2 }
        return width >= feedThreeColumnWidth ? maxFeedColumns : 2
    }

    /// A trend or routine card lays its content out across the card — three
    /// numbered steps side by side — so it needs roughly the comp's own measure
    /// to read. The comp gives it the full 354pt width of a phone.
    static let minWideCardWidth: CGFloat = 300

    /// The most columns the big look card can take while staying about a
    /// phone's width.
    ///
    /// On a phone it is the full feed width (19:837, 364 of 412). It keeps the
    /// column card's tall proportion, so spanning every column of an iPad would
    /// make it roughly 1,000 × 1,780pt; held to the reading measure, it stays
    /// the size it is on a phone. Never fewer than one column.
    static func bigCardSpan(columnWidth: CGFloat, count: Int) -> Int {
        var best = 1
        for span in 1...max(1, count) {
            let width = columnWidth * CGFloat(span) + feedColumnGap * CGFloat(span - 1)
            if width <= maxContentWidth { best = span }
        }
        return best
    }

    /// The fewest columns a wide card can take and still reach that measure.
    ///
    /// Taking more than it needs is not free: a spanning card cannot start
    /// until *every* column it covers is clear, so it strands whatever space is
    /// left above it in the shallower ones. Once the columns have grown past
    /// 300pt on their own, a wide card is best off in a single one.
    static func wideCardSpan(columnWidth: CGFloat, count: Int) -> Int {
        guard count > 1 else { return 1 }
        for span in 1...count {
            let width = columnWidth * CGFloat(span) + feedColumnGap * CGFloat(span - 1)
            if width >= minWideCardWidth { return span }
        }
        return count
    }

    /// The measured width of one column, so cards can be pinned to an equal
    /// width rather than left to an `HStack`'s own distribution.
    static func feedColumnWidth(for width: CGFloat, count: Int) -> CGFloat {
        let gaps = feedColumnGap * CGFloat(max(0, count - 1))
        return (width - feedGutter * 2 - gaps) / CGFloat(count)
    }
}

extension View {
    /// Caps the view at the design's measure and centres it horizontally,
    /// leaving whatever sits behind it to fill the rest of the screen.
    ///
    /// Apply this to a screen's *scroll content* and to any bar pinned over it,
    /// never to the scroll view itself — the background and the scrim bands are
    /// meant to run edge to edge.
    func glanceContentColumn(_ width: CGFloat = GlanceLayout.maxContentWidth) -> some View {
        frame(maxWidth: width)
            .frame(maxWidth: .infinity)
    }
}
