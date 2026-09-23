import Foundation

/// Product lookup. Swap this for a networked implementation without touching views.
struct ProductRepository {
    static let shared = ProductRepository()

    func product(id: String) -> Product {
        Product.unifringePolo
    }
}

extension Product {
    static let unifringePolo = Product(
        id: "unifringe-derrick-rose-polo",
        brand: "UNIFRINGE",
        name: "Men Derrick Rose Polo Collar T-shirt",
        price: "$48.00",
        originalPrice: "$72.00",
        discount: "50% Off",
        // The feed card's own shot leads, so the zoom transition from Home lands
        // on the same photograph it grew out of. `Image Carousal` (335:1248)
        // supplies the five frames that follow.
        images: [
            "product-polo-card",
            "product-polo-1",
            "product-polo-2",
            "product-polo-3",
            "product-polo-4",
            "product-polo-5"
        ],

        matchTitle: "Strong match for you",
        matchBody: "This works well with your usual relaxed-smart style, warm-neutral color palette, and preference for pieces that can move between casual and slightly elevated occasions.",

        rating: "4.2",
        ratingCount: "(342)",
        reviews: [
            Review(
                highlight: "Because you care about Fabric I wanted to highlight this review in particular for you",
                body: "The texture feels incredible soft, refined, and genuinely premium. It looks far more expensive than it is, making it feel like a great find.",
                author: "- Arjun K."
            ),
            Review(
                highlight: "You tend to size up, so this note on the cut is worth reading",
                body: "Runs true to size with a relaxed shoulder. I usually take a medium and the large gave me exactly the drape I wanted without looking oversized.",
                author: "- Meera S."
            ),
            Review(
                highlight: "You buy for longevity — here is how it held up after a season",
                body: "Six washes in and the olive has not faded at all. The collar still sits flat, which is where most polos in this price range give up.",
                author: "- Daniel R."
            )
        ],
        aiSummary: "Users love the substantial feel of the tee and the olive green color. The most common note is regarding the fit. Users love the substantial feel of the tee and the deep blue color. The most common note is regarding the fit.",

        sizeGuess: SizeGuess(
            size: "L",
            confidence: "High Confidence",
            rationale: "Matches your preferred relaxed silhouette from past purchases."
        ),
        availableSizes: ["XS", "S", "M", "L", "XL"],

        colors: [
            ColorOption(name: "Navy Blue", image: "color-navy"),
            ColorOption(name: "White", image: "color-white"),
            ColorOption(name: "Grey", image: "color-grey")
        ],
        moreColors: 6,

        priceStats: PriceStats(low: "$44.00", typical: "$52.00", high: "$58.00"),
        priceHistory: Product.makePriceHistory(),
        offer: CardOffer(
            price: "Buy for $32",
            strikethrough: "$48",
            card: "Amex card",
            saveExtra: "Save Extra $16",
            additionalOffers: 5
        ),

        whyItWorks: [
            WhyItWorks(title: "Fit", detail: "Relaxed fit suits your broad shoulders."),
            WhyItWorks(title: "Color", detail: "Blue complements your warm undertones."),
            WhyItWorks(title: "Fabric", detail: "Breathable fabric keeps you through the day."),
            WhyItWorks(title: "Versatility", detail: "Pairs with most of your casual wardrobe.")
        ],
        delivery: Delivery(
            headline: "Free Delivery by Thursday, Aug 30th",
            deliveredToLabel: "Delivered to",
            pincode: "560034",
            note: "In time for your weekend Japan trip",
            facts: [
                DeliveryFact(icon: "ic-delivery-truck", label: "Shipping fees", value: "$2"),
                DeliveryFact(icon: "ic-delivery-return", label: "Return Window", value: "7 Days"),
                DeliveryFact(icon: "ic-delivery-tag", label: "Exchange Available", value: "Size & Color"),
                DeliveryFact(icon: "ic-delivery-truck", label: "Return Pickup", value: "Free doorstep")
            ]
        ),
        occasion: WearOccasion(
            image: "wear-date-night",
            title: "Date Night",
            summary: "This item looks like a good match for your upcoming date night",
            tip: "Pair with cream linen trousers and brown loafers for an effortless evening look."
        ),
        alsoWorksFor: [
            AlsoWorksFor(
                image: "wear-office-day",
                tint: 0x605141,
                title: "Office Day",
                detail: "Warm candlelight makes every evening feel a little more special"
            ),
            AlsoWorksFor(
                image: "wear-weekend-brunch",
                tint: 0x605141,
                title: "Weekend Brunch",
                detail: "Warm candlelight makes every evening feel a little more special"
            )
        ],
        suggestionChips: ["Try On", "Ways to style this", "Show cheaper options"]
    )

    /// Six months of daily prices, shaped to hit the $44 low, $52 typical and
    /// $58 high quoted in the design and to land on $48.00 today.
    static func makePriceHistory() -> [PricePoint] {
        // Fixed reference date so the chart reads the same as the comp.
        var components = DateComponents()
        components.year = 2026
        components.month = 8
        components.day = 25
        let calendar = Calendar(identifier: .gregorian)
        let end = calendar.date(from: components) ?? Date()

        let count = 182
        // A deterministic walk: overlaid waves plus a seeded jitter, so the line
        // has the character of a real price history and redraws identically.
        var seed: UInt64 = 0x9E3779B97F4A7C15
        func jitter() -> Double {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return Double((seed >> 33) % 1000) / 1000 - 0.5
        }

        var drift = 0.0
        return (0..<count).map { index in
            let t = Double(index) / Double(count - 1)
            drift = drift * 0.97 + jitter() * 0.5
            let wave = sin(t * .pi * 2.6) * 5.2 + sin(t * .pi * 5.1 + 1.2) * 2.4 + cos(t * .pi * 1.3) * 2.2
            let price = min(58, max(44, 51 + wave + drift))
            let date = calendar.date(byAdding: .day, value: index - (count - 1), to: end) ?? end
            return PricePoint(date: date, price: index == count - 1 ? 48 : price)
        }
    }
}
