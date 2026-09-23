import SwiftUI

/// One of the four `MY VISUAL SOURCES` slots. A filled slot shows its photo;
/// an empty one invites the viewer to add it.
struct VisualSource: Identifiable, Hashable {
    let id = UUID()
    var label: String
    var image: String?
    /// Framing for a filled tile, in the comp's points against an 82.5pt tile.
    var crop: ImageCrop = ImageCrop(reference: 82.5)
    /// The trailing "add another" tile has no caption.
    var isSpare: Bool = false
}

struct VibeChip: Identifiable, Hashable {
    let id = UUID()
    var text: String
    /// The dashed `+ vibe` affordance.
    var isAdd: Bool = false
}

/// A `PERSONAL ANAYLSIS` card — body, face, skin or hair (631:777).
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
    var title: String
    var value: String
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

/// A row inside an `AI READ` block. Glance either has a reading — a word over a
/// track, never a percentage — or it has nothing yet, and asks for it instead.
struct MeterRow: Identifiable, Hashable {
    let id = UUID()
    var label: String
    /// `High` / `Medium` / `Low`. `nil` shows the `+Add` prompt in its place.
    var reading: String?
    /// Track fill, 0…100. `nil` draws no track.
    var percent: Int?

    var isPrompt: Bool { reading == nil }
}

/// How often an occasion comes up. Three steps, cycled by tapping the track.
enum FrequencyLevel: Int, CaseIterable, Hashable {
    case low, medium, high

    var label: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    /// Track fill, 0…1.
    var fill: Double { Double(rawValue) / Double(FrequencyLevel.high.rawValue) }

    var next: FrequencyLevel {
        FrequencyLevel(rawValue: (rawValue + 1) % FrequencyLevel.allCases.count) ?? .low
    }
}

/// Who put a reading there.
enum ReadingSource: Hashable {
    /// Glance inferred it and will keep refining it.
    case ai
    /// The viewer pinned it; Glance leaves it alone.
    case you
}

/// One editable row in the Occasion card's `FREQUENCY` block.
struct OccasionRow: Identifiable, Hashable {
    let id = UUID()
    var name: String
    /// `nil` means Glance has no reading yet — the row offers `+Add` instead.
    var level: FrequencyLevel?
    var source: ReadingSource = .ai

    var isActive: Bool { level != nil }
    /// Only what the viewer added is theirs to edit — an `AI READ` is fixed.
    var canRemove: Bool { source == .you }
}

struct PaletteSwatch: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var color: UInt32
}

/// The mascot nudge that appears when Glance is missing something.
struct GapPrompt: Hashable {
    var title: String
    var body: String
    var cta: String
    var ctaBackground: UInt32
    var ctaInk: UInt32
    /// What the call to action opens the assistant with: the first question,
    /// then the rest asked one at a time, then a closing line.
    var opening: ChatPrompt?
    var followUps: [ChatPrompt] = []
    var closing: String?
}

/// A group inside a dimension card: a titled block of rows, meters or swatches.
enum DimensionBlock: Identifiable {
    case facts(title: String, accessory: String, rows: [FactRow])
    case meters(title: String, accessory: String, rows: [MeterRow])
    case palette(title: String, accessory: String, swatches: [PaletteSwatch])
    /// The one editable block: readings the viewer can correct and pin.
    case frequency(title: String, accessory: String, rows: [OccasionRow])

    var id: String {
        switch self {
        case .facts(let t, _, _): return "facts-" + t
        case .meters(let t, _, _): return "meters-" + t
        case .palette(let t, _, _): return "palette-" + t
        case .frequency(let t, _, _): return "frequency-" + t
        }
    }
}

/// One card under `WHAT GLANCE KNOWS`.
struct DimensionCard: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var subtitle: String
    var blocks: [DimensionBlock]
    /// 0…1 completeness, shown as the bar pinned to the card's bottom edge.
    var completeness: Double
    var progressColor: UInt32

    static func == (lhs: DimensionCard, rhs: DimensionCard) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct StyleProfile {
    var name: String
    var namePlaceholder: String
    var avatar: String
    var subtitle: String
    var location: String
    var weather: String
    var sources: [VisualSource]
    var editorialLead: String
    var editorialEmphasis: String
    var editorialTail: String
    var editorialBody: String
    var vibes: [VibeChip]
    var analysis: [AnalysisCard]
    var training: GapPrompt
    var dimensions: [DimensionCard]
}
