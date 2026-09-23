import SwiftUI

/// One vertical slice of the feed. The design alternates between two-column
/// masonry runs and cards that span the full width.
enum FeedBlock: Identifiable {
    case columns(left: [FeedItem], right: [FeedItem])
    case wide(FeedItem)

    var id: String {
        switch self {
        case .columns(let l, let r): return "cols-" + (l.first?.id.uuidString ?? "") + (r.first?.id.uuidString ?? "")
        case .wide(let item): return "wide-" + item.id.uuidString
        }
    }
}

/// Everything the home screen needs. Swap the implementation for a networked
/// one and no view has to change.
protocol FeedRepository {
    func header() -> HomeHeader
    func blocks() -> [FeedBlock]
}

/// Content follows the `Home` frame (321:518).
///
/// Card artwork is left on `ImageCrop`'s default — a centred cover fill. The
/// comp offsets each node's art rect by hand, but reproducing those made the
/// framing read as off across the feed, so every card now fills from centre.
struct MockFeedRepository: FeedRepository {

    // Shared copy, repeated verbatim across the comp's cards.
    private static let spfBody = "UV rays can penetrate clouds and glass. Daily protection is the #1 way to prevent premature aging and sun damage."
    private static let brunchTitle = "Perfect outfit for Sunday brunch with friends"
    private static let conversationPrompt = "Start a conversation with Glance AI"

    private static let routineSteps = [
        RoutineStep(title: "Cleanser", detail: "Refresh and rebalance your skin"),
        RoutineStep(title: "Moisturizer", detail: "Strengthen your skin barrier with"),
        RoutineStep(title: "SPF 50", detail: "Your most important layer today—protect")
    ]

    func header() -> HomeHeader {
        HomeHeader(
            greeting: "Good Morning, Mansi",
            subtitle: "Tuesday, Feb 18 • Brooklyn NY",
            avatar: "avatar-user"
        )
    }

    func blocks() -> [FeedBlock] {
        [
            .columns(
                left: [
                    // 321:684
                    .look(LookCard(
                        image: "look-brunch",
                        tag: MatchTag(category: "Beauty"),
                        title: Self.brunchTitle
                    )),
                    // 321:519
                    .rational(RationalCard(
                        image: "product-polo-card",
                        tint: Color(hex: 0x645F59),
                        claim: "Olive Green Polo Tee. Perfect for warm undertones",
                        reason: "Because it will brighten your appearance by enhancing your skin tone",
                        price: PriceTag(current: "$30", original: "$64"),
                        note: "2k bought this",
                        productID: Product.unifringePolo.id
                    ))
                ],
                right: [
                    .tip(TipCard(
                        tint: Color(hex: 0x6B3B3B),
                        ink: Color(hex: 0xEAD6D6),
                        tag: MatchTag(category: "Skin tip"),
                        headline: "Don't skip SPF, even on cloudy days. It’s",
                        body: Self.spfBody
                    )),
                    // 321:636
                    .look(LookCard(
                        image: "look-yellow-dress",
                        tag: MatchTag(category: "Beauty"),
                        title: Self.brunchTitle,
                        likes: "2.2K like Dior",
                        action: "Style Me"
                    )),
                    .prompt(PromptCard(text: Self.conversationPrompt))
                ]
            ),

            // 321:742 — line art 140×120 at (253, 32); card right edge is 380.
            .wide(.routine(RoutineCard(
                tag: MatchTag(category: "Health"),
                headline: "94% of the people with your skin type use this for their skin glow",
                subhead: "3 Step ~ Morning Routine",
                subheadInk: Color(hex: 0x8CFFC9),
                steps: Self.routineSteps,
                background: Color(hex: 0x003435),
                illustration: "il-health",
                illustrationSize: CGSize(width: 140, height: 120),
                illustrationInset: CGSize(width: 13, height: Space.xxl),
                glow: Color.white.opacity(0.64)
            ))),

            .columns(
                left: [
                    .tip(TipCard(
                        tint: Color(hex: 0x38492C),
                        ink: .white,
                        tag: MatchTag(category: "Skin tip"),
                        headline: "Don't skip SPF, even on cloudy days.",
                        body: Self.spfBody
                    )),
                    .look(LookCard(
                        image: "look-yellow-dress",
                        tag: MatchTag(category: "Beauty"),
                        title: Self.brunchTitle
                    )),
                    // 321:533
                    .signal(SignalCard(
                        avatar: "profile-hero",
                        question: "Do you keep a phone for three years or more?",
                        options: ["Yes", "No"],
                        acknowledgement: "Noted — %@. I'll weigh durability accordingly when I show you gadgets."
                    )),
                    .rational(RationalCard(
                        image: "product-brush",
                        tint: Color(hex: 0x42423E),
                        claim: "Jade Roller & Vitamin E. Boost your natural glow",
                        reason: "Because you mentioned wanting a better skincare routine",
                        price: PriceTag(current: "$30", original: "$64")
                    )),
                    .prompt(PromptCard(text: Self.conversationPrompt))
                ],
                right: [
                    // 321:526
                    .rational(RationalCard(
                        image: "product-harrys-spf",
                        tint: Color(hex: 0x1A355F),
                        claim: "Harry's Post-Shave Balm. Smooth, hydrating care",
                        reason: "Because you prefer clean, gentle grooming essentials",
                        price: PriceTag(current: "$30", original: "$64")
                    )),
                    // 321:587
                    .rational(RationalCard(
                        image: "product-sunscreen",
                        tint: Color(hex: 0x584228),
                        claim: "Tinted SPF 30 Moisturizer. Daily glow + protection",
                        reason: "Because you mentioned needing daily SPF for your skin type",
                        price: PriceTag(current: "$30", original: "$64"),
                        note: "2k bought this"
                    )),
                    // 321:705 — flattened campaign art.
                    .brand(BrandCard(image: "brand-dior")),
                    .signal(SignalCard(
                        avatar: "profile-hero",
                        question: "Would you wear the same outfit twice in a week?",
                        options: ["Happily", "Only if nobody noticed", "Never"],
                        acknowledgement: "Noted — %@. That tells me how hard to work your basics."
                    ))
                ]
            ),

            .wide(.trend(TrendCard(
                image: "trend-metgala",
                badge: "Trending News on Met Gala 2026",
                headline: "Jennifer Lopez & Nicole Kidman showcase their clothes at Met Gala",
                tint: Color(hex: 0x0B1A38)
            ))),

            .columns(
                left: [
                    // 321:772
                    .brand(BrandCard(image: "brand-gucci")),
                    // 321:540
                    .rational(RationalCard(
                        image: "product-flowers",
                        tint: Color(hex: 0x7C6F3A),
                        claim: "Ceramic Vase. Bold warmth and color for your space",
                        reason: "Because your style leans towards bold, earthy accents"
                    )),
                    .tip(TipCard(
                        tint: Color(hex: 0x3A4763),
                        ink: .white,
                        tag: MatchTag(category: "Skin tip"),
                        headline: "Don't skip SPF, even on cloudy days.",
                        body: Self.spfBody
                    ))
                ],
                right: [
                    .tip(TipCard(
                        tint: Color(hex: 0x2C4A52),
                        ink: .white,
                        tag: MatchTag(category: "Skin tip"),
                        headline: "Don't skip SPF, even on cloudy days.",
                        body: Self.spfBody
                    )),
                    // 321:554 — its own export, distinct from 321:684.
                    .look(LookCard(
                        image: "look-brunch-alt",
                        tag: MatchTag(category: "Beauty"),
                        title: Self.brunchTitle
                    )),
                    // 321:547
                    .rational(RationalCard(
                        image: "product-chanel",
                        tint: Color(hex: 0x41413F),
                        claim: "No. 5 Red Edition Parfum. Bold, iconic fragrance",
                        reason: "Because you gravitate towards warm, sophisticated fragrances"
                    ))
                ]
            ),

            // 321:713 — line art 151×160 at (243, 20); a larger, higher bleed.
            .wide(.routine(RoutineCard(
                tag: MatchTag(category: "Fashion"),
                headline: "94% of the people with your skin type use this for their skin glow",
                subhead: "3 Step ~ Morning Routine",
                subheadInk: Color(hex: 0x7FA8FF),
                steps: Self.routineSteps,
                background: Color(hex: 0x001C35),
                illustration: "il-fashion",
                illustrationSize: CGSize(width: 151, height: 160),
                illustrationInset: CGSize(width: 14, height: 20),
                glow: Color(hex: 0x7FA8FF, opacity: 0.5)
            )))
        ]
    }
}
