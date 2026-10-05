import SwiftUI

/// How many columns a feed card occupies.
private struct FeedSpanKey: LayoutValueKey {
    static let defaultValue: Int = 1
}

/// The gap left beneath a card. Bubble-tailed cards take a tighter one: the
/// tail already hangs into the space below the body.
private struct FeedGapKey: LayoutValueKey {
    static let defaultValue: CGFloat = 24
}

extension View {
    func feedSpan(_ columns: Int) -> some View {
        layoutValue(key: FeedSpanKey.self, value: columns)
    }

    func feedGapBelow(_ gap: CGFloat) -> some View {
        layoutValue(key: FeedGapKey.self, value: gap)
    }
}

/// A masonry that measures its cards and lets wide ones span two columns.
///
/// Dealing cards into fixed column stacks — the obvious `HStack` of `VStack`s —
/// can't do either of those things. It has to guess heights before the cards
/// are laid out, and it has no way to express a card wider than one column, so
/// a wide card must interrupt the flow instead. On a phone neither limitation
/// shows: the comp pairs the cards by hand and a wide card genuinely spans the
/// whole screen. On a wide canvas both do — short runs between wide cards leave
/// columns ending at wildly different heights, and the holes are conspicuous.
///
/// `Layout` is handed each subview's real measured size, so the placement here
/// is exact rather than estimated, and `FeedSpanKey` lets the trend and routine
/// cards take two columns — about 380pt at the column widths this grid
/// produces, which is close to the 354pt their artwork is positioned for.
struct FeedMasonry: Layout {
    var columns: Int
    /// Gap between columns; the vertical gap travels with each card.
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        let placement = place(subviews, inWidth: width)
        return CGSize(width: width, height: placement.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let placement = place(subviews, inWidth: bounds.width)
        for (index, frame) in placement.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(width: frame.width, height: frame.height)
            )
        }
    }

    // MARK: - Placement

    private struct Placement {
        var frames: [CGRect]
        var height: CGFloat
    }

    private func place(_ subviews: Subviews, inWidth total: CGFloat) -> Placement {
        let count = max(1, columns)
        let columnWidth = (total - spacing * CGFloat(count - 1)) / CGFloat(count)

        /// Bottom edge reached in each column, including that card's own gap.
        var bottoms = [CGFloat](repeating: 0, count: count)
        var frames: [CGRect] = []
        /// Tracked separately from `bottoms` so a trailing gap is not counted
        /// into the feed's overall height.
        var contentHeight: CGFloat = 0

        for subview in subviews {
            let span = min(max(1, subview[FeedSpanKey.self]), count)
            let width = columnWidth * CGFloat(span) + spacing * CGFloat(span - 1)
            let height = subview.sizeThatFits(ProposedViewSize(width: width, height: nil)).height

            let start = bestStart(in: bottoms, span: span)
            let top = bottoms[start..<(start + span)].max() ?? 0

            frames.append(
                CGRect(
                    x: (columnWidth + spacing) * CGFloat(start),
                    y: top,
                    width: width,
                    height: height
                )
            )

            contentHeight = max(contentHeight, top + height)
            // Every column the card covers is levelled to its bottom edge, so
            // the next card can't slide up beside part of it.
            let next = top + height + subview[FeedGapKey.self]
            for column in start..<(start + span) { bottoms[column] = next }
        }

        return Placement(frames: frames, height: contentHeight)
    }

    /// The run of `span` adjacent columns whose deepest point is highest — the
    /// shortest-column rule, generalised to a card that covers several. Ties go
    /// to the leftmost run, which keeps the first cards in authored order.
    private func bestStart(in bottoms: [CGFloat], span: Int) -> Int {
        var best = 0
        var bestTop = CGFloat.greatestFiniteMagnitude
        for start in 0...(bottoms.count - span) {
            let top = bottoms[start..<(start + span)].max() ?? 0
            if top < bestTop {
                bestTop = top
                best = start
            }
        }
        return best
    }
}
