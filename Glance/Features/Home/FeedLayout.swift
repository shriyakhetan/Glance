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
/// `right` lists, paired by hand so a tip sits beside the look it answers, with
/// wide cards breaking between them. That pairing *is* the design at two
/// columns, so `rows` hands it straight through and a phone renders exactly
/// what it rendered before this type existed.
///
/// Above two columns there is no authored arrangement to honour — the pairs
/// would be meaningless — so `items` linearises the feed and `FeedMasonry`
/// places it from real measured heights.
enum FeedLayout {
    /// The comp's own arrangement, for a two-column canvas.
    static func rows(for blocks: [FeedBlock]) -> [FeedRow] {
        blocks.map { block in
            switch block {
            case .columns(let left, let right):
                return .flow(FeedFlow(id: block.id, columns: [left, right]))
            case .wide(let item):
                return .wide(item)
            }
        }
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
