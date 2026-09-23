import SwiftUI

/// A styled tag pair rendered as `BEAUTY · 95% MATCH`.
struct MatchTag: Hashable {
    var category: String
    var match: String = "95% MATCH"
}

/// Photo-led card with the shade-match footer and the AI spark badge.
struct LookCard: Identifiable, Hashable {
    let id = UUID()
    var image: String
    var tag: MatchTag
    var title: String
    var crop: ImageCrop = ImageCrop()
    /// The social read in front of the category — `2.2K LIKE DIOR`.
    var likes: String?
    /// The action offered on the photograph, when there is one.
    var action: String?
}

/// The price pill that sits on the product shot — `$30` beside a struck-out `$64`.
struct PriceTag: Hashable {
    var current: String
    var original: String
}

/// The `Rational` cards — a product shot fading into a solid card colour,
/// with a serif claim and an Inter reason underneath. `Product Cards` in Figma:
/// the image container is a strict 3:4.
struct RationalCard: Identifiable, Hashable {
    let id = UUID()
    var image: String
    var tint: Color
    var claim: String
    var reason: String
    var crop: ImageCrop = ImageCrop()
    var price: PriceTag?
    /// The pill on the artwork — `2k bought this`, `Sponsored`.
    var note: String?
    /// Set when tapping the card should open a product detail screen.
    var productID: String?
}

/// The speech-bubble skin tips.
struct TipCard: Identifiable, Hashable {
    let id = UUID()
    var tint: Color
    var ink: Color
    var tag: MatchTag
    var headline: String
    var body: String
    /// Which bottom corner the bubble tail points from.
    var tailOnLeading: Bool = false
}

/// A `TRAIN YOUR AI` card: one question Glance wants answered, the answers on
/// offer, and what it says once one is picked. Three states in one card —
/// question, the answer as given, then the acknowledgement.
struct SignalCard: Identifiable, Hashable {
    let id = UUID()
    var label: String = "Train your AI"
    /// The viewer's own portrait sits beside the label.
    var avatar: String
    var question: String
    var options: [String]
    /// Said back once an answer is picked; `%@` takes the answer.
    var acknowledgement: String = "Noted — %@. I'll fold that into what I show you."
}

/// The small mascot prompt bubbles that invite a conversation.
struct PromptCard: Identifiable, Hashable {
    let id = UUID()
    var text: String
}

/// Brand store card. The campaign art now ships flattened — wordmark and scrim
/// are baked into the image — leaving the caption and the folded page corner.
struct BrandCard: Identifiable, Hashable {
    let id = UUID()
    var image: String
    var crop: ImageCrop = ImageCrop()
    var title: String = "Brand Store"
    var subtitle: String = "As you shopped for this brand very often"
    var note: String? = "Popular brand"
}

/// Full-width editorial news card with try-on tools.
struct TrendCard: Identifiable, Hashable {
    let id = UUID()
    var image: String
    var badge: String = "Trending news"
    var headline: String
    /// The panel under the photograph. The comp tints it per story — maroon for
    /// the Lakme card, navy for the Met Gala one — rather than fixing one colour.
    var tint: Color = Color(hex: 0x220605)
}

struct RoutineStep: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var detail: String
}

/// Full-width routine card — the deep editorial blocks with line-art illustration.
struct RoutineCard: Identifiable, Hashable {
    let id = UUID()
    var kicker: String = "Routine"
    var tag: MatchTag
    var headline: String
    var subhead: String
    var subheadInk: Color
    var steps: [RoutineStep]
    var background: Color
    var illustration: String
    /// The line art is drawn at a different size and bleed on each card:
    /// 140×120 at (253, 32) on the health card, 151×160 at (243, 20) on fashion.
    var illustrationSize: CGSize
    var illustrationInset: CGSize
    var glow: Color
}

/// One entry in the home feed. Masonry items flow in two columns;
/// wide items interrupt the flow and span the full width.
enum FeedItem: Identifiable {
    case look(LookCard)
    case rational(RationalCard)
    case tip(TipCard)
    case prompt(PromptCard)
    case brand(BrandCard)
    case trend(TrendCard)
    case routine(RoutineCard)
    case signal(SignalCard)

    var id: UUID {
        switch self {
        case .look(let m): return m.id
        case .rational(let m): return m.id
        case .tip(let m): return m.id
        case .prompt(let m): return m.id
        case .brand(let m): return m.id
        case .trend(let m): return m.id
        case .routine(let m): return m.id
        case .signal(let m): return m.id
        }
    }

    /// Wide items break the two-column flow.
    var isWide: Bool {
        switch self {
        case .trend, .routine: return true
        default: return false
        }
    }

    /// True for the cards drawn with `BubbleShape`. Their tail hangs below the
    /// body, so the gap beneath them is tightened to keep the rhythm even.
    var hasTail: Bool {
        switch self {
        case .tip, .prompt: return true
        case .look, .rational, .brand, .trend, .routine, .signal: return false
        }
    }
}

/// What the greeting header shows.
struct HomeHeader {
    var greeting: String
    var subtitle: String
    var avatar: String
}
