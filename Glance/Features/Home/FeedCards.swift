import SwiftUI

// MARK: - Look

/// Photo card with the shade-match footer. `Look` in Figma.
struct LookCardView: View {
    let card: LookCard
    var height: CGFloat = 320

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color(hex: 0xF0F0F0)

            CroppedImage(name: card.image, crop: card.crop)

            ImageScrim(height: 90)
                .frame(maxHeight: .infinity, alignment: .bottom)

            VStack(alignment: .leading, spacing: Space.xxs) {
                MatchTagView(
                    tag: card.tag,
                    ink: GlanceColor.textSecondary,
                    showsIcon: true,
                    prefix: card.likes
                )
                Text(card.title)
                    .glanceText(.headingS)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let action = card.action {
                    GlanceChip(title: action, systemIcon: "sparkles", tone: .scrim)
                        .padding(.top, Space.xs)
                }
            }
            .padding(Space.lg)
        }
        // An action chip adds a row under the title, so the card grows to hold
        // it rather than clipping it against the bottom edge.
        .frame(height: card.action == nil ? height : height + 48)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
        .overlay(alignment: .topTrailing) {
            WishlistButton().padding(Space.md)
        }
        .glanceFloatingShadow()
    }
}

// MARK: - Rational

/// Product shot fading into a solid card colour, with a serif claim.
/// `Product Cards` (321:117) / `Card 14…19` in Figma.
struct RationalCardView: View {
    let card: RationalCard

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                CroppedImage(name: card.image, crop: card.crop)

                CardScrim(tint: card.tint)

                VStack(alignment: .leading, spacing: Space.xs) {
                    if let price = card.price {
                        PricePill(price: price)
                    }
                    if let note = card.note {
                        TrendingTag(text: note)
                    }
                }
                .padding(.leading, Space.lg)
                .padding(.bottom, Space.sm)
            }
            // The image container is a strict 3:4, so it tracks the column width.
            .aspectRatio(3.0 / 4.0, contentMode: .fit)

            // `Rational` starts flush against the image — no top padding.
            VStack(alignment: .leading, spacing: Space.sm) {
                Text(card.claim)
                    .glanceText(.displayM)
                Text(card.reason)
                    .glanceText(.bodyS)
            }
            .foregroundStyle(GlanceColor.textPrimary)
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
struct TipCardView: View {
    let card: TipCard
    private let tailHeight: CGFloat = 16

    /// `Heading/XL` on this card is **20**, not the scale's 24 (27641:10010).
    /// At 24 the headline crowds the card and pushes the body off the bottom.
    private static let headline = GlanceTextStyle(GlanceTypeface.interExtraBold, 20, lineHeight: 22)

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            // The tag and the heart share one row, spread apart — the heart is
            // not a corner overlay here.
            HStack(spacing: Space.sm) {
                Text(card.tag.category, style: .labelOverline)
                    .glanceText(.labelOverline)
                Spacer(minLength: Space.sm)
                WishlistButton(isOn: true, tone: .glass)
            }

            VStack(alignment: .leading, spacing: Space.md) {
                Text(card.headline)
                    .glanceText(Self.headline)
                Text(card.body)
                    .glanceText(.bodySMedium)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(card.ink)
        .padding(.horizontal, Space.lg)
        .padding(.top, Space.lg)
        .padding(.bottom, Space.xl)
        // The card takes its height from the tip, so the 24pt under the last
        // line is always 24. Pinned to the comp's 302 instead, a long tip
        // pushes that padding outside the bubble and a short one leaves a well
        // of dead space above the tail.
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, tailHeight)
        .background(BubbleShape(tailHeight: tailHeight).fill(card.tint))
        .glanceFloatingShadow()
    }
}

// MARK: - Prompt

/// Mascot bubble inviting a conversation. `Card` in Figma.
struct PromptCardView: View {
    let card: PromptCard
    var action: () -> Void = {}
    private let tailHeight: CGFloat = 12.6

    var body: some View {
        Button(action: action) {
            Text(card.text)
                .glanceText(.headingS)
                .foregroundStyle(Color(hex: 0x444444))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .padding(.bottom, tailHeight)
                .background(BubbleShape(tailHeight: tailHeight, tailWidth: 30, tailInset: 18).fill(Color(hex: 0xDED6FF)))
                .overlay(alignment: .topTrailing) {
                    // 36pt mascot at (right: 3, top: 35) — it overhangs the bubble.
                    Image("ic-mascot-chat")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .offset(x: -3, y: 35)
                }
                .glanceCardShadow()
        }
        .buttonStyle(.plain)
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
            WishlistButton().padding(Space.md)
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
struct TrendCardView: View {
    let card: TrendCard
    var onTryLooks: () -> Void = {}
    var onFindOutfits: () -> Void = {}
    var onAsk: () -> Void = {}

    /// The comp's own frame: a 322pt image in a 364pt card.
    private static let imageAspect: CGFloat = 364.0 / 322.0
    private static let headline = GlanceTextStyle(GlanceTypeface.interMedium, 18, lineHeight: 18 * 1.35)
    private static let source = GlanceTextStyle(GlanceTypeface.interSemiBold, 12, tracking: 0.24)

    var body: some View {
        VStack(spacing: Space.lg) {
            Color.clear
                .aspectRatio(Self.imageAspect, contentMode: .fit)
                .overlay {
                    Image(card.image)
                        .resizable()
                        .scaledToFill()
                }
                .clipped()

            VStack(alignment: .leading, spacing: Space.sm) {
                sourceBar
                Text(card.headline)
                    .glanceText(Self.headline)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)

            // Three tools at the comp's widths total 330 of its 333pt row, so
            // they fit — the scroll view is only insurance against longer copy.
            ScrollView(.horizontal) {
                HStack(spacing: Space.xs) {
                    GlanceIconChip(
                        icon: "ic-tag",
                        iconSize: CGSize(width: 14.57, height: 12),
                        tone: .plain,
                        action: onAsk
                    )
                    GlanceChip(title: "Try these looks", icon: "ic-tryon", tone: .plain, action: onTryLooks)
                    GlanceChip(title: "Find similar outfits", icon: "ic-visual-search", tone: .plain, action: onFindOutfits)
                }
                .fixedSize()
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Space.lg)
        }
        .padding(.bottom, Space.xl)
        .background(card.tint)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(alignment: .topTrailing) {
            WishlistButton(isOn: true).padding(Space.lg)
        }
        .glanceFloatingShadow()
    }

    /// The story line is the same `TrendingTag` the artwork pills use — one tag,
    /// one treatment, wherever a live read is marked (28119:1632).
    private var sourceBar: some View {
        TrendingTag(text: card.badge)
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
            WishlistButton(isOn: true).padding(Space.lg)
        }
    }
}
