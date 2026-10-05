import SwiftUI

/// A styled tag pair rendered as `BEAUTY · 95% MATCH`.
struct MatchTag: Hashable {
    var category: String
    var match: String = "95% MATCH"
}

/// Which variant of the V7 `Look Card` set (16:240) a card is authored as.
///
/// The set's other two variants, *thumbs up* and *thumbs down*, are not chosen
/// here: they are what a `feedback` or `highlighted` card becomes when tapped.
enum LookCardStyle: Hashable {
    /// `Look card w/o feedback` — the photograph and its caption.
    case plain
    /// `Look Card w feedback` — adds a thumbs up / down row under the photograph.
    case feedback
    /// `Look Card highlighted` — the feedback card inside a gradient rule, for
    /// the look Glance most wants a read on.
    ///
    /// Not a resting state: a card in the feed starts as `plain` or
    /// `feedback`, and is only highlighted when something calls for it.
    case highlighted

    var asksForFeedback: Bool { self != .plain }
}

/// Photo-led look card (V7 `Look Card`, 16:240).
struct LookCard: Identifiable, Hashable {
    let id = UUID()
    var image: String
    /// The match read. Not drawn by the V7 card, which leaves the photograph
    /// to its caption; kept for the screens that still speak it.
    var tag: MatchTag
    /// The caption over the foot of the photograph.
    var title: String
    var crop: ImageCrop = ImageCrop()
    /// The social read in front of the category — `2.2K LIKE DIOR`. Not drawn
    /// by the V7 card.
    var likes: String?
    /// The action offered on the photograph. Not drawn by the V7 card.
    var action: String?
    var style: LookCardStyle = .plain
    /// `Look Card big` (19:837) — spans the feed, gutter to gutter, instead of
    /// sitting in a column. Independent of `style`: the comp draws it plain,
    /// but a big card can also ask for feedback.
    var isFullWidth: Bool = false
}

/// A price and what it was — `$30` beside a struck-out `$64`.
struct PriceTag: Hashable {
    var current: String
    var original: String

    /// `(53% OFF)` — worked out from the two prices rather than authored
    /// alongside them, so the three numbers can never disagree. The comp
    /// (8:1624) pairs $30 and $64 with "31% OFF", which those two prices do not
    /// support; deriving it is what keeps that from shipping.
    ///
    /// `nil` when either price will not parse or there is no saving to show.
    var discountLabel: String? {
        guard let now = Self.amount(current),
              let was = Self.amount(original),
              was > 0, was > now else { return nil }
        let percent = Int((((was - now) / was) * 100).rounded())
        guard percent > 0 else { return nil }
        return "(\(percent)% OFF)"
    }

    /// Currency symbols, thousands separators and spacing vary, so the digits
    /// are read out rather than the string being parsed as a number.
    private static func amount(_ text: String) -> Double? {
        Double(text.filter { $0.isNumber || $0 == "." })
    }
}

/// The `Rational` cards — a product shot fading into a solid card colour,
/// with a serif claim and an Inter reason underneath. `Product Cards` in Figma:
/// the image container is a strict 3:4.
struct RationalCard: Identifiable, Hashable {
    let id = UUID()
    var image: String
    var tint: Color
    /// The overline above the claim. Hidden when absent rather than filled with
    /// a stand-in: naming the wrong label on a product is worse than naming none.
    var brand: String?
    var claim: String
    /// Why Glance put this in front of you. Not drawn by the V7 card, which
    /// gives the block a single line of copy — kept on the model because it is
    /// the card's reason for existing and the product screen still speaks it.
    var reason: String
    var crop: ImageCrop = ImageCrop()
    var price: PriceTag?
    /// The pill on the artwork — `2k bought this`, `Sponsored`. Also not drawn
    /// by the V7 card. Anything that is a *disclosure* rather than social proof
    /// needs a home before it can be dropped for good.
    var note: String?
    /// Set when tapping the card should open a product detail screen.
    var productID: String?
}

/// The skin and beauty tips.
struct TipCard: Identifiable, Hashable {
    let id = UUID()
    var tint: Color
    var ink: Color
    /// `category` is the kicker, shown as written — "Skin tip".
    var tag: MatchTag
    /// The whole tip. The V7 card (8:1649) gives it no body to lean on.
    var headline: String
    /// The part of `headline` that carries the tip, drawn heavier and brighter
    /// than the rest (14:240). Must appear in `headline` verbatim; if it does
    /// not, the headline simply renders plain rather than half-styled.
    var highlight: String?
    /// The supporting detail. Not drawn by the V7 card; kept for what
    /// `TELL ME MORE` opens onto.
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

/// An editorial poster that is itself a prompt — `Spoil my pet this month`,
/// `Pick a watch I'll never take off` — sitting in the grid as a column card.
/// The headline is set into the artwork, so the card draws the image whole
/// and never crops it.
struct PosterCard: Identifiable, Hashable {
    let id = UUID()
    var image: String
    /// What the poster says, as plain text: the accessibility label, and what
    /// Ask Glance opens on when it is tapped.
    var prompt: String
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

/// Full-width editorial news card with try-on tools (V7 `Trending News Card`, 2:821).
struct TrendCard: Identifiable, Hashable {
    let id = UUID()
    var image: String
    /// Who ran the story, shown as a pill over the photograph's bottom edge.
    var publisher: String
    /// The publisher's round mark, beside its name.
    var publisherLogo: String
    var headline: String
    /// The card's fill. The publisher pill takes the same colour, which is what
    /// makes it read as cut out of the card rather than laid on the photo.
    /// V7 sets it to `surfaceBright`, #1A1A1A.
    var tint: Color = Color(hex: 0x1A1A1A)
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
    case poster(PosterCard)

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
        case .poster(let m): return m.id
        }
    }

    /// Wide items break the two-column flow.
    var isWide: Bool {
        switch self {
        case .trend, .routine: return true
        case .look(let card): return card.isFullWidth
        default: return false
        }
    }

    /// The big look card (19:837). It spans the feed on a phone; on a wider
    /// canvas it is held to about a phone's width rather than every column:
    /// drawn at its own tall proportion across a whole iPad, it would run
    /// past the bottom of the screen.
    var keepsPhoneWidth: Bool {
        if case .look(let card) = self { return card.isFullWidth }
        return false
    }

    /// True for the cards drawn with `BubbleShape`. Their tail hangs below the
    /// body, so the gap beneath them is tightened to keep the rhythm even.
    /// Tips and prompts were both bubbles until V7 flattened them (8:1649,
    /// 19:753), so no card currently has one; the rule stays for the next.
    var hasTail: Bool {
        switch self {
        case .tip, .prompt, .look, .rational, .brand, .trend, .routine, .signal, .poster: return false
        }
    }
}

/// What the greeting header shows.
struct HomeHeader {
    var greeting: String
    var subtitle: String
    var avatar: String
}
