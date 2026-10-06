import CoreGraphics
import Foundation

/// A box in a comp's own points — where a piece sits, or how its art is cropped.
struct CompRect: Hashable {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat

    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    var size: CGSize { CGSize(width: width, height: height) }
}

/// `Social Proof` (32:2561) — who else bought it, and how lately.
struct SocialProof: Hashable {
    var buyers: [String]
    var headline: String
    var detail: String
}

/// The glyph a match point leads with (32:2593).
enum MatchIcon: Hashable {
    case fit, neckline, colour, price, occasion, pattern
}

/// One line of the match card: the point in white, the reason after it dimmed.
struct MatchPoint: Identifiable, Hashable {
    let id = UUID()
    var icon: MatchIcon
    var lead: String
    var rest: String
}

/// `Why it works for you?` (32:2572).
struct ProductMatch: Hashable {
    /// Set bold inside `A … for you`.
    var verdict: String
    var score: Int
    var matches: [MatchPoint]
    var mismatches: [MatchPoint]
    var question: String
    var answers: [String]
}

struct SizeGuess: Hashable {
    var size: String
    var rationale: String
}

struct ColorOption: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var image: String
}

/// `Price Trends` (32:2677) — the verdict, and where today's price sits
/// between the lowest and highest it has been.
struct PriceTrend: Hashable {
    var verdict: String
    var detail: String
    var buyLabel: String
    var lowest: Double
    var usual: Double
    var highest: Double
    var current: Double

    /// Where `price` falls on the tracker, 0…1. The limits row spaces lowest,
    /// usual and highest evenly, so the scale runs straight between each pair
    /// and the usual price sits mid-track.
    func position(of price: Double) -> CGFloat {
        let clamped = min(max(price, lowest), highest)
        if clamped <= usual {
            guard usual > lowest else { return 0.5 }
            return 0.5 * (clamped - lowest) / (usual - lowest)
        }
        guard highest > usual else { return 0.5 }
        return 0.5 + 0.5 * (clamped - usual) / (highest - usual)
    }

    func label(_ price: Double) -> String {
        "$" + String(format: "%.0f", price)
    }
}

enum DeliveryIcon: Hashable {
    case fees, returnWindow, exchange, pickup
}

struct DeliveryFact: Identifiable, Hashable {
    let id = UUID()
    var icon: DeliveryIcon
    var label: String
    var value: String
}

/// `Delivery & Returns` (32:2702).
struct Delivery: Hashable {
    /// `Free Delivery by` — dimmed ahead of the date.
    var lead: String
    var date: String
    var place: String
    var facts: [DeliveryFact]
}

/// `HELP US IMPROVE` (32:2741) — a question the product page asks back.
struct FitQuestion: Hashable {
    var label: String
    var text: String
    var options: [String]
    /// What Glance says once answered; `%@` takes the answer.
    var acknowledgement: String
}

/// A piece on an outfit board (32:2775), in the board's 298 × 252 collage.
struct OutfitTile: Identifiable, Hashable {
    enum Content: Hashable {
        /// A product on a white tile: `art` is its box in the tile, and `crop`
        /// where the image falls inside that box — `nil` covers it.
        case piece(image: String, art: CompRect, crop: CompRect?)
        /// The empty slot for adding a piece.
        case add
    }

    let id = UUID()
    var frame: CompRect
    var content: Content
    /// The hero product is the board's anchor, so only the rest can be swapped.
    var swappable = true
}

/// `Where can you wear this?` (32:2766) — one occasion and its board.
struct Outfit: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var summary: String
    var tiles: [OutfitTile]
}

/// `More I think you'll like` (32:2825) — a look or a product.
struct SuggestedProduct: Identifiable, Hashable {
    enum Style: Hashable {
        /// `Card` (32:2829): the photograph fades into the card's own colour,
        /// the title sits on it.
        case look
        /// `Non Fashion Cards` (32:2838): a photograph over a brand and title,
        /// with a save button.
        case product
    }

    let id = UUID()
    var style: Style
    var image: String
    /// The photograph's box inside its 170pt-wide frame.
    var art: CompRect
    /// The card colour the photograph fades into.
    var tint: UInt32
    var brand: String?
    var title: String
    var price: String
    var wasPrice: String
}

struct Product: Identifiable, Hashable {
    var id: String
    var brand: String
    var name: String
    var price: String
    var originalPrice: String
    var discount: String
    var images: [String]

    var rating: String
    var ratingCount: String
    var socialProof: SocialProof

    var match: ProductMatch

    var sizeGuess: SizeGuess
    var availableSizes: [String]

    var colors: [ColorOption]
    var moreColors: Int

    var priceTrend: PriceTrend
    var delivery: Delivery
    var fitQuestion: FitQuestion
    var outfits: [Outfit]
    var moreLikeThis: [SuggestedProduct]
    var suggestionChips: [String]
}
