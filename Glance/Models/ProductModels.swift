import Foundation

struct Review: Identifiable, Hashable {
    let id = UUID()
    /// The serif lead-in explaining why this review was surfaced.
    var highlight: String
    var body: String
    var author: String
}

struct SizeGuess: Hashable {
    var size: String
    var confidence: String
    var rationale: String
}

struct ColorOption: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var image: String
}

struct PricePoint: Identifiable, Hashable {
    let id = UUID()
    var date: Date
    var price: Double
}

enum PriceRange: String, CaseIterable, Identifiable {
    case thirtyDay = "30 Day"
    case threeMonths = "3 Months"
    case sixMonths = "6 Months"

    var id: String { rawValue }
    var days: Int {
        switch self {
        case .thirtyDay: return 30
        case .threeMonths: return 91
        case .sixMonths: return 182
        }
    }
}

struct PriceStats: Hashable {
    var low: String
    var typical: String
    var high: String
}

struct CardOffer: Hashable {
    var price: String
    var strikethrough: String
    var card: String
    var saveExtra: String
    var additionalOffers: Int
}

struct WhyItWorks: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var detail: String
}

struct DeliveryFact: Identifiable, Hashable {
    let id = UUID()
    var icon: String
    var label: String
    var value: String
}

struct Delivery: Hashable {
    var headline: String
    var deliveredToLabel: String
    var pincode: String
    var note: String
    var facts: [DeliveryFact]
}

struct WearOccasion: Identifiable, Hashable {
    let id = UUID()
    var image: String
    var title: String
    var summary: String
    var tip: String
}

struct AlsoWorksFor: Identifiable, Hashable {
    let id = UUID()
    var image: String
    var tint: UInt32
    var title: String
    var detail: String
}

struct Product: Identifiable, Hashable {
    var id: String
    var brand: String
    var name: String
    var price: String
    var originalPrice: String
    var discount: String
    var images: [String]

    var matchTitle: String
    var matchBody: String

    var rating: String
    var ratingCount: String
    var reviews: [Review]
    var aiSummary: String

    var sizeGuess: SizeGuess
    var availableSizes: [String]

    var colors: [ColorOption]
    var moreColors: Int

    var priceStats: PriceStats
    var priceHistory: [PricePoint]
    var offer: CardOffer

    var whyItWorks: [WhyItWorks]
    var delivery: Delivery
    var occasion: WearOccasion
    var alsoWorksFor: [AlsoWorksFor]
    var suggestionChips: [String]

    func history(for range: PriceRange) -> [PricePoint] {
        Array(priceHistory.suffix(range.days))
    }
}
