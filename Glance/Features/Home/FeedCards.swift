import SwiftUI

// MARK: - Look

/// Photo card with the shade-match footer. `Look` in Figma.
/// `Look Card` (V7, 16:240) — a photograph with its caption, optionally asking
/// for a thumbs up or down, in all five of the set's variants.
///
/// `card.style` picks the authored variant: `plain`, `feedback` or
/// `highlighted`. The other two — *thumbs up* and *thumbs down* — are where a
/// feedback card goes once tapped, so they are state here rather than data.
///
/// Every feedback variant is the same height (346 at the comp's 170 width).
/// Answering doesn't grow the card; the photograph's window shrinks from the
/// bottom to make room for the reply, its caption riding up with it, so the
/// masonry around it never jumps.
struct LookCardView: View {
    let card: LookCard
    var onGiveFeedback: () -> Void = {}

    enum Feedback: Hashable {
        case none, up, down
    }

    @State private var feedback: Feedback

    init(card: LookCard, feedback: Feedback = .none, onGiveFeedback: @escaping () -> Void = {}) {
        self.card = card
        self.onGiveFeedback = onGiveFeedback
        _feedback = State(initialValue: card.style.asksForFeedback ? feedback : .none)
    }

    /// The photograph's frame at rest. One proportion for both sizes: the
    /// column card is 170×302 in the comp (16:242), the big card 364×647
    /// (19:837) — the same shape, scaled.
    private let photoAspect: CGFloat = 170.0 / 302.0

    /// The big card (19:837) sets its caption a size up, on a deeper scrim,
    /// with its heart set further in.
    private var isBig: Bool { card.isFullWidth }
    /// The thumbs row: two 32pt targets with 6pt above and below.
    private static let feedbackRowHeight: CGFloat = 44
    private static let cornerRadius: CGFloat = Radius.xl

    /// The comp's own scrim and panel — what `ImageTone` gives for its photo,
    /// and what a card falls back to if its photo can't be sampled.
    private static let fallbackShade = Color(hex: 0x284358)
    private static let fallbackPanel = Color(hex: 0x203546)
    private static let plainFill = Color(hex: 0x292929)

    /// Taken from this card's own photograph at the scrim's lightness, so the
    /// fade settles into a colour that belongs to the picture.
    private var shade: Color {
        ImageTone.color(for: card.image, lightness: ImageTone.scrimLightness, fallback: Self.fallbackShade)
    }

    /// The same hue a step darker — the panel the scrim gives way to.
    private var panel: Color {
        ImageTone.color(for: card.image, lightness: ImageTone.panelLightness, fallback: Self.fallbackPanel)
    }

    var body: some View {
        sizing
            .overlay { content }
            .background(card.style.asksForFeedback ? panel : Self.plainFill)
            .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
            .overlay { highlightRule }
            .overlay(alignment: .topTrailing) {
                WishlistButton(tone: .scrim).padding(isBig ? Space.lg : Space.md)
            }
            .animation(.spring(response: 0.38, dampingFraction: 0.86), value: feedback)
    }

    // MARK: - Layout

    /// Fixes the card's height — the photograph at rest, plus the thumbs row
    /// when there is one — so nothing that happens inside can change it.
    private var sizing: some View {
        VStack(spacing: 0) {
            Color.clear.aspectRatio(photoAspect, contentMode: .fit)
            if card.style.asksForFeedback {
                Color.clear.frame(height: Self.feedbackRowHeight)
            }
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            // Takes whatever height the rows below leave it.
            photo
                .frame(maxHeight: .infinity)

            if card.style.asksForFeedback {
                feedbackRow
                reply
            }
        }
        .padding(.bottom, feedback == .none ? 0 : Space.md)
    }

    /// The photograph is always drawn at its full resting height and pinned to
    /// the top; the window over it is what shrinks. So the crop sheds the foot
    /// of the photo, never the face.
    private var photo: some View {
        Color.clear
            .overlay(alignment: .top) {
                // `.fill`, not `.fit`: the frame can be taller than the window,
                // and fitting would shrink its width to match.
                Color.clear
                    .aspectRatio(photoAspect, contentMode: .fill)
                    .overlay { CroppedImage(name: card.image, crop: card.crop) }
            }
            .overlay { if isBig { bigScrim } }
            .overlay(alignment: .bottom) { caption }
            // Only the corner that meets the panel is rounded; the rest are
            // the card's own (16:242).
            .clipShape(UnevenRoundedRectangle(bottomTrailingRadius: Self.cornerRadius, style: .continuous))
            // `Shadow/Floating` — falls onto the panel below.
            .glanceFloatingShadow()
    }

    /// `Shade Match Card` (16:244): the caption on a scrim that fades in from
    /// 15% of the way down its own band. The big card's caption sits on
    /// `bigScrim` instead, so it carries no band of its own.
    @ViewBuilder
    private var caption: some View {
        if isBig {
            // 19:840 — `Headline/Small` with 24pt all round.
            Text(card.title)
                .glanceText(.headlineS)
                .foregroundStyle(GlanceColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Space.xl)
        } else {
            Text(card.title)
                .glanceText(.bodyCaption)
                .foregroundStyle(GlanceColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Space.lg)
                .padding(.top, 48)
                .padding(.bottom, Space.lg)
                .background {
                    LinearGradient(
                        stops: [
                            .init(color: shade.opacity(0), location: 0.147),
                            .init(color: shade, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
    }

    /// The big card's scrim (19:839) is a fixed band rather than one sized to
    /// its caption: the bottom 260 of the comp's 647pt, fading in from 14.7%
    /// of the way down that band. Written as stops over the whole photo, so it
    /// keeps that proportion at any width without measuring anything.
    private var bigScrim: some View {
        let band = 260.0 / 647.0
        let fadeStart = 1 - band + band * 0.147
        return LinearGradient(
            stops: [
                .init(color: shade.opacity(0), location: fadeStart),
                .init(color: shade, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .allowsHitTesting(false)
    }

    // MARK: - Feedback

    private var feedbackRow: some View {
        HStack(spacing: Space.xxl) {
            thumb(.up)
            thumb(.down)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Space.xs)
    }

    /// Outlined at 18pt until chosen, then the filled 24pt glyph. In the comp
    /// the filled state is an animated icon; this keeps its resting frame and
    /// lets a spring stand in for the motion.
    private func thumb(_ choice: Feedback) -> some View {
        let isUp = choice == .up
        let isChosen = feedback == choice

        return Button {
            // Tapping the chosen thumb again takes the answer back.
            feedback = isChosen ? .none : choice
        } label: {
            ZStack {
                if isChosen {
                    Image(isUp ? "ic-thumb-up-filled" : "ic-thumb-down-filled")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                } else {
                    Image(isUp ? "ic-thumb-up" : "ic-thumb-down")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .transition(.opacity)
                }
            }
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isUp ? "More like this" : "Less like this")
        .accessibilityAddTraits(isChosen ? .isSelected : [])
    }

    /// What the card says back — a thank-you for a thumbs up (16:258), a way to
    /// say more for a thumbs down (16:271).
    @ViewBuilder
    private var reply: some View {
        switch feedback {
        case .none:
            EmptyView()
        case .up:
            replyText("Got your response! You’ll see more of these")
                .padding(.horizontal, Space.md)
                .padding(.top, 3)
                .padding(.bottom, 2)
                .transition(.opacity)
        case .down:
            VStack(spacing: Space.sm) {
                replyText("Help us improve your recommendations")
                    .padding(.horizontal, Space.xl)
                GiveFeedbackButton(action: onGiveFeedback)
            }
            .transition(.opacity)
        }
    }

    private func replyText(_ text: String) -> some View {
        Text(text)
            .glanceText(.labelSmall)
            .foregroundStyle(GlanceColor.textPrimary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Highlight

    /// `Look Card highlighted` (16:286): a 1pt rule, outside the card, running
    /// from orchid at the top-left to violet and a flash of white at the
    /// bottom-right corner.
    @ViewBuilder
    private var highlightRule: some View {
        if card.style == .highlighted {
            RoundedRectangle(cornerRadius: Self.cornerRadius + 0.5, style: .continuous)
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: 0xC051D9), location: 0),
                            .init(color: Color(hex: 0x765AEA), location: 0.885),
                            .init(color: .white, location: 1)
                        ],
                        startPoint: UnitPoint(x: 0.05, y: 0),
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .padding(-0.5)
        }
    }
}

/// `Give Feedback ›` (16:271) — the faint pill the thumbs-down reply offers.
private struct GiveFeedbackButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            // 10pt measured off the comp, which fits the pill to its 104×24.
            HStack(spacing: Space.xxs) {
                Text("Give Feedback")
                    .glanceText(.captionMedium)
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .semibold))
            }
            .foregroundStyle(GlanceColor.textPrimary)
            .padding(.horizontal, Space.md)
            .frame(height: 24)
            .background {
                Capsule().fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.005), Color.white.opacity(0.08)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
            .overlay { Capsule().strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5) }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Rational

/// Product shot fading into a solid card colour, with a serif claim.
/// `Product Cards` (321:117) / `Card 14…19` in Figma.
struct RationalCardView: View {
    let card: RationalCard

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                CroppedImage(name: card.image, crop: card.crop)

                CardScrim(tint: card.tint)
            }
            // 170×226 in the comp, which is 3:4 to within a point, so the
            // container keeps tracking the column width.
            .aspectRatio(3.0 / 4.0, contentMode: .fit)

            // `Rational` starts flush against the image — no top padding.
            VStack(alignment: .leading, spacing: Space.sm) {
                if let brand = card.brand {
                    Text(brand, style: .labelBrand)
                        .glanceText(.labelBrand)
                        .foregroundStyle(GlanceColor.textPrimary)
                }

                // Carried back to 60%; the brand above it holds full white.
                Text(card.claim)
                    .glanceText(.bodyL)
                    .foregroundStyle(GlanceColor.textTertiary)

                if let price = card.price {
                    PriceRow(price: price)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Space.lg)
            .padding(.bottom, Space.lg)
        }
        .background(card.tint)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
        .overlay(alignment: .topTrailing) {
            WishlistButton().padding(Space.md)
        }
        .glanceCardShadow()
    }
}

/// The price, what it was, and the saving — one row, with weight and colour
/// doing the ranking rather than size alone (V7, 8:1624).
struct PriceRow: View {
    let price: PriceTag

    var body: some View {
        // One row where it fits; otherwise the saving drops beneath the two
        // prices rather than all three truncating — `$48.00 $72.00 (33% OFF)`
        // is wider than a phone column.
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Space.xxs) {
                prices
                discount
            }
            VStack(alignment: .leading, spacing: Space.xxs) {
                HStack(spacing: Space.xxs) { prices }
                discount
            }
        }
        .lineLimit(1)
    }

    @ViewBuilder
    private var prices: some View {
        Text(price.current)
            .glanceText(.priceNow)
            .foregroundStyle(GlanceColor.textPrimary)
            .fixedSize()

        Text(price.original)
            .glanceText(.priceWas)
            .foregroundStyle(GlanceColor.textTertiary)
            .strikethrough(true, color: GlanceColor.textTertiary)
            .fixedSize()
    }

    @ViewBuilder
    private var discount: some View {
        if let discount = price.discountLabel {
            Text(discount)
                .glanceText(.priceOff)
                // The comp fixes this at #958173, which is white at ~40%
                // over its brown card. Taken as the token it keeps its
                // relationship to whatever tint the card happens to carry —
                // the feed also runs navy, olive and near-black.
                .foregroundStyle(GlanceColor.textDisabled)
                .fixedSize()
        }
    }
}

/// White capsule over the product shot: bold current price, struck-out original.
struct PricePill: View {
    let price: PriceTag

    var body: some View {
        HStack(spacing: 2) {
            Text(price.current)
                .font(.custom(GlanceTypeface.interBold, size: 11))
                .foregroundStyle(.black)
            Text(price.original)
                .font(.custom(GlanceTypeface.interRegular, size: 10))
                .strikethrough()
                .foregroundStyle(.black.opacity(0.4))
        }
        .lineLimit(1)
        .padding(.horizontal, 7)
        .padding(.vertical, 2)
        .background(Capsule().fill(.white))
    }
}

// MARK: - Tip

/// Skin-tip speech bubble. `Bubble` in Figma.
/// `Tips Cards - Change` (V7, 14:240) — a flat block of colour with a kicker, a
/// single headline that carries the whole tip, and a `TELL ME MORE` row.
///
/// It replaced the speech bubble: no tail, no save button, no body copy. The
/// detail the body used to spell out is what `TELL ME MORE` now opens.
struct TipCardView: View {
    let card: TipCard
    var onMore: () -> Void = {}

    /// 20, not the scale's 16 or 24: the revised card (14:240) tightens both
    /// the corners and the rhythm between its three rows.
    private let radius: CGFloat = 20
    private let rowGap: CGFloat = 20

    var body: some View {
        VStack(alignment: .leading, spacing: rowGap) {
            Text(card.tag.category)
                .glanceText(.labelSmall)

            // The face of `headlineS` but none of its 26pt leading. SwiftUI
            // adds one line-spacing value to every line, and the highlight
            // runs a size up, so that target opened the bold lines out to
            // ~28pt. Natural leading sets them at ~24, the comp's own figure
            // for the emphasis, and tightens the plain lines with them.
            headline
                .font(GlanceTextStyle.headlineS.font)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onMore) {
                HStack(spacing: Space.sm) {
                    Text("Tell me more", style: .labelBrand)
                        .glanceText(.labelBrand)
                    Spacer(minLength: Space.sm)
                    // A 7.9×6.8 glyph centred in a 12pt box (8:1660), the two
                    // sized separately so the stroke keeps its proportions.
                    Image("ic-arrow-right")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 7.875, height: 6.75)
                        .frame(width: 12, height: 12)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        // Both labels sit at the card's full ink in the revision; only the
        // un-highlighted part of the headline steps back.
        .foregroundStyle(card.ink)
        .padding(.horizontal, Space.lg)
        .padding(.vertical, Space.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card.tint, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        .glanceCardShadow()
    }

    /// The headline as one `Text`, with the highlighted phrase set heavier,
    /// a size up and at full ink while the sentence around it drops to 70%.
    ///
    /// One attributed string rather than `Text + Text`, which iOS 26
    /// deprecates — and one `Text` wraps as a single paragraph, so the phrase
    /// breaks across lines like any other words.
    private var headline: Text {
        var text = AttributedString(card.headline)

        guard let phrase = card.highlight, let range = text.range(of: phrase) else {
            // Nothing to lean on: the whole line at full strength, rather than
            // a sentence dimmed to 70% for the sake of an emphasis that isn't there.
            return Text(text)
        }

        text.foregroundColor = card.ink.opacity(0.7)
        text[range].font = GlanceTextStyle.headlineEmphasis.font
        text[range].foregroundColor = card.ink
        return Text(text)
    }
}

// MARK: - Prompt

/// Mascot bubble inviting a conversation. `Card` in Figma.
/// `Filler` (V7, 19:753) — the small card that invites a conversation: the
/// mascot and a one-line prompt on Glance's own violet.
struct PromptCardView: View {
    let card: PromptCard
    var action: () -> Void = {}

    /// V7 `secondaryContainer`.
    private static let fill = Color(hex: 0x342C55)
    /// `rgba(96, 50, 255, 0.1)` — a violet edge just lifting it off the feed.
    private static let edge = Color(hex: 0x6032FF, opacity: 0.1)

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)

        Button(action: action) {
            HStack(spacing: Space.sm) {
                mascot

                // The comp sets the arrow inline as the prompt's last word.
                Text(card.text + " →")
                    .glanceText(.labelSmall)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(Space.lg)
            .background(Self.fill, in: shape)
            .overlay { shape.strokeBorder(Self.edge, lineWidth: 1) }
            .contentShape(shape)
        }
        .buttonStyle(.plain)
    }

    /// The exported mascot carries its own glow and a margin around it, so the
    /// comp draws it at 131.88% of its 24pt box, nudged up and left, and lets
    /// the box crop the spare canvas away (2:1011).
    private var mascot: some View {
        Color.clear
            .frame(width: 24, height: 24)
            .overlay(alignment: .topLeading) {
                Image("ic-mascot-filler")
                    .resizable()
                    .frame(width: 24 * 1.3188, height: 24 * 1.3188)
                    .offset(x: -24 * 0.1728, y: -24 * 0.2196)
            }
            .clipped()
    }
}

// MARK: - Brand

/// Brand store card — logo over a campaign image with a folded page corner.
struct BrandCardView: View {
    let card: BrandCard
    var height: CGFloat = 320

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color(hex: 0xF0F0F0)

            // The wordmark and the bottom scrim are part of the artwork now, so
            // there is nothing to composite over it.
            CroppedImage(name: card.image, crop: card.crop)

            VStack(alignment: .leading, spacing: Space.xxxs) {
                if let note = card.note {
                    TrendingTag(text: note)
                        .padding(.bottom, Space.xs)
                }
                Text(card.title)
                    .glanceText(.displayS)
                Text(card.subtitle)
                    .glanceText(.captionRegular)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(GlanceColor.textPrimary)
            .padding(.leading, Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            // `border-l-[1.5px] rgba(255,255,255,0.6)`. As an overlay it takes the
            // text block's height; a sibling `Rectangle` would stretch to the
            // whole card and drag the text to the middle with it.
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 1.5)
            }
            .padding(.trailing, Space.lg)
            .padding(.bottom, Space.xl)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .bottomTrailing) {
            Image("ic-book-page")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        }
        .overlay(alignment: .topTrailing) {
            WishlistButton(tone: .light).padding(Space.md)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
        .glanceFloatingShadow()
    }
}

// MARK: - Trend

/// Full-width editorial news card with try-on tools. `Trend Cards - Dark` in Figma.
/// `Trending News Card` (Surface Art Playground, 27948:7574) — a news moment on
/// a deep maroon panel: the photograph, a blurred gradient bar naming the story,
/// the headline, and the three tools that act on it.
///
/// It replaces the older image-and-headline card. Two departures from that
/// library, which does not share this project's foundations: its Manrope
/// headline is set in Inter Medium, the nearest bundled face, and the panel's
/// own photograph and copy stay Glance's rather than the file's placeholders.
/// `Trending News Card` (V7, 2:821) — a full-bleed photograph, the publisher
/// pill set into its bottom edge, the story, and a row of tools.
struct TrendCardView: View {
    let card: TrendCard
    var onTryLooks: () -> Void = {}
    var onFindOutfits: () -> Void = {}
    var onAsk: () -> Void = {}

    /// The comp crops a 364×511 photo frame to the top 400 of it, so the crop
    /// keeps the head and sheds the hem.
    private static let windowAspect: CGFloat = 364.0 / 400.0
    private static let photoAspect: CGFloat = 364.0 / 511.0
    /// How far the publisher pill rides up over the photograph.
    private static let pillOverlap: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: -Self.pillOverlap) {
            photo

            VStack(alignment: .leading, spacing: Space.md) {
                publisherPill
                    .padding(.horizontal, Space.xl)

                Text(card.headline)
                    .glanceText(.headlineS)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Space.xl)

                tools
            }
        }
        .padding(.bottom, Space.xl)
        .background(card.tint)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }

    private var photo: some View {
        Color.clear
            .aspectRatio(Self.windowAspect, contentMode: .fit)
            .overlay(alignment: .top) {
                // `.fill`, not `.fit`: the frame is taller than the window, and
                // fitting it would shrink its width to match the window's
                // height. Filling keeps it full width; the window then crops
                // the bottom off.
                Color.clear
                    .aspectRatio(Self.photoAspect, contentMode: .fill)
                    .overlay {
                        Image(card.image)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipped()
            }
            .clipped()
    }

    /// Filled with the card's own colour, so it reads as a notch cut out of
    /// the photograph rather than a chip laid over it.
    private var publisherPill: some View {
        HStack(spacing: Space.xs) {
            Image(card.publisherLogo)
                .resizable()
                .scaledToFill()
                .frame(width: 16, height: 16)
                .clipShape(Circle())
            Text(card.publisher)
                .glanceText(.labelMedium)
                .foregroundStyle(GlanceColor.textPrimary.opacity(0.8))
                .lineLimit(1)
        }
        .padding(Space.sm)
        .background(Capsule().fill(card.tint))
        // `drop-shadow(0 4px 4px rgba(0,0,0,0.5))` — SwiftUI's radius is half
        // the CSS blur.
        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 4)
    }

    /// Scrolls past the card's right edge rather than stopping at its padding,
    /// as the comp lets the last pill run off.
    private var tools: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Space.sm) {
                TrendToolChip(title: "Try these looks", action: onTryLooks)
                TrendToolChip(title: "Find similar outfits", action: onFindOutfits)
                TrendToolChip(title: "Ask Glance", action: onAsk)
            }
        }
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, Space.xl, for: .scrollContent)
    }
}

/// A trending card tool (2:830) — sparkle and label on a faint diagonal sheen
/// with a hairline edge.
private struct TrendToolChip: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Space.xs) {
                Image("ic-sparkle")
                    .resizable()
                    .frame(width: 16, height: 16)
                Text(title)
                    .glanceText(.labelMedium)
                    .lineLimit(1)
            }
            .foregroundStyle(GlanceColor.textPrimary)
            .padding(.horizontal, 8.25)
            .frame(height: 32)
            .background {
                Capsule().fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 1, green: 231 / 255, blue: 231 / 255, opacity: 0.005), location: 0.049),
                            .init(color: Color.white.opacity(0.08), location: 0.984)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
            .overlay { Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5) }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Routine

/// Full-width routine card with line-art illustration and three numbered steps.
struct RoutineCardView: View {
    let card: RoutineCard

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(card.kicker)
                .glanceText(.bodyS)
                .foregroundStyle(GlanceColor.textTertiary)

            Spacer(minLength: 96)

            VStack(alignment: .leading, spacing: Space.lg) {
                HStack(spacing: Space.sm) {
                    Text(card.tag.category, style: .labelSection)
                        .glanceText(.labelSection)
                    HStack(spacing: Space.xxs) {
                        Circle().fill(GlanceColor.textMuted).frame(width: 2, height: 2)
                        Text(card.tag.match, style: .labelOverline)
                            .glanceText(.labelOverline)
                    }
                }
                .foregroundStyle(GlanceColor.textMuted)

                Text(card.headline)
                    .glanceText(.displayL)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.trailing, 68)

                Text(card.subhead)
                    .glanceText(.displaySItalic)
                    .foregroundStyle(card.subheadInk)

                Rectangle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 64, height: 1)
            }

            Spacer(minLength: Space.xl)

            HStack(alignment: .top, spacing: Space.sm) {
                ForEach(Array(card.steps.enumerated()), id: \.element.id) { index, step in
                    VStack(alignment: .leading, spacing: Space.md) {
                        Text("\(index + 1).")
                            .glanceText(.displayFeature)
                            .foregroundStyle(GlanceColor.textPrimary)
                        VStack(alignment: .leading, spacing: Space.xxs) {
                            Text(step.title)
                                .glanceText(.headingM)
                                .foregroundStyle(GlanceColor.textPrimary)
                            Text(step.detail)
                                .glanceText(.captionRegular)
                                .foregroundStyle(GlanceColor.textTertiary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.horizontal, Space.xxl)
        .padding(.top, Space.xxl)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(card.background)
                .overlay {
                    // `shadow(inset 0 0 34 rgba(255,255,255,.64))` — a soft rim of light,
                    // not a border: keep the stroke wide and heavily blurred.
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(card.glow.opacity(0.55), lineWidth: 26)
                        .blur(radius: 26)
                }
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        }
        .overlay(alignment: .topTrailing) {
            Image(card.illustration)
                .resizable()
                .scaledToFit()
                .frame(width: card.illustrationSize.width, height: card.illustrationSize.height)
                .padding(.top, card.illustrationInset.height)
                .offset(x: card.illustrationInset.width)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        // Over the illustration, as the comp has it.
        .overlay(alignment: .topTrailing) {
            WishlistButton(isOn: true, tone: .light).padding(Space.lg)
        }
    }
}

// MARK: - Look card variants

/// Every variant of the V7 `Look Card` set (16:240), side by side — the three
/// authored styles, then a feedback card already answered each way.
struct LookCardGallery: View {
    private let card = LookCard(
        image: "look-brunch",
        tag: MatchTag(category: "Fashion"),
        title: "Chocolate knit and barrel jeans for a slow Sunday brunch"
    )

    private let variants: [(String, LookCardStyle, LookCardView.Feedback)] = [
        ("w/o feedback", .plain, .none),
        ("w feedback", .feedback, .none),
        ("highlighted", .highlighted, .none),
        ("thumbs up", .feedback, .up),
        ("thumbs down", .feedback, .down)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 165), spacing: Space.xl, alignment: .top)], spacing: Space.xl) {
                ForEach(variants, id: \.0) { name, style, feedback in
                    VStack(alignment: .leading, spacing: Space.sm) {
                        Text(name, style: .labelSection)
                            .glanceText(.labelSection)
                            .foregroundStyle(GlanceColor.textMuted)
                        LookCardView(card: { var c = card; c.style = style; return c }(), feedback: feedback)
                    }
                }
            }
            .padding(Space.xl)
        }
        .background(GlanceColor.bgBase)
    }
}

#Preview("Look Card variants") {
    LookCardGallery()
        .preferredColorScheme(.dark)
}

// MARK: - Poster

/// A poster whose headline is set into the artwork, at a column's width. The
/// image is drawn whole at its own proportion — 3:4 or 9:16 — because
/// cropping it would cut into the type. Tapping it asks Glance the question
/// it poses.
struct PosterCardView: View {
    let card: PosterCard
    var action: () -> Void = {}

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)

        Button(action: action) {
            Image(card.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(shape)
                .contentShape(shape)
        }
        .buttonStyle(FeedCardButtonStyle())
        .glanceCardShadow()
        .accessibilityLabel(card.prompt)
        .accessibilityHint("Asks Glance")
    }
}
