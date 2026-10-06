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
    /// Set when tapping the photograph should open the look's own page.
    var detailID: String?
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
/// with a serif claim and a sans reason underneath. `Product Cards` in Figma:
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

/// The four palettes of the `Tip Card` set (2825:810), each in five shades
/// running from deepest to lightest.
enum TipCategory: Hashable {
    case beauty, fashion, gadget, health

    private var shades: [UInt32] {
        switch self {
        case .beauty: [0x5C3820, 0x6B4526, 0x7A5C42, 0x8A6640, 0x8A5C30]
        case .fashion: [0x3A1F2B, 0x4E1F30, 0x5C2E3E, 0x6B2E44, 0x974267]
        case .gadget: [0x162132, 0x1C2B3D, 0x24405C, 0x2F5478, 0x3B6894]
        case .health: [0x124126, 0x234030, 0x2F5A3C, 0x3F7850, 0x4F9463]
        }
    }

    /// `Shade=1` … `Shade=5`; anything outside that range is clamped to it.
    func fill(shade: Int) -> Color {
        Color(hex: shades[min(max(shade, 1), shades.count) - 1])
    }
}

/// A tip card's call to action, named for what the tip leads to.
enum TipAction: Hashable {
    /// `Tell Me More` — Glance explains the tip.
    case explain
    /// `Show Products`, `Find Sunscreens` — what the tip suggests buying.
    case shop(String)

    var title: String {
        switch self {
        case .explain: "Tell Me More"
        case .shop(let title): title
        }
    }
}

/// A tip: the advice, its kicker, and the phrase it leans on.
struct TipCard: Identifiable, Hashable {
    let id = UUID()
    /// Which palette the card is drawn in, and which of its five shades.
    var category: TipCategory
    var shade: Int
    /// `category` is the kicker, shown as written — "Skin tip".
    var tag: MatchTag
    /// The whole tip. The V7 card (8:1649) gives it no body to lean on.
    var headline: String
    /// The part of `headline` that carries the tip, drawn heavier and brighter
    /// than the rest (14:240). Must appear in `headline` verbatim; if it does
    /// not, the headline simply renders plain rather than half-styled.
    var highlight: String?
    /// The supporting detail. Not drawn by the card.
    var body: String
    /// What the tip's own page (4201:5148) suggests buying, and the replies
    /// its composer offers.
    var suggestions: [ShopProduct] = []
    var chips: [String] = ["Find more", "Find similar", "Explain this"]
    /// What the card's button offers.
    var action: TipAction = .shop("Show Products")
    /// Which bottom corner the bubble tail points from.
    var tailOnLeading: Bool = false
}

extension TipCard {
    /// `Tell Me More`: the assistant opens on the tip's detail, offering the
    /// tip's own replies.
    var explanation: ChatTopic {
        ChatTopic(source: tag.category, opening: body, options: chips)
    }
}

/// A `TRAIN YOUR AI` card (`Signal Card`, 2831:1117): one question Glance
/// wants answered and the answers on offer. Once one is picked the card turns
/// to its second face and asks to keep going (`State=Start Chat`, 2831:1118).
struct SignalCard: Identifiable, Hashable {
    let id = UUID()
    var label: String = "Train your AI"
    /// The viewer's own portrait sits beside the label.
    var avatar: String
    var question: String
    var options: [String]
    /// What Glance says back about the answer — the first line of the chat
    /// `Start Chat` opens. `%@` takes the answer.
    var acknowledgement: String = "Noted — %@. I'll fold that into what I show you."
    /// The second face: the invitation, and the button that takes it up.
    var invitation: String = "Want to tell me a little more about what you like?"
    var invitationAction: String = "Start Chat"
    /// What that chat goes on to ask, a question at a time.
    var interview: [ChatPrompt] = SignalCard.likesInterview
    /// Said once the interview runs out.
    var closing: String = "That's plenty to go on. I'll fold it into your feed, so it should start looking more like you within a day or two."

    /// What she likes, asked four ways — where she spends, what she won't
    /// wear, who else she shops for, how far ahead she plans.
    static let likesInterview: [ChatPrompt] = [
        ChatPrompt(
            text: "Now a few quick ones about what you like. First: when you're buying clothes, where are you happy to spend more?",
            options: ["Outerwear", "Shoes & bags", "Everyday basics", "I hunt for deals"]
        ),
        ChatPrompt(
            text: "Noted. And what would you never wear, whatever the occasion?",
            options: ["Bodycon", "Neon brights", "Big logos", "Nothing's off limits"]
        ),
        ChatPrompt(
            text: "Good. Who else do you shop for?",
            options: ["Just me", "My partner", "Kids", "Gifts for family"]
        ),
        ChatPrompt(
            text: "Last one — how far ahead do you decide an outfit?",
            options: ["The night before", "Morning of", "Weeks ahead", "I improvise"]
        )
    ]

    /// The conversation `Start Chat` opens: Glance takes the answer in, then
    /// asks the interview one question at a time.
    func chatTopic(answering answer: String) -> ChatTopic {
        let acknowledged = String(format: acknowledgement, answer.lowercased())
        guard let first = interview.first else {
            return ChatTopic(source: label, opening: acknowledged)
        }
        return ChatTopic(
            source: label,
            opening: acknowledged + " " + first.text,
            options: first.options,
            followUps: Array(interview.dropFirst()),
            closing: closing
        )
    }
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

/// A filler card (`Card`, 2831:1018) — Glance offering to talk, in one of the
/// set's three states.
struct PromptCard: Identifiable, Hashable {
    enum Style: Hashable {
        /// `State=Start Chat` (2831:1019) — the mascot beside a single line.
        case compact
        /// `State=Start Chat 2` (3138:1867) — the mascot over a longer line.
        case stacked
        /// `State=Continue Chat` (2831:1017) — picks an earlier conversation
        /// back up, behind its own button.
        case resume
    }

    let id = UUID()
    var style: Style
    var text: String
    /// What opens: Glance's first line and the replies it offers.
    var chat: ChatTopic
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
