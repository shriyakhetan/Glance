import Foundation

/// Product lookup. Swap this for a networked implementation without touching views.
struct ProductRepository {
    static let shared = ProductRepository()

    func product(id: String) -> Product {
        Product.unifringePolo
    }
}

extension Product {
    /// `T-Shirt Product - L2 - New 01` (V7, 32:2523).
    static let unifringePolo = Product(
        id: "unifringe-derrick-rose-polo",
        brand: "UNIFRINGE",
        name: "Men Derrick Rose Polo Collar T-shirt",
        price: "$48.00",
        originalPrice: "$72.00",
        discount: "50% Off",
        // The feed card's own shot leads, so the zoom transition from Home lands
        // on the same photograph it grew out of; the comp's second frame, the
        // polo worn, follows it.
        images: [
            "product-polo-card",
            "product-polo-2",
            "product-polo-1",
            "product-polo-3",
            "product-polo-4",
            "product-polo-5"
        ],

        rating: "4.2",
        ratingCount: "(342)",
        socialProof: SocialProof(
            buyers: ["buyer-1", "buyer-2", "buyer-3"],
            headline: "412 people bought this in the last 30 days.",
            detail: "36 bought in the last 24 hours"
        ),

        match: ProductMatch(
            verdict: "strong match",
            score: 87,
            matches: [
                MatchPoint(icon: .fit, lead: "Relaxed fit,", rest: "same as your usual"),
                MatchPoint(icon: .neckline, lead: "V-neck,", rest: "like most of your tees"),
                MatchPoint(icon: .colour, lead: "Olive,", rest: "in your earthy-tone palette"),
                MatchPoint(icon: .price, lead: "$28,", rest: "inside your usual range")
            ],
            mismatches: [
                MatchPoint(icon: .occasion, lead: "Best for date night,", rest: "but you mostly shop for the office"),
                MatchPoint(icon: .pattern, lead: "Block print,", rest: "but you usually prefer subtle patterns")
            ],
            question: "Did we read your preferences right?",
            answers: ["Yes", "Not quite"]
        ),

        sizeGuess: SizeGuess(
            size: "L",
            rationale: "Recommended based on the relaxed fits you've bought before."
        ),
        availableSizes: ["XS", "S", "M", "L", "XL"],

        colors: [
            ColorOption(name: "Navy Blue", image: "color-navy"),
            ColorOption(name: "White", image: "color-white"),
            ColorOption(name: "Grey", image: "color-grey")
        ],
        moreColors: 6,

        priceTrend: PriceTrend(
            verdict: "Great price",
            detail: "34% below its usual price. It dropped three days ago.",
            buyLabel: "Buy $99",
            lowest: 80,
            usual: 150,
            highest: 250,
            current: 99
        ),
        delivery: Delivery(
            lead: "Free Delivery by",
            date: "Thursday, Aug 30th",
            place: "New York",
            facts: [
                DeliveryFact(icon: .fees, label: "Shipping fees", value: "$2"),
                DeliveryFact(icon: .returnWindow, label: "Return Window", value: "7 Days"),
                DeliveryFact(icon: .exchange, label: "Exchange Available", value: "Size & Color"),
                DeliveryFact(icon: .pickup, label: "Return Pickup", value: "Free doorstep")
            ]
        ),
        fitQuestion: FitQuestion(
            label: "Help us improve",
            text: "Do you usually prefer a relaxed fit?",
            options: ["Yes", "I size down"],
            acknowledgement: "Noted. I'll fold that into every size I suggest."
        ),
        outfits: [
            // `4 Product` (32:2769). The pieces are cut from two flat-lay
            // sprites, so each carries the comp's own crop.
            Outfit(
                title: "Casual Date",
                summary: "A relaxed combination for a more laid-back date night.",
                tiles: [
                    OutfitTile(
                        frame: CompRect(0, 5.06, 105, 140),
                        content: .piece(image: "outfit-polo-flatlay", art: CompRect(13.27, 8.77, 76.875, 123.75), crop: CompRect(0, -15.83, 206.25, 155.4)),
                        swappable: false
                    ),
                    OutfitTile(
                        frame: CompRect(11, 153.06, 94, 94),
                        content: .piece(image: "outfit-flatlay", art: CompRect(23, 17, 47.151, 62.868), crop: CompRect(-135.28, -8.42, 195.12, 107))
                    ),
                    OutfitTile(
                        frame: CompRect(113, 0.06, 95, 95),
                        content: .piece(image: "outfit-flatlay", art: CompRect(7.57, 28.1, 75.626, 49.157), crop: CompRect(-227.82, -118.16, 328.6, 180.2))
                    ),
                    OutfitTile(frame: CompRect(216, 167.06, 72, 72), content: .add),
                    OutfitTile(
                        frame: CompRect(113, 103.06, 95, 149),
                        content: .piece(image: "outfit-flatlay", art: CompRect(18, 23, 59.825, 112.025), crop: CompRect(-81.52, 0, 203.88, 111.8))
                    ),
                    OutfitTile(
                        frame: CompRect(216, 36.06, 82, 123),
                        content: .piece(image: "outfit-bag", art: CompRect(10, 14, 63, 95), crop: nil)
                    )
                ]
            ),
            // `3 Product` (32:2802).
            Outfit(
                title: "Arcade Day",
                summary: "A relaxed combination for a more laid-back date night.",
                tiles: [
                    OutfitTile(
                        frame: CompRect(45, 4.97, 105, 140),
                        content: .piece(image: "outfit-polo-flatlay", art: CompRect(13.27, 8.77, 76.875, 123.75), crop: CompRect(0, -15.83, 206.25, 155.4)),
                        swappable: false
                    ),
                    OutfitTile(
                        frame: CompRect(56, 152.97, 94, 94),
                        content: .piece(image: "outfit-sunglasses", art: CompRect(12, 29.09, 70, 35), crop: CompRect(-5, -21, 80, 80))
                    ),
                    OutfitTile(frame: CompRect(158, -0.03, 95, 95), content: .add),
                    OutfitTile(
                        frame: CompRect(158, 102.97, 95, 149),
                        content: .piece(image: "outfit-trousers", art: CompRect(13, 28.09, 69, 100), crop: CompRect(-56.68, 0.32, 183.1, 100.02))
                    )
                ]
            )
        ],
        moreLikeThis: [
            SuggestedProduct(
                style: .look,
                image: "more-olive-polo",
                art: CompRect(-24.5, 0.1, 206, 308),
                tint: 0x616046,
                title: "Olive Long-Sleeve Polo",
                price: "$45",
                wasPrice: "$64"
            ),
            SuggestedProduct(
                style: .product,
                image: "more-olive-longsleeve",
                art: CompRect(-6.85, -7.93, 186.36, 245.88),
                tint: 0x22210F,
                brand: "HARRY'S",
                title: "Olive Long-Sleeve Polo",
                price: "$30",
                wasPrice: "$64"
            ),
            SuggestedProduct(
                style: .product,
                image: "more-olive-check",
                art: CompRect(-3.9, -0.95, 177.58, 237.89),
                tint: 0x22210F,
                brand: "HARRY'S",
                title: "Olive Check Polo",
                price: "$30",
                wasPrice: "$64"
            )
        ],
        suggestionChips: ["Buy Now", "Try On", "Ways to style this", "Show cheaper options"]
    )
}
