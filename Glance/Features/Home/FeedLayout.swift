import SwiftUI

/// One band of the comp's feed: a pair of hand-authored columns, or a single
/// wide card between them.
struct FeedFlow: Identifiable {
    let id: String
    let columns: [[FeedItem]]
}

enum FeedRow: Identifiable {
    case flow(FeedFlow)
    case wide(FeedItem)

    var id: String {
        switch self {
        case .flow(let flow): return flow.id
        case .wide(let item): return "wide-" + item.id.uuidString
        }
    }
}

/// Bridges the authored feed to the two layouts the home screen uses.
///
/// The repository authors the feed as the comp draws it: explicit `left` and
/// `right` lists with wide cards breaking between them. At two columns `rows`
/// keeps each column's order, running consecutive blocks on as one flow so
/// every card sits 8pt below the one above it.
///
/// Above two columns there is no authored arrangement to honour — the pairs
/// would be meaningless — so `items` linearises the feed and `FeedMasonry`
/// places it from real measured heights.
enum FeedLayout {
    /// The comp's own arrangement, for a two-column canvas.
    ///
    /// Consecutive column blocks run on as one flow, so each column stacks its
    /// cards the same 8pt apart all the way down. Squaring the columns up at
    /// every block would leave the shorter one a wider gap each time; they
    /// only square up where a wide card breaks across them, which is the one
    /// place a difference in height shows.
    static func rows(for blocks: [FeedBlock]) -> [FeedRow] {
        var rows: [FeedRow] = []
        var run: (id: String, left: [FeedItem], right: [FeedItem])?

        func endRun() {
            if let run {
                rows.append(.flow(FeedFlow(id: run.id, columns: [run.left, run.right])))
            }
            run = nil
        }

        for block in blocks {
            switch block {
            case .columns(let left, let right):
                if run == nil { run = (block.id, [], []) }
                run?.left += left
                run?.right += right
            case .wide(let item):
                endRun()
                rows.append(.wide(item))
            }
        }
        endRun()
        return rows
    }

    /// Every card in reading order, for a masonry to place.
    static func items(for blocks: [FeedBlock]) -> [FeedItem] {
        blocks.flatMap { block in
            switch block {
            case .columns(let left, let right): return interleave(left, right)
            case .wide(let item): return [item]
            }
        }
    }

    /// Reading order for a hand-paired block is across, not down: the two cards
    /// of a pair sit side by side, so they stay adjacent once linearised.
    private static func interleave(_ left: [FeedItem], _ right: [FeedItem]) -> [FeedItem] {
        var items: [FeedItem] = []
        for index in 0..<max(left.count, right.count) {
            if index < left.count { items.append(left[index]) }
            if index < right.count { items.append(right[index]) }
        }
        return items
    }
}
