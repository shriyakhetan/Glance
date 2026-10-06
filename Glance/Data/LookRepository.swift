import Foundation

/// The looks that have a page of their own.
struct LookRepository {
    static let shared = LookRepository()

    func look(id: String) -> LookDetail {
        switch id {
        default: return .airport
        }
    }
}

extension LookDetail {
    /// `Look L2` (6215:7530), opened from the big look card. The comp's copy
    /// calls the airport shot a Sunday brunch look; the title follows the
    /// card's own caption instead.
    static let airport = LookDetail(
        id: "airport",
        title: "Perfect outfit - Easy airport look",
        image: "look-airport",
        pieces: [.zaraKnit, .zaraTrousers, .rayBanRound],
        // Two knits down the first column, the trousers over the way into
        // more in the second, as the comp pairs them.
        more: [.mangoKnitTop, .cosMockNeck, .hmLinenTrousers]
    )
}

// MARK: - Products

extension ShopProduct {
    // The pieces in the airport look, cut out on white. Sizes are the comp's
    // own, in the 68×86 thumbnail and the 194×234 tile.
    private static let knitArt = Art.cutout(thumb: CGSize(width: 40.3, height: 65.29), tile: CGSize(width: 104.86, height: 169.87))
    private static let trousersArt = Art.cutout(thumb: CGSize(width: 23.25, height: 55.84), tile: CGSize(width: 74.91, height: 179.94))
    private static let sunglassesArt = Art.cutout(thumb: CGSize(width: 56.86, height: 33.51), tile: CGSize(width: 150, height: 88.4))

    static let zaraKnit = ShopProduct(
        image: "look-knit-top", art: knitArt, brand: "ZARA", name: "Knit Sweater",
        price: PriceTag(current: "$50", original: "$80"),
        note: "Soft enough for a long flight, and cream warms your undertone."
    )
    static let zaraTrousers = ShopProduct(
        image: "look-wide-trousers", art: trousersArt, brand: "ZARA", name: "Wide-Leg Trousers",
        price: PriceTag(current: "$46", original: "$60"),
        note: "Wide and fluid, so they stay comfortable through a day of travel."
    )
    static let rayBanRound = ShopProduct(
        image: "look-sunglasses", art: sunglassesArt, brand: "Ray-Ban", name: "Round Sunglasses",
        price: PriceTag(current: "$120", original: "$165"),
        note: "Tortoiseshell picks up the warm tones in the knit."
    )

    static let mangoKnitTop = ShopProduct(
        image: "look-knit-top", art: knitArt, brand: "Mango", name: "Ribbed Sleeveless Knit Top",
        price: PriceTag(current: "$45", original: "$56"),
        note: "The same cream, in a lighter rib for warmer days."
    )
    static let hmLinenTrousers = ShopProduct(
        image: "look-wide-trousers", art: trousersArt, brand: "H&M", name: "Linen-Blend Wide Trousers",
        price: PriceTag(current: "$39", original: "$49"),
        note: "A linen blend that keeps the look's ease."
    )
    static let cosMockNeck = ShopProduct(
        image: "look-knit-top", art: knitArt, brand: "COS", name: "Fine-Knit Mock-Neck Top",
        price: PriceTag(current: "$59", original: "$74"),
        note: "A finer knit for when the look goes to the office."
    )

    // From the feed, photographed in a setting rather than cut out.
    static let aurodheaSPF = ShopProduct(
        image: "product-sunscreen", art: .scene, brand: "Aurodhea", name: "SPF 30 Sun Spray",
        price: PriceTag(current: "$22", original: "$28"),
        note: "Weightless over makeup, so it actually gets reapplied."
    )
    static let neutrogenaCleanser = ShopProduct(
        image: "product-cleanser", art: .scene, brand: "Neutrogena", name: "Hydrating Gel Cleanser",
        price: PriceTag(current: "$24", original: "$32"),
        note: "Lifts the day's SPF without stripping combination skin."
    )
    static let harrysCream = ShopProduct(
        image: "product-harrys-spf", art: .scene, brand: "Harry's", name: "Taming Cream",
        price: PriceTag(current: "$14", original: "$18"),
        note: "A light hold that keeps waves defined without the crunch."
    )
    static let bassLoafers = ShopProduct(
        image: "product-loafers", art: .scene, brand: "G.H. Bass", name: "Suede Penny Loafers",
        price: PriceTag(current: "$89", original: "$120"),
        note: "Brown suede, to match a brown belt the way the tip asks."
    )
    static let unifringePolo = ShopProduct(
        image: "product-polo-card", art: .scene, brand: "Unifringe", name: "Olive Green Polo",
        price: PriceTag(current: "$48", original: "$72"),
        note: "Olive sits in your autumn palette and flatters more than black."
    )
    static let chanelNo5 = ShopProduct(
        image: "product-chanel", art: .scene, brand: "Chanel", name: "N°5 Eau de Parfum",
        price: PriceTag(current: "$132", original: "$165"),
        note: "On moisturised pulse points, it lasts the evening."
    )
    static let uniqloMerino = ShopProduct(
        image: "product-knit", art: .scene, brand: "Uniqlo", name: "Merino Crewneck, Oatmeal",
        price: PriceTag(current: "$64", original: "$85"),
        note: "The cream-not-white swap, in a fine merino."
    )
}
