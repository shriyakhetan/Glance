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

    /// The photograph's own proportion. One for both sizes: the column card
    /// is 170×302 in the comp (16:242), the big card's shot 364×647 (29:883)
    /// — the same shape, scaled.
    private let photoAspect: CGFloat = 170.0 / 302.0

    /// The big card (29:881) sets its caption a size up, on a deeper scrim,
    /// with its heart set further in.
    private var isBig: Bool { card.isFullWidth }
    /// The big card asking for a read rests its photo in a 364×576 window
    /// over its footer, shedding the foot of the shot. Every other card shows
    /// the whole photograph.
    private var hasFooter: Bool { isBig && card.style.asksForFeedback }
    /// The window's height in the comp's points, for the big card's scrim.
    private var bigWindowHeight: CGFloat { hasFooter ? 576 : 647 }
    private var windowAspect: CGFloat { hasFooter ? 364 / bigWindowHeight : photoAspect }
    /// The thumbs row. The column card's: two 32pt targets with 6pt above and
    /// below. The big card's footer (29:888): its question beside the thumbs,
    /// 16pt above and below.
    private var feedbackRowHeight: CGFloat { isBig ? 64 : 44 }
    /// 24, smoothed, like every card in the app — the big card's comp asks
    /// for 32.
    private let cornerRadius: CGFloat = Radius.xl

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
            .background(surfaceFill)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay { highlightRule }
            .overlay(alignment: .topTrailing) {
                WishlistButton(tone: .scrim).padding(isBig ? Space.lg : Space.md)
            }
            .animation(.spring(response: 0.38, dampingFraction: 0.86), value: feedback)
            .sensoryFeedback(.selection, trigger: feedback)
    }

    /// What shows past the photograph. The big card's footer is the scrim's
    /// own tone, so the photo settles straight into it (29:881 uses `#41413E`
    /// for both); the column card's panel is a step darker (16:242).
    private var surfaceFill: Color {
        guard card.style.asksForFeedback else { return Self.plainFill }
        return isBig ? shade : panel
    }

    // MARK: - Layout

    /// Fixes the card's height — the photograph at rest, plus the thumbs row
    /// when there is one — so nothing that happens inside can change it.
    private var sizing: some View {
        VStack(spacing: 0) {
            Color.clear.aspectRatio(windowAspect, contentMode: .fit)
            if card.style.asksForFeedback {
                Color.clear.frame(height: feedbackRowHeight)
            }
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            // Takes whatever height the rows below leave it.
            photo
                .frame(maxHeight: .infinity)

            if hasFooter {
                footer
            } else if card.style.asksForFeedback {
                feedbackRow
                reply
            }
        }
        .padding(.bottom, !isBig && feedback != .none ? Space.md : 0)
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
            // the card's own (16:242, 29:882).
            .clipShape(UnevenRoundedRectangle(bottomTrailingRadius: cornerRadius, style: .continuous))
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
            // `Body/Large`, 16pt.
            Text(card.title)
                .glanceText(.bodyLarge)
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

    /// The big card's scrim (29:884) is a fixed band rather than one sized to
    /// its caption: the bottom 260pt of the photo's window, fading in from
    /// 14.7% of the way down that band. Written as stops over the whole
    /// window, so it keeps that proportion at any width without measuring.
    private var bigScrim: some View {
        let band = 260.0 / bigWindowHeight
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

    /// The big card's footer (29:888): the question, then the thumbs. A thumbs
    /// up answers it — `You’ll see more of these` (29:914). A thumbs down
    /// leaves the question standing, as the comp has it (29:901).
    private var footer: some View {
        HStack(spacing: Space.xxl) {
            Text(feedback == .up ? "You’ll see more of these" : "Do you like this look?")
                .glanceText(.labelMedium)
                .foregroundStyle(GlanceColor.textPrimary)
                .contentTransition(.opacity)
                .frame(maxWidth: .infinity, alignment: .leading)
            thumb(.up)
            thumb(.down)
        }
        .padding(.horizontal, Space.xl)
        .padding(.vertical, Space.lg)
    }

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
            RoundedRectangle(cornerRadius: cornerRadius + 0.5, style: .continuous)
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
                // One colour for the saving on every product card, whatever
                // the card's own tint.
                .foregroundStyle(GlanceColor.discount)
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
                .font(.custom(GlanceTypeface.manropeBold, size: 11))
                .foregroundStyle(.black)
            Text(price.original)
                .font(.custom(GlanceTypeface.manropeRegular, size: 10))
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

/// `Tip Card` (2825:810) — one piece of advice on its category's colour: a
/// kicker, the tip with the phrase it leans on set in bold, and a button named
/// for where the tip leads — `Tell Me More`, `Show Products`, `Find
/// Sunscreens`. The four categories each come in five shades (`TipCategory`).
///
/// The comp's button is a 24pt pill with a 9pt label. It is the secondary
/// Liquid Glass button here, at iOS's own measure — 32pt, a 12pt label — as on
/// the filler card.
struct TipCardView: View {
    let card: TipCard
    var onAction: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            Text(card.tag.category)
                .glanceText(.labelSmall)
                .foregroundStyle(Color.white.opacity(0.7))

            // 20pt throughout, the bold phrase included, so every line sits
            // at the same 24pt.
            headline
                .glanceText(.headlineM)
                .foregroundStyle(GlanceColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            SecondaryButton(title: card.action.title, padding: Space.md, showsArrow: true, action: onAction)
        }
        .padding(.horizontal, Space.lg)
        .padding(.vertical, Space.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            card.category.fill(shade: card.shade),
            in: RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
        )
    }

    /// The headline as one `Text`, with the highlighted phrase set in
    /// ExtraBold at the sentence's own size. The component keeps the whole
    /// sentence white, so only the weight carries the emphasis.
    ///
    /// One attributed string rather than `Text + Text`, which iOS 26
    /// deprecates — and one `Text` wraps as a single paragraph, so the phrase
    /// breaks across lines like any other words.
    private var headline: Text {
        var text = AttributedString(card.headline)
        if let phrase = card.highlight, let range = text.range(of: phrase) {
            text[range].font = GlanceTextStyle.headlineEmphasis.font
        }
        return Text(text)
    }
}

/// Every palette of the `Tip Card` set (2825:810): four categories, five
/// shades each.
struct TipCardGallery: View {
    private let categories: [(String, TipCategory)] = [
        ("Beauty", .beauty), ("Fashion", .fashion), ("Gadget", .gadget), ("Health", .health)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                ForEach(categories, id: \.0) { name, category in
                    VStack(alignment: .leading, spacing: Space.sm) {
                        Text(name, style: .labelSection)
                            .glanceText(.labelSection)
                            .foregroundStyle(GlanceColor.textMuted)
                        ScrollView(.horizontal) {
                            HStack(alignment: .top, spacing: Space.md) {
                                ForEach(1...5, id: \.self) { shade in
                                    TipCardView(card: TipCard(
                                        category: category,
                                        shade: shade,
                                        tag: MatchTag(category: "\(name) Tip"),
                                        headline: "Bangalore's hard water dries skin out. A hydrating cleanser fixes that.",
                                        highlight: "hard water dries skin out",
                                        body: ""
                                    ))
                                    .frame(width: 170)
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                }
            }
            .padding(Space.xl)
        }
        .background(GlanceColor.bgBase)
    }
}

#Preview("Tip card palettes") {
    TipCardGallery()
        .preferredColorScheme(.dark)
}

// MARK: - Prompt

/// The filler card (`Card`, 2831:1018) — Glance offering to talk. A near-black
/// card lit faintly from its top-left corner, with a large sparkle
/// watermarked into the other end, in one of three states:
///
/// - `compact` (`Start Chat`, 2831:1019): the mascot beside one line.
/// - `stacked` (`Start Chat 2`, 3138:1867): the mascot over a longer line.
/// - `resume` (`Continue Chat`, 2831:1017): picks an earlier thread back up.
///
/// The two that start a chat are one big button. `Continue Chat` has its own,
/// a secondary Liquid Glass pill at iOS's own measure — 32pt, a 12pt label —
/// where the comp's 24pt pill set its label at 9pt.
struct PromptCardView: View {
    let card: PromptCard
    var action: () -> Void = {}

    private static let fill = Color(hex: 0x050505)
    private static let shape = RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)

    /// The edge's ramp: `#9375FE` at 10% at either end, white at 90% midway.
    /// Figma blends between stops without premultiplying, which keeps the
    /// flanks violet; SwiftUI premultiplies, which greys and brightens them.
    /// Stops every eighth of the way, each mixed Figma's way, close the gap.
    private static let edgeStops: [Gradient.Stop] = (0...8).map { step in
        let location = Double(step) / 8
        let mix = 1 - abs(location - 0.5) * 2
        return Gradient.Stop(
            color: Color(
                red: (147 + 108 * mix) / 255,
                green: (117 + 138 * mix) / 255,
                blue: (254 + mix) / 255,
                opacity: 0.1 + 0.8 * mix
            ),
            location: location
        )
    }

    var body: some View {
        switch card.style {
        case .compact, .stacked:
            Button(action: action) { surfaced }
                .buttonStyle(FeedCardButtonStyle())
        case .resume:
            surfaced
        }
    }

    private var surfaced: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { surface }
            .clipShape(Self.shape)
            .overlay { edge }
            .contentShape(Self.shape)
    }

    @ViewBuilder
    private var content: some View {
        switch card.style {
        case .compact:
            // A single 24pt line, centred in the comp's 58pt card.
            HStack(alignment: .top, spacing: Space.md) {
                mascot
                line
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 17)
        case .stacked:
            VStack(alignment: .leading, spacing: Space.md) {
                mascot
                line
            }
            .padding(20)
        case .resume:
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: Space.md) {
                    mascot
                    line
                }
                SecondaryButton(title: "Continue Chat", padding: Space.md, showsArrow: true, action: action)
            }
            .padding(20)
        }
    }

    /// V7 `Title/Medium`.
    private var line: some View {
        Text(card.text)
            .glanceText(.titleMedium)
            .foregroundStyle(GlanceColor.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// The comp lays a copy under the mascot, blurred 12pt, for its glow.
    private var mascot: some View {
        FillerMascot(side: 24)
            .background { FillerMascot(side: 24).blur(radius: 12) }
    }

    private var surface: some View {
        Self.fill
            .overlay { cornerLight }
            .overlay(alignment: .bottomTrailing) {
                Image("ic-filler-sparkle")
                    .resizable()
                    .frame(width: 114, height: 114)
                    .opacity(0.07)
                    .offset(sparkleOverhang)
            }
            .allowsHitTesting(false)
    }

    /// The card's 1pt edge: violet at 10%, flaring to white at 90% along a
    /// band that crosses the top at 44% of the width and the bottom at 65% —
    /// the comp's gradient stroke, read off its pixels, since the exported
    /// code flattens it to the violet alone.
    ///
    /// Figma lays a gradient out in the card's unit square and stretches it
    /// over the card, so the band shears with each state's height. Drawing it
    /// in a square and scaling that to the card does the same; a plain
    /// `LinearGradient` would keep its bands square to the points instead.
    private var edge: some View {
        GeometryReader { geometry in
            LinearGradient(
                stops: Self.edgeStops,
                startPoint: UnitPoint(x: 0.018, y: 0.609),
                endPoint: UnitPoint(x: 1.074, y: 0.391)
            )
            .frame(width: 100, height: 100)
            .scaleEffect(x: geometry.size.width / 100, y: geometry.size.height / 100, anchor: .topLeading)
        }
        .mask { Self.shape.strokeBorder(lineWidth: 1) }
        .allowsHitTesting(false)
    }

    /// `Ellipse 2465528` — a 159×29 bar of `#7F9BBD`, blurred by 50 and
    /// centred just past the top-left corner.
    ///
    /// Drawn as the light that blur leaves behind rather than as a live blur:
    /// a bar that thin under a σ50 Gaussian is an elliptical Gaussian itself,
    /// σ64 across and σ50.5 down, peaking near 19%, which tracks the comp
    /// within a few levels from the corner out to where it fades. SwiftUI's
    /// `blur(radius: 50)` spread it far thinner, to barely a glimmer, and a
    /// gradient costs nothing to scroll.
    private var cornerLight: some View {
        let sigma: CGFloat = 50.5
        let reach = sigma * 3
        let peak = 0.19
        let tone = Color(hex: 0x7F9BBD)
        // exp(−r²/2σ²) at every half σ out to 3σ.
        let falloff: [Double] = [1, 0.8825, 0.6065, 0.3247, 0.1353, 0.0439, 0]

        return Circle()
            .fill(
                RadialGradient(
                    stops: falloff.enumerated().map { index, level in
                        .init(color: tone.opacity(peak * level), location: Double(index) / Double(falloff.count - 1))
                    },
                    center: .center,
                    startRadius: 0,
                    endRadius: reach
                )
            )
            .frame(width: reach * 2, height: reach * 2)
            .scaleEffect(x: 64 / sigma, y: 1)
            .position(x: 12.5, y: -15.5)
    }

    /// How far each state's sparkle runs past the card's bottom-trailing
    /// corner, from the comp's own placements.
    private var sparkleOverhang: CGSize {
        switch card.style {
        case .compact: CGSize(width: 21, height: 15)
        case .stacked: CGSize(width: 25, height: 20)
        case .resume: CGSize(width: 23, height: 14)
        }
    }
}

/// All three states of the filler `Card` set (2831:1018), at a column's width.
struct PromptCardGallery: View {
    private let topic = ChatTopic(source: "Glance AI", opening: "What's on your mind?")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                variant("continue chat", PromptCard(style: .resume, text: "Did you get the perfect dress for your date? I have a few ideas for you", chat: topic))
                variant("start chat", PromptCard(style: .compact, text: "Start a chat?", chat: topic))
                variant("start chat 2", PromptCard(style: .stacked, text: "Want to chat about something?", chat: topic))
            }
            .frame(width: 185)
            .padding(Space.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(GlanceColor.bgBase)
    }

    private func variant(_ name: String, _ card: PromptCard) -> some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            Text(name, style: .labelSection)
                .glanceText(.labelSection)
                .foregroundStyle(GlanceColor.textMuted)
            PromptCardView(card: card)
        }
    }
}

#Preview("Filler card states") {
    PromptCardGallery()
        .preferredColorScheme(.dark)
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
/// It replaces the older image-and-headline card. One departure from that
/// library, which does not share this project's foundations: the panel's own
/// photograph and copy stay Glance's rather than the file's placeholders.
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
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
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
            RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                .fill(card.background)
                .overlay {
                    // `shadow(inset 0 0 34 rgba(255,255,255,.64))` — a soft rim of light,
                    // not a border: keep the stroke wide and heavily blurred.
                    RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                        .strokeBorder(card.glow.opacity(0.55), lineWidth: 26)
                        .blur(radius: 26)
                }
                .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
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
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
        // Over the illustration, as the comp has it.
        .overlay(alignment: .topTrailing) {
            WishlistButton(isOn: true, tone: .light).padding(Space.lg)
        }
    }
}

// MARK: - Look card variants

/// Every variant of the V7 `Look Card` set (16:240), side by side — the three
/// authored styles, then a feedback card already answered each way — and
/// below them `Look Card Big` (29:881) in each of its three states.
struct LookCardGallery: View {
    private let card = LookCard(
        image: "look-brunch",
        tag: MatchTag(category: "Fashion"),
        title: "Chocolate knit and barrel jeans for a slow Sunday brunch"
    )
    private let bigCard = LookCard(
        image: "look-airport",
        tag: MatchTag(category: "Travel", match: "93% MATCH"),
        title: "Cream knit and wide-leg trousers: an easy airport look for your next trip",
        style: .feedback,
        isFullWidth: true
    )
    private let bigVariants: [(String, LookCardView.Feedback)] = [
        ("big", .none),
        ("big · thumbs up", .up),
        ("big · thumbs down", .down)
    ]

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

            VStack(alignment: .leading, spacing: Space.xl) {
                ForEach(bigVariants, id: \.0) { name, feedback in
                    VStack(alignment: .leading, spacing: Space.sm) {
                        Text(name, style: .labelSection)
                            .glanceText(.labelSection)
                            .foregroundStyle(GlanceColor.textMuted)
                        LookCardView(card: bigCard, feedback: feedback)
                    }
                    .id(name)
                }
            }
            .padding(.horizontal, GlanceLayout.feedGutter)
            .padding(.bottom, Space.xl)
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
