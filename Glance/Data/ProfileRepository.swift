import Foundation

protocol ProfileRepository {
    func profile() -> StyleProfile
}

/// `D0- Profile` (Surface Art Design Library, 2490:1619).
struct MockProfileRepository: ProfileRepository {
    func profile() -> StyleProfile {
        StyleProfile(
            avatar: "profile-hero",
            subtitle: "Building from your photo and your browsing",
            location: "Bengaluru",
            weather: "27° light rain",
            editorialLead: "Here's what Glance ",
            editorialEmphasis: "understands",
            editorialTail: " about you.",
            editorialBody: "A first read based on your photo. Some of it will be off, as these are AI predictions. The more you chat, the better it knows you.",
            vibes: [
                VibeChip(text: "Clean Bold"),
                VibeChip(text: "Quiet Luxury"),
                VibeChip(text: "Minimalist")
            ],
            // Body and Face use Figma's pre-rendered circles; Skin and Hair
            // frame a source photo, since Figma will not export those two.
            analysis: [
                AnalysisCard(
                    portrait: "analysis-body",
                    metricLabel: "Proportions",
                    metricValue: "Balanced",
                    title: "Body Frame",
                    headline: "Athletic frame",
                    detail: "Shoulders and hips sit close to equal, with a lightly defined waist.",
                    cta: "Find your fit →",
                    chatOpening: "Your shoulders and hips sit close to even with a lightly defined waist, so shape comes from what you nip in rather than what you pad out. Wrap dresses, high-rise straight trousers and a belted overshirt all sit well on that frame. Where shall we start?",
                    chatOptions: ["Show me tops", "Trousers that work", "What to skip", "Not now"]
                ),
                AnalysisCard(
                    portrait: "analysis-face",
                    metricLabel: "Shape",
                    metricValue: "Soft taper",
                    title: "Face Shape",
                    headline: "Oval Face",
                    detail: "Most lengths and necklines work on you, so lead with what you like.",
                    cta: "Cuts and Frames →",
                    chatOpening: "An oval face carries most cuts and frames, so this is preference more than rules. A blunt bob, curtain bangs, and angular frames like rectangles or wayfarers all play against your soft taper. What would you like to see?",
                    chatOptions: ["Haircuts to try", "Frames that suit me", "Necklines", "Not now"]
                ),
                AnalysisCard(
                    // 2490:1722 — the studio portrait blown up to 204×163 and
                    // pushed off centre, which lands the circle on her cheek.
                    portrait: "analysis-skin",
                    crop: ImageCrop(width: 204, height: 163, x: -52.74, y: -54, reference: 76),
                    metricLabel: "Skin health",
                    metricValue: "Average",
                    title: "Skin Type",
                    headline: "Combination",
                    detail: "Your T-zone and cheeks need different moisturizers, not one for all",
                    cta: "Build your routine →",
                    chatOpening: "Combination skin wants two different things at once — something light where your T-zone gets oily, something richer where your cheeks feel tight. Three steps morning and night covers it. Shall I lay one out?",
                    chatOptions: ["Morning routine", "Night routine", "Keep it under ₹1,000", "Not now"]
                ),
                AnalysisCard(
                    // 2490:1743 — 129×103, off centre, so the circle sits on the
                    // back of her hair rather than the shoulders around it.
                    portrait: "analysis-hair",
                    crop: ImageCrop(width: 129, height: 103, x: -12.74, y: -24, reference: 76),
                    metricLabel: "Hair health",
                    metricValue: "Good",
                    title: "Hair Type",
                    headline: "Wavy",
                    detail: "Heavy creams flatten your waves. Lightweight leave-ins hold them.",
                    cta: "Build your routine →",
                    chatOpening: "Waves lose their shape under weight. A lightweight leave-in, scrunch-drying rather than rough-drying, and washing every second or third day will hold the pattern far longer than a heavy cream. What would help most?",
                    chatOptions: ["Styling steps", "Products for waves", "How often to wash", "Not now"]
                )
            ],
            dimensions: [
                DimensionCard(
                    title: "Fashion & Style",
                    subtitle: "Warm undertone · Autumn palette · routine unknown",
                    blocks: [
                        .facts(title: "Fit & sizing", tag: .yours("Your go to"), rows: [
                            FactRow(label: "Top/Dress", value: "Oversized, Slim"),
                            FactRow(label: "Neckline", value: "V Neck, Off Shoulder"),
                            FactRow(label: "Bottom", value: "Loose, Regular"),
                            FactRow(label: "Bottom Rise preferences", value: "High"),
                            FactRow(label: "Top wear Preferred fit", value: "Relaxed"),
                            FactRow(label: "Pattern Preference", value: "No prints")
                        ]),
                        // Tracks at the widths the comp draws them: 243, 183
                        // and 63 of 316.
                        .meters(title: "Aesthetic mix", tag: .aiRead, rows: [
                            MeterRow(label: "Quiet luxury/minimal", reading: "High", percent: 77),
                            MeterRow(label: "Old money/classic", reading: "Medium", percent: 58),
                            MeterRow(label: "Streetwear", reading: "Low", percent: 20)
                        ]),
                        .palette(title: "Palette for you", tag: .aiRead, swatches: [
                            PaletteSwatch(name: "Espresso", color: 0x451A03),
                            PaletteSwatch(name: "Sand", color: 0xEAB308),
                            PaletteSwatch(name: "Sand", color: 0xEAB308),
                            PaletteSwatch(name: "Cream", color: 0xFEF08A),
                            PaletteSwatch(name: "Sage", color: 0xA7F3D0)
                        ])
                    ],
                    headerSpacing: 12
                ),
                DimensionCard(
                    title: "Occasion",
                    subtitle: "Work-first · Weekend casual · Festive emerging",
                    blocks: [
                        // The comp draws Work and Casual to the same 264 of
                        // 316; a Medium reading takes Medium's width from the
                        // mix above.
                        .meters(title: "Frequency", tag: .aiRead, rows: [
                            MeterRow(label: "Work", reading: "High", percent: 84),
                            MeterRow(label: "Casual", reading: "Medium", percent: 58)
                        ], spacing: 16, rowInset: 8)
                    ]
                ),
                DimensionCard(
                    title: "Brand",
                    subtitle: "High street · Mid-range · Occasional splurge",
                    blocks: [
                        .facts(title: "Frequency", tag: .aiRead, rows: [
                            FactRow(label: "Zara", value: "Clothing"),
                            FactRow(label: "Nike", value: "Footwear"),
                            FactRow(label: "Puma", value: "Clothing, Footwear")
                        ], spacing: 16)
                    ]
                ),
                DimensionCard(
                    title: "Gadgets",
                    subtitle: "Apple ecosystem · minimal, matte taste",
                    blocks: [
                        .facts(title: "Ecosystem", tag: .yours("Your"), rows: [
                            FactRow(label: "Phone", value: "iPhone 17 pro")
                        ])
                    ]
                )
            ]
        )
    }
}
