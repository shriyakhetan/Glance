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

    // The comp repeats one brunch title and one SPF tip across every card of
    // its kind. Each card here speaks to its own category, its own artwork,
    // and the profile Glance has built: warm undertone, autumn palette,
    // work-first wardrobe, wavy hair.

    func header() -> HomeHeader {
        HomeHeader(
            greeting: "Good Morning, Mansi",
            subtitle: "Tuesday, Feb 18 • Brooklyn NY",
            avatar: "avatar-user"
        )
    }

    func blocks() -> [FeedBlock] {
        // Two-column runs between the wide cards. Consecutive runs flow on as
        // one (`FeedLayout.rows`), so what matters is each column's order:
        // posters, dark AI cards, tips and products never sit next to one
        // another — across the columns or one above the other.
        [
            .columns(
                left: [
                    // 321:684
                    .look(LookCard(
                        image: "look-brunch",
                        tag: MatchTag(category: "Fashion", match: "96% MATCH"),
                        title: "Chocolate knit and barrel jeans for a slow Sunday brunch",
                        style: .plain
                    ))
                ],
                right: [
                    .tip(TipCard(
                        category: .beauty,
                        shade: 1,
                        tag: MatchTag(category: "Skin tip"),
                        headline: "Overcast isn't off-duty. Most UV gets through cloud, so SPF stays on.",
                        highlight: "Most UV gets through cloud",
                        body: "UV rays penetrate clouds and glass. Daily protection is the most effective way to prevent premature ageing and sun damage.",
                        suggestions: [.aurodheaSPF, .neutrogenaCleanser],
                        chips: ["Find more", "SPF for combination skin", "Tinted options"],
                        action: .shop("Find Sunscreens")
                    )),
                    // 2831:1019 — `Start Chat`, the filler at its shortest.
                    .prompt(PromptCard(
                        style: .compact,
                        text: "Start a chat?",
                        chat: ChatTopic(
                            source: "Glance AI",
                            opening: "Hi! What's on your mind? I can put a look together, find you a gift, or settle a sizing question.",
                            options: ["Put a look together", "Find a gift", "Help with sizing"]
                        )
                    ))
                ]
            ),

            .columns(
                left: [
                    // 321:519
                    .rational(RationalCard(
                        image: "product-polo-card",
                        tint: Color(hex: 0x645F59),
                        // Read from the product rather than retyped, so the
                        // card and the screen it opens can't disagree. Elsewhere
                        // a brand is set only where it is printed on the
                        // product in the shot; the rest go without.
                        brand: Product.unifringePolo.brand,
                        claim: "Olive Green Polo Tee. Perfect for warm undertones",
                        reason: "Because it will brighten your appearance by enhancing your skin tone",
                        // Same source as the brand: the card used to quote
                        // $30 for a product its own detail screen sells at $48.
                        price: PriceTag(
                            current: Product.unifringePolo.price,
                            original: Product.unifringePolo.originalPrice
                        ),
                        note: "2k bought this",
                        productID: Product.unifringePolo.id
                    ))
                ],
                right: [
                    // 321:636
                    .look(LookCard(
                        image: "look-yellow-dress",
                        tag: MatchTag(category: "Fashion", match: "92% MATCH"),
                        title: "Butter-yellow linen midi for warm afternoons out",
                        likes: "2.2K like Dior",
                        action: "Style Me",
                        style: .feedback
                    ))
                ]
            ),

            // 29:881 — `Look Card Big`, gutter to gutter, asking for a read
            // under the photo. The caption stays Glance's own: the comp's
            // placeholder calls this airport shot a Sunday brunch look.
            .wide(.look(LookCard(
                image: "look-airport",
                tag: MatchTag(category: "Travel", match: "93% MATCH"),
                title: "Cream knit and wide-leg trousers: an easy airport look for your next trip",
                style: .feedback,
                isFullWidth: true,
                detailID: "airport"
            ))),

            // A poster tops one column and its twin ends the other, so the two never
            // sit side by side and, being one shape, add the same height to each.
            .columns(
                left: [
                    .poster(PosterCard(image: "poster-watch-rose", prompt: "Pick a watch I'll never take off")),
                    // 321:533
                    .signal(SignalCard(
                        avatar: "profile-hero",
                        question: "Do you keep a phone for three years or more?",
                        options: ["Yes", "No"],
                        acknowledgement: "Noted — %@. I'll weigh durability accordingly when I show you gadgets."
                    )),
                    // Was the yellow dress again; the office flat lay is its
                    // own look and the profile's most-worn occasion.
                    .look(LookCard(
                        image: "wear-office-day",
                        tag: MatchTag(category: "Workwear", match: "90% MATCH"),
                        title: "Olive polo, black trousers, brown loafers. Office-ready without the effort",
                        style: .plain
                    ))
                ],
                right: [
                    // 321:526 — the tube in the shot is Harry's Taming Cream.
                    .rational(RationalCard(
                        image: "product-harrys-spf",
                        tint: Color(hex: 0x1A355F),
                        brand: "Harry's",
                        claim: "Taming Cream. Light hold, natural finish",
                        reason: "Because you prefer clean, low-fuss grooming",
                        price: PriceTag(current: "$14", original: "$18")
                    )),
                    .tip(TipCard(
                        category: .beauty,
                        shade: 3,
                        tag: MatchTag(category: "Hair tip"),
                        headline: "Wavy hair frizzes in humid air. Scrunch in a leave-in while it's still damp.",
                        highlight: "Wavy hair frizzes in humid air",
                        body: "Waves lose definition when moisture from the air swells the hair shaft. Sealing it while damp keeps the pattern intact through the day.",
                        suggestions: [.harrysCream],
                        chips: ["Find more", "Styling for waves", "A humidity-proof routine"],
                        action: .shop("Show Products")
                    )),
                    .poster(PosterCard(image: "poster-gift-partner", prompt: "Pick a gift for my partner"))
                ]
            ),

            // Runs on into the block below as one flow (`FeedLayout.rows`), so
            // what matters is each column's order: the filler's two taller
            // states are kept clear of the question cards beside them.
            .columns(
                left: [
                    .signal(SignalCard(
                        avatar: "profile-hero",
                        question: "Would you wear the same outfit twice in a week?",
                        options: ["Happily", "Only if nobody noticed", "Never"],
                        acknowledgement: "Noted — %@. That tells me how hard to work your basics."
                    )),
                    // The artwork is a pet slicker brush; the comp's copy
                    // called it a jade roller.
                    .rational(RationalCard(
                        image: "product-brush",
                        tint: Color(hex: 0x42423E),
                        brand: "Hertzko",
                        claim: "Self-cleaning slicker brush. Less fur on the sofa",
                        reason: "Because you've been looking at pet care",
                        price: PriceTag(current: "$18", original: "$25")
                    ))
                ],
                right: [
                    .tip(TipCard(
                        category: .fashion,
                        shade: 2,
                        tag: MatchTag(category: "Workwear tip"),
                        headline: "Match your belt to your shoes. It pulls an office look together in one move.",
                        highlight: "Match your belt to your shoes",
                        body: "Leathers in the same tone read as a decision rather than an accident, which is most of what makes an outfit look put together.",
                        suggestions: [.bassLoafers, .unifringePolo],
                        chips: ["Find more", "Find similar outfits", "Browse belts"],
                        action: .explain
                    )),
                    // 321:587 — a sun spray, by the bottle's own label.
                    .rational(RationalCard(
                        image: "product-sunscreen",
                        tint: Color(hex: 0x584228),
                        brand: "Aurodhea",
                        claim: "SPF 30 Sun Spray. Weightless, and easy to reapply over makeup",
                        reason: "Because you asked for an SPF you'd actually reapply",
                        price: PriceTag(current: "$22", original: "$28"),
                        note: "2k bought this"
                    )),
                    // 2831:1017 — `Continue Chat`, picking a thread back up.
                    // The comp's copy, with its "you date" and "few ideas"
                    // put right.
                    .prompt(PromptCard(
                        style: .resume,
                        text: "Did you get the perfect dress for your date? I have a few ideas for you",
                        chat: ChatTopic(
                            source: "Date night",
                            opening: "Did you find the dress for your date? If not, I've pulled a few ideas that suit your warm undertone: a slip dress in deep olive, a rust wrap midi, and a black column dress with a low back.",
                            options: ["Show me the ideas", "I found one", "Still looking"]
                        )
                    ))
                ]
            ),

            .columns(
                left: [
                    .poster(PosterCard(image: "poster-shirts", prompt: "Curate shirts for me")),
                    // 3138:1867 — `Start Chat 2`. The comp's line reads "What to
                    // chat about something?".
                    .prompt(PromptCard(
                        style: .stacked,
                        text: "Want to chat about something?",
                        chat: ChatTopic(
                            source: "Glance AI",
                            opening: "Always. A look for the week, a gift, a routine — what are we working on?",
                            options: ["A look for this week", "A gift idea", "My skincare routine"]
                        )
                    )),
                    // 321:540
                    .rational(RationalCard(
                        image: "product-flowers",
                        tint: Color(hex: 0x7C6F3A),
                        brand: "Ferm Living",
                        claim: "Stacked ceramic vases. A shot of colour for a calm room",
                        reason: "Because your space leans neutral and could take one bold accent",
                        price: PriceTag(current: "$38", original: "$52")
                    )),
                    .tip(TipCard(
                        category: .beauty,
                        shade: 5,
                        tag: MatchTag(category: "Fragrance tip"),
                        headline: "Moisturise before you spray. Scent lasts longer on hydrated skin.",
                        highlight: "Scent lasts longer on hydrated skin",
                        body: "Fragrance oils evaporate faster from dry skin. An unscented lotion on pulse points gives them something to hold on to.",
                        suggestions: [.chanelNo5],
                        chips: ["Find more", "Scents like this", "Unscented lotions"],
                        action: .explain
                    ))
                ],
                right: [
                    .tip(TipCard(
                        category: .fashion,
                        shade: 4,
                        tag: MatchTag(category: "Style tip"),
                        headline: "Warm undertone? Swap stark white for cream or ecru near your face.",
                        highlight: "Swap stark white for cream or ecru",
                        body: "Bright white can make warm skin look sallow. Softer, yellow-based whites reflect warmth back and read as more polished.",
                        suggestions: [.uniqloMerino],
                        chips: ["Find more", "Find similar outfits", "Browse cream knits"],
                        action: .shop("Show Products")
                    )),
                    // 321:554 — its own export, distinct from 321:684.
                    .look(LookCard(
                        image: "look-brunch-alt",
                        tag: MatchTag(category: "Autumn edit", match: "88% MATCH"),
                        title: "A turtleneck and barrel jeans: your autumn uniform, minus the thinking",
                        style: .feedback
                    )),
                    .poster(PosterCard(image: "poster-pet", prompt: "Spoil my pet this month"))
                ]
            ),

            // 2:821 — the V7 story, artwork and publisher.
            .wide(.trend(TrendCard(
                image: "trend-redcarpet",
                publisher: "AP NEWS",
                publisherLogo: "publisher-apnews",
                headline: "Red carpet dropped 6 hours ago, these looks are tonight's most-searched."
            ))),

            .columns(
                left: [
                    // The swap the cream-not-white style tip asks for.
                    .rational(RationalCard(
                        image: "product-knit",
                        tint: Color(hex: 0x6D5437),
                        brand: "Uniqlo",
                        claim: "Merino crewneck in oatmeal. Your cream-not-white swap, done",
                        reason: "Because warm whites suit your undertone better than stark white",
                        price: PriceTag(current: "$64", original: "$85")
                    ))
                ],
                right: [
                    // 321:547
                    .rational(RationalCard(
                        image: "product-chanel",
                        tint: Color(hex: 0x41413F),
                        brand: "Chanel",
                        claim: "N°5 Eau de Parfum, Red Edition. Bold and iconic",
                        reason: "Because you gravitate towards warm, sophisticated fragrances",
                        price: PriceTag(current: "$132", original: "$165")
                    ))
                ]
            ),

            .columns(
                left: [
                    .poster(PosterCard(image: "poster-watch-classic", prompt: "Pick a watch I'll never take off")),
                    .rational(RationalCard(
                        image: "product-loafers",
                        tint: Color(hex: 0x68543C),
                        brand: "G.H. Bass",
                        claim: "Suede penny loafers. Polished for the office, easy at the weekend",
                        reason: "Because loafers are already your most-worn office shoe",
                        price: PriceTag(current: "$89", original: "$120")
                    )),
                    .tip(TipCard(
                        category: .fashion,
                        shade: 3,
                        tag: MatchTag(category: "Colour tip"),
                        headline: "Autumn palette? Rust, olive and camel flatter you more than black.",
                        highlight: "Rust, olive and camel",
                        body: "Warm, muted colours echo the warmth in your skin. Black can drain it, especially close to the face.",
                        suggestions: [.unifringePolo, .bassLoafers],
                        chips: ["Find more", "Find similar outfits", "Browse rust and camel"],
                        action: .explain
                    ))
                ],
                right: [
                    .tip(TipCard(
                        category: .beauty,
                        shade: 2,
                        tag: MatchTag(category: "Skin tip"),
                        headline: "Wear SPF daily? Cleanse twice at night. Once won't lift it all.",
                        highlight: "Once won't lift it all",
                        body: "Sunscreen is built to stay put. A first cleanse breaks it down; the second actually cleans the skin underneath.",
                        suggestions: [.neutrogenaCleanser, .aurodheaSPF],
                        chips: ["Find more", "Build my night routine", "Gentle cleansers"],
                        action: .shop("Find Cleansers")
                    )),
                    .rational(RationalCard(
                        image: "product-cleanser",
                        tint: Color(hex: 0x4D5656),
                        brand: "Neutrogena",
                        claim: "Hydrating gel cleanser. Gentle enough for twice a day",
                        reason: "Because you asked for a gentler evening routine",
                        price: PriceTag(current: "$24", original: "$32")
                    )),
                    .poster(PosterCard(image: "poster-gift-budget", prompt: "Find a gift under budget"))
                ]
            )
        ]
    }
}
