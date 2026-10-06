import SwiftUI

struct VibeChip: Identifiable, Hashable {
    let id = UUID()
    var text: String
}

/// A `Personal Analysis` card — body, face, skin or hair (2490:1671).
struct AnalysisCard: Identifiable, Hashable {
    let id = UUID()
    /// The photograph inside the 76pt circle: either a pre-rendered circle or a
    /// source photo framed by `crop`.
    var portrait: String?
    /// Framing for `portrait`, in the comp's points against the 76pt circle.
    /// The default centre-fills, which is what a pre-rendered circle wants.
    var crop: ImageCrop = ImageCrop(width: 76, height: 76, reference: 76)
    /// The tag beside the portrait: a quiet label over a bold reading.
    var metricLabel: String
    var metricValue: String
    /// What the card reads — `Body Frame`, `Face Shape`.
    var title: String
    /// The reading itself, in the editorial voice — `Athletic frame`.
    var headline: String
    var detail: String
    /// Per-card call to action; the comp gives each one its own wording.
    var cta: String
    /// What Glance says when that call to action opens the assistant, and the
    /// replies it offers (731:701).
    var chatOpening: String
    var chatOptions: [String]
}

/// A label/value row inside a dimension card.
struct FactRow: Identifiable, Hashable {
    let id = UUID()
    var label: String
    var value: String
}

/// A reading over a track — a word, never a percentage, with the track drawn to
/// the width the comp gives it.
struct MeterRow: Identifiable, Hashable {
    let id = UUID()
    var label: String
    /// `High` / `Medium` / `Low`.
    var reading: String
    /// Track fill, 0…100.
    var percent: Int
}

struct PaletteSwatch: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var color: UInt32
}

/// Whose read a block is, named on its header's trailing side.
struct BlockTag: Hashable {
    enum Source: Hashable {
        /// What she has told Glance — `YOUR GO TO`, `YOUR`. Amber.
        case yours
        /// What Glance inferred — `AI READ`. Lavender.
        case ai
    }

    var text: String
    var source: Source

    static let aiRead = BlockTag(text: "AI Read", source: .ai)
    static func yours(_ text: String) -> BlockTag { BlockTag(text: text, source: .yours) }
}

/// A group inside a dimension card: a titled block of rows, meters or swatches.
///
/// Row rhythm is the comp's own, and it is not the same everywhere: Fit &
/// sizing sets its rows 12 apart and Brand 16; Occasion pads 8 under each meter
/// on top of a 16 gap, where the Aesthetic mix uses a plain 20.
enum DimensionBlock: Identifiable {
    case facts(title: String, tag: BlockTag, rows: [FactRow], spacing: CGFloat = 12)
    case meters(title: String, tag: BlockTag, rows: [MeterRow], spacing: CGFloat = 20, rowInset: CGFloat = 0)
    case palette(title: String, tag: BlockTag, swatches: [PaletteSwatch])

    var id: String {
        switch self {
        case .facts(let title, _, _, _): return "facts-" + title
        case .meters(let title, _, _, _, _): return "meters-" + title
        case .palette(let title, _, _): return "palette-" + title
        }
    }
}

/// One card under `What Glance Knows` (2490:1757).
struct DimensionCard: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var subtitle: String
    var blocks: [DimensionBlock]
    /// Title to subtitle. Fashion & Style stacks them 12 apart; the cards
    /// after it group the pair 4 apart.
    var headerSpacing: CGFloat = 4

    static func == (lhs: DimensionCard, rhs: DimensionCard) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct StyleProfile {
    var avatar: String
    var subtitle: String
    var location: String
    var weather: String
    var editorialLead: String
    var editorialEmphasis: String
    var editorialTail: String
    var editorialBody: String
    var vibes: [VibeChip]
    var analysis: [AnalysisCard]
    var dimensions: [DimensionCard]
}
