import SwiftUI

/// The L2 comp (V7, 32:2523) sets every section 24pt in from the screen edge.
private let gutter = Space.xl

// MARK: - Shared

/// A comp's heavily blurred disc of light, as the radial falloff it renders
/// to — far cheaper than a live blur on a page that scrolls.
private struct SoftGlow: View {
    var color: Color
    /// Opacity at the centre.
    var peak: Double
    /// Radius at which it has faded out.
    var reach: CGFloat

    var body: some View {
        RadialGradient(
            stops: [
                .init(color: color.opacity(peak), location: 0),
                .init(color: color.opacity(peak * 0.45), location: 0.45),
                .init(color: color.opacity(0), location: 1)
            ],
            center: .center,
            startRadius: 0,
            endRadius: reach
        )
        .frame(width: reach * 2, height: reach * 2)
        .allowsHitTesting(false)
    }
}

private extension View {
    /// The card the L2 sections sit on: white at 8%.
    func l2Card(radius: CGFloat = Radius.xl) -> some View {
        background(GlanceColor.bgOverlay, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    /// Places `glow` so its centre lands at `center`, in the comp's points from
    /// the view's top-leading corner.
    func glow(_ glow: SoftGlow, centeredAt center: CGPoint) -> some View {
        overlay(alignment: .topLeading) {
            glow.offset(x: center.x - glow.reach, y: center.y - glow.reach)
        }
    }
}

// MARK: - Product

/// `Product Detail Section` (32:2525): the photographs, what it is and what it
/// costs, the two ways to act on it, and who else bought it.
struct ProductHeroSection: View {
    let product: Product
    @Binding var isWishlisted: Bool
    var onBuy: () -> Void
    var onStyleMe: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            gallery
            Group {
                info
                purchase
                socialProof
            }
            .padding(.horizontal, gutter)
        }
    }

    /// `Image Carousal` — the frames run off the trailing edge, so the next one
    /// shows there's more to swipe to.
    private var gallery: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15.57) {
                ForEach(product.images, id: \.self) { name in
                    Image(name)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 224.03, height: 298.7)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
                        .accessibilityHidden(true)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, gutter, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .frame(height: 298.7)
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            HStack(spacing: Space.md) {
                Text(product.brand)
                    .glanceText(.displaySmall)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: Space.sm) {
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.6)) { isWishlisted.toggle() }
                    } label: {
                        actionGlyph(isWishlisted ? "heart.fill" : "heart", ink: isWishlisted ? Color(hex: 0xFF3B30) : GlanceColor.textPrimary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isWishlisted ? "Remove from wishlist" : "Save to wishlist")

                    ShareLink(item: "\(product.brand) \(product.name)") {
                        actionGlyph("square.and.arrow.up")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Share")
                }
            }

            Text(product.name)
                .glanceText(.bodyMedium)
                .foregroundStyle(GlanceColor.textSecondary)

            HStack(spacing: 0) {
                Image("ic-rating-star")
                    .resizable()
                    .frame(width: 15.41, height: 15.41)
                HStack(spacing: 4.1) {
                    Text(product.rating)
                        .glanceText(.labelLarge)
                        .foregroundStyle(GlanceColor.textPrimary)
                    Text(product.ratingCount)
                        .glanceText(.bodyCaption)
                        .foregroundStyle(GlanceColor.textSecondary)
                }
            }
            .accessibilityElement(children: .combine)

            HStack(spacing: 6.28) {
                Text(product.price)
                    .glanceText(.titleMedium)
                    .foregroundStyle(GlanceColor.textPrimary)
                Text(product.originalPrice)
                    .glanceText(.labelLarge)
                    .strikethrough()
                    .foregroundStyle(GlanceColor.textPrimary.opacity(0.4))
                Text(product.discount)
                    .glanceText(.labelSmall)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .padding(.horizontal, Space.md)
                    .frame(height: 23.04)
                    .background(GlanceColor.bgOverlay, in: Capsule())
            }
        }
    }

    /// The `Actions` beside the brand (32:2535) — 32pt secondary buttons. Their
    /// glyphs are the system's own heart and share, as an iOS product page has them.
    private func actionGlyph(_ systemName: String, ink: Color = GlanceColor.textPrimary) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(ink)
            .frame(width: 32, height: 32)
            .secondaryGlass(in: Circle())
            .contentShape(Circle())
    }

    /// `Purchase Buttons` (32:2552). Buying is the page's one primary action, so
    /// it stays the comp's solid white; `Style me` is a secondary, so glass.
    private var purchase: some View {
        HStack(spacing: Space.md) {
            Button(action: onBuy) {
                HStack(spacing: Space.sm) {
                    Text("Buy on")
                        .glanceText(.labelLarge)
                        .foregroundStyle(Color.black)
                        .fixedSize()
                    Image("logo-amazon")
                        .resizable()
                        .frame(width: 48, height: 24)
                }
                .padding(.horizontal, Space.xl)
                .frame(height: 48)
                .background(Color.white, in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Buy on Amazon")

            SecondaryButton(
                title: "Style me",
                icon: "ic-style-me",
                iconSize: 18,
                style: .labelLarge,
                height: 48,
                padding: Space.xl,
                hairline: GlanceColor.hairline,
                action: onStyleMe
            )
        }
    }

    /// `Social Proof` (32:2561).
    private var socialProof: some View {
        HStack(spacing: Space.lg) {
            HStack(spacing: -8.2) {
                ForEach(product.socialProof.buyers, id: \.self) { buyer in
                    Image(buyer)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24.6, height: 24.6)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(Color.black, lineWidth: 1.03))
                }
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Space.xxs) {
                Text(product.socialProof.headline)
                    .foregroundStyle(GlanceColor.textPrimary)
                Text(product.socialProof.detail)
                    .foregroundStyle(GlanceColor.textSecondary)
            }
            .glanceText(.bodyCaption)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, Space.xl)
        .padding(.vertical, Space.lg)
        .background(GlanceColor.bgOverlay, in: RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
    }
}

// MARK: - Why it works

/// `Why it Works Section` (32:2572): how strong a match it is, what agrees with
/// her taste and what doesn't, and a check that the read was right.
struct ProductMatchSection: View {
    let match: ProductMatch
    var onAnswer: (String) -> Void = { _ in }

    @State private var answer: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            SectionTitle(title: "Why it works for you?")

            VStack(spacing: Space.lg) {
                header
                PointsBox(title: "What matches", tint: GlanceColor.positive, points: match.matches, wraps: false)
                PointsBox(title: "What doesn’t match", tint: GlanceColor.negative, points: match.mismatches, wraps: true)
                feedback
                    .padding(.top, Space.sm)
            }
            .padding(Space.xl)
            .l2Card()
        }
        .padding(.horizontal, gutter)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: answer)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 11) {
                Image("ic-match-spark")
                    .resizable()
                    .frame(width: 16, height: 15.97)
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(Text("A ").font(.custom(GlanceTypeface.manropeRegular, size: 18)))\(Text(match.verdict).font(.custom(GlanceTypeface.manropeBold, size: 20)))")
                        .frame(height: 26)
                    Text("for you")
                        .font(.custom(GlanceTypeface.manropeRegular, size: 18))
                        .frame(height: 26)
                }
                .foregroundStyle(GlanceColor.textPrimary)
            }
            Spacer(minLength: Space.md)
            MatchGauge(score: match.score)
        }
        .accessibilityElement(children: .combine)
    }

    private var feedback: some View {
        VStack(spacing: Space.lg) {
            Text(answer == nil ? match.question : "Thanks — that sharpens every match from here.")
                .glanceText(.bodyCaption)
                .foregroundStyle(GlanceColor.textPrimary)
                .multilineTextAlignment(.center)
                .contentTransition(.opacity)
            if answer == nil {
                HStack(spacing: Space.sm) {
                    ForEach(match.answers, id: \.self) { option in
                        SecondaryButton(title: option, minWidth: 100) {
                            answer = option
                            onAnswer(option)
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// `matches-box` / `mismatch-box` (32:2590, 32:2619).
private struct PointsBox: View {
    let title: String
    let tint: Color
    let points: [MatchPoint]
    /// The matches hold to a line each; what doesn't match runs longer and wraps.
    let wraps: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            Text(title)
                .glanceText(.labelMedium)
                .foregroundStyle(tint)
            ForEach(points) { point in
                HStack(alignment: wraps ? .top : .center, spacing: Space.md) {
                    MatchGlyph(icon: point.icon)
                    Text("\(Text(point.lead).foregroundStyle(GlanceColor.textPrimary)) \(Text(point.rest).foregroundStyle(GlanceColor.textSecondary))")
                        .glanceText(.bodyCaption)
                        .lineLimit(wraps ? nil : 1)
                        .fixedSize(horizontal: false, vertical: wraps)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GlanceColor.surfaceBright, in: RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
    }
}

/// The 16pt glyphs the match rows lead with (32:2596 …), dimmed to 60% as the
/// comp dims them — all but the price tag, which carries its own 70%.
private struct MatchGlyph: View {
    let icon: MatchIcon

    var body: some View {
        glyph
            .frame(width: 16, height: 16)
            .opacity(icon == .price ? 1 : 0.6)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var glyph: some View {
        switch icon {
        case .fit:
            // The comp mirrors the tape measure.
            Image("ic-match-fit")
                .resizable()
                .frame(width: 14.33, height: 10.33)
                .scaleEffect(x: -1)
        case .neckline:
            ZStack {
                Image("ic-match-neck")
                    .resizable()
                    .frame(width: 13.67, height: 13.67)
                // `shirt-01` shows only its collar, through a 12 × 8 window.
                Image("ic-match-neck-shirt")
                    .resizable()
                    .frame(width: 21, height: 19)
                    .offset(x: -4.5, y: 2.5)
                    .frame(width: 12, height: 8, alignment: .topLeading)
                    .clipped()
            }
        case .colour:
            Image("ic-match-colour")
                .resizable()
                .frame(width: 14.33, height: 14.33)
        case .price:
            Image("ic-match-price")
                .resizable()
                .frame(width: 16, height: 16)
        case .occasion:
            Image("ic-match-occasion")
                .resizable()
                .frame(width: 13, height: 14.33)
        case .pattern:
            Image("ic-match-pattern")
                .resizable()
                .frame(width: 13.67, height: 13.67)
        }
    }
}

/// `gauge-container` (32:2583) — the score on a 4.8pt ring, out of 100.
struct MatchGauge: View {
    let score: Int
    var total = 100

    private let ring: CGFloat = 4.8

    var body: some View {
        ZStack {
            Circle()
                .inset(by: ring / 2)
                .stroke(GlanceColor.bgOverlay, lineWidth: ring)
            Circle()
                .inset(by: ring / 2)
                .trim(from: 0, to: CGFloat(score) / CGFloat(total))
                .stroke(Color.white, style: StrokeStyle(lineWidth: ring, lineCap: .round))
                // From twelve o'clock, with its round cap just clear of it.
                .rotationEffect(.degrees(-90 + 3.7))
            VStack(spacing: -4) {
                Text("\(score)")
                    .glanceText(.headlineL)
                    .foregroundStyle(GlanceColor.textPrimary)
                Text("\(total)")
                    .glanceText(.bodyCaption)
                    .foregroundStyle(GlanceColor.textSecondary)
            }
        }
        .frame(width: 80, height: 80)
        .accessibilityElement()
        .accessibilityLabel("Match score \(score) out of \(total)")
    }
}

// MARK: - Size

/// `Recommendation Section` (32:2635).
struct SizeSection: View {
    let guess: SizeGuess
    let sizes: [String]
    @Binding var selected: String?
    var onSizeChart: () -> Void
    var onUpdateSize: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            VStack(alignment: .leading, spacing: 16.4) {
                HStack(alignment: .center) {
                    SectionTitle(title: "I’d Go With")
                    SecondaryButton(
                        title: "View size chart",
                        style: .labelSmall,
                        height: 24,
                        padding: Space.md,
                        minWidth: 98,
                        action: onSizeChart
                    )
                }
                recommendation
            }
            available
        }
        .padding(.horizontal, gutter)
    }

    private var recommendation: some View {
        HStack(spacing: 0) {
            Text(guess.size)
                .font(.custom(GlanceTypeface.playfairRegular, size: 48))
                .foregroundStyle(GlanceColor.textPrimary)
                .frame(width: 88)
                .offset(x: 1.5)
                .accessibilityLabel("Recommended size \(guess.size)")
            Rectangle()
                .fill(GlanceColor.hairline)
                .frame(width: 1, height: 68)
            VStack(alignment: .leading, spacing: Space.sm) {
                Text(guess.rationale)
                    .glanceText(.bodyCaption)
                    .foregroundStyle(GlanceColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button(action: onUpdateSize) {
                    Text("Update size")
                        .glanceText(.bodyCaption)
                        .underline()
                        .foregroundStyle(GlanceColor.textPrimary)
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, 22)
            .padding(.trailing, 26)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 100.44)
        .l2Card(radius: 24.6)
    }

    private var available: some View {
        VStack(alignment: .leading, spacing: 10.25) {
            Text("AVAILABLE SIZES")
                .glanceText(.labelSmall)
                .foregroundStyle(GlanceColor.textPrimary)
            HStack(spacing: 8.2) {
                ForEach(sizes, id: \.self) { size in
                    let isSelected = size == selected
                    Button { selected = isSelected ? nil : size } label: {
                        Text(size)
                            .glanceText(.bodyCaption)
                            .foregroundStyle(isSelected ? GlanceColor.textInverse : GlanceColor.textPrimary)
                            .frame(width: 41, height: 41)
                            .background(isSelected ? GlanceColor.bgInverse : GlanceColor.bgOverlay, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Size \(size)")
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
    }
}

// MARK: - Colour

/// `Available Colors` (32:2659).
struct ColourSection: View {
    let colors: [ColorOption]
    let more: Int
    @Binding var selected: UUID?

    private let tile = CGSize(width: 68.33, height: 92.24)
    private let radius: CGFloat = 14.23

    var body: some View {
        VStack(alignment: .leading, spacing: 16.4) {
            SectionTitle(title: "Colour")
            HStack(alignment: .top, spacing: 12.3) {
                ForEach(colors) { option in
                    Button { selected = option.id } label: {
                        VStack(spacing: 4.1) {
                            swatch(option.image, isSelected: option.id == selected)
                            Text(option.name)
                                .glanceText(.labelSmall)
                                .foregroundStyle(GlanceColor.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(width: tile.width)
                    .accessibilityLabel(option.name)
                    .accessibilityAddTraits(option.id == selected ? .isSelected : [])
                }

                swatch("color-more", isSelected: false)
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(Color.black.opacity(0.7))
                        Text("+\(more)")
                            .glanceText(.bodyMedium)
                            .foregroundStyle(GlanceColor.textPrimary)
                    }
                    .accessibilityElement()
                    .accessibilityLabel("\(more) more colours")
            }
        }
        .padding(.horizontal, gutter)
    }

    /// `Button - Content Area` — the photograph in a hairline, lit from its top
    /// right by the comp's inner shadow.
    private func swatch(_ image: String, isSelected: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return Image(image)
            .resizable()
            .scaledToFill()
            .frame(width: tile.width, height: tile.height)
            .clipShape(shape)
            .innerGlow(shape, radius: 26.8, color: Color(white: 0.75).opacity(0.14), offset: CGSize(width: -5.36, height: 5.36))
            .overlay { shape.strokeBorder(isSelected ? Color.white : GlanceColor.hairline, lineWidth: 1) }
    }
}

// MARK: - Price trends

/// `Price Trends` (32:2677).
struct PriceTrendSection: View {
    let trend: PriceTrend
    var onBuy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            SectionTitle(title: "Price Trends")
            VStack(alignment: .leading, spacing: Space.xxl) {
                HStack(alignment: .top, spacing: Space.xl) {
                    VStack(alignment: .leading, spacing: Space.xxs) {
                        Text(trend.verdict)
                            .glanceText(.titleMedium)
                            .foregroundStyle(GlanceColor.textPrimary)
                        Text(trend.detail)
                            .glanceText(.bodyCaption)
                            .foregroundStyle(GlanceColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: onBuy) {
                        Text(trend.buyLabel)
                            .glanceText(.labelMedium)
                            .foregroundStyle(Color.black)
                            .padding(.horizontal, 18)
                            .frame(height: 32)
                            .background(Color.white, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                PriceTracker(trend: trend)
            }
            .padding(Space.xl)
            .l2Card()
        }
        .padding(.horizontal, gutter)
    }
}

/// `Price Tracker Visual` (32:2687): the range from lowest to highest with the
/// usual price ticked mid-track, today's price as the knob, and the stretch
/// from it up to the usual price — the saving — in green.
private struct PriceTracker: View {
    let trend: PriceTrend

    private let trackTop: CGFloat = 27
    private let trackHeight: CGFloat = 5

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                let width = geometry.size.width
                let now = width * trend.position(of: trend.current)
                let usual = width * trend.position(of: trend.usual)

                ZStack(alignment: .topLeading) {
                    Capsule()
                        .fill(GlanceColor.bgOverlay)
                        .frame(width: width, height: trackHeight)
                        .offset(y: trackTop)
                    UnevenRoundedRectangle(topLeadingRadius: 3, bottomLeadingRadius: 3, style: .continuous)
                        .fill(GlanceColor.positive)
                        .frame(width: max(0, usual - now), height: trackHeight)
                        .offset(x: now, y: trackTop)
                    Rectangle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 1, height: 9)
                        .offset(x: usual - 0.5, y: trackTop - 2)
                    knob
                        .offset(x: now - 7, y: trackTop - 4)
                    nowBubble
                        .offset(x: now - 34.5, y: -6)
                }
            }
            .frame(height: 40)

            HStack {
                limit("lowest", trend.lowest)
                Spacer()
                limit("usual", trend.usual)
                Spacer()
                limit("highest", trend.highest)
            }
            .frame(height: 29)
        }
        .accessibilityElement()
        .accessibilityLabel("Now \(trend.label(trend.current)). Lowest \(trend.label(trend.lowest)), usually \(trend.label(trend.usual)), highest \(trend.label(trend.highest)).")
    }

    /// `Slider Knob` — white, ringed in `surfaceBright`, on a soft drop shadow.
    private var knob: some View {
        Circle()
            .fill(Color.white)
            .overlay { Circle().inset(by: 0.75).stroke(GlanceColor.surfaceBright, lineWidth: 1.5) }
            .frame(width: 14, height: 14)
            .shadow(color: Color.black.opacity(0.25), radius: 2, y: 1)
    }

    /// `$99 now` on the comp's bubble, centred over the knob.
    private var nowBubble: some View {
        Text("\(trend.label(trend.current)) now")
            .glanceText(.labelMedium)
            .foregroundStyle(GlanceColor.textPrimary)
            .frame(width: 69, height: 23)
            .padding(.bottom, 5.39)
            .background {
                PointerBubble(cornerRadius: 11.5, tailWidth: 9.53, tailHeight: 5.39)
                    .fill(GlanceColor.bgOverlay)
            }
    }

    private func limit(_ label: String, _ price: Double) -> some View {
        VStack(spacing: 0) {
            Text(label)
                .glanceText(.labelSmall)
            Text(trend.label(price))
                .glanceText(.labelMedium)
        }
        .foregroundStyle(GlanceColor.textSecondary)
        .multilineTextAlignment(.center)
    }
}

// MARK: - Delivery

/// `Delivery & Returns` (32:2702).
struct DeliverySection: View {
    let delivery: Delivery

    private let columns = [
        GridItem(.flexible(), spacing: 40, alignment: .leading),
        GridItem(.flexible(), alignment: .leading)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            SectionTitle(title: "Delivery & Returns")
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: Space.xs) {
                    Text("\(Text(delivery.lead).foregroundStyle(GlanceColor.textSecondary)) \(Text(delivery.date).foregroundStyle(GlanceColor.textPrimary))")
                        .glanceText(.bodyMedium)
                    Text("\(Text("Delivery to").foregroundStyle(GlanceColor.textSecondary)) \(Text(delivery.place).foregroundStyle(GlanceColor.textPrimary))")
                        .glanceText(.labelMedium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 19)
                .padding(.vertical, 17)
                .background(GlanceColor.bgOverlay, in: RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))

                LazyVGrid(columns: columns, alignment: .leading, spacing: Space.xl) {
                    ForEach(delivery.facts) { fact in
                        HStack(spacing: Space.md) {
                            DeliveryGlyph(icon: fact.icon)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(fact.label)
                                    .glanceText(.labelSmall)
                                    .foregroundStyle(GlanceColor.textSecondary)
                                Text(fact.value)
                                    .glanceText(.labelMedium)
                                    .foregroundStyle(GlanceColor.textPrimary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
        .padding(.horizontal, gutter)
    }
}

/// The 32pt discs the delivery facts lead with (32:2712 …).
private struct DeliveryGlyph: View {
    let icon: DeliveryIcon

    var body: some View {
        Group {
            switch icon {
            case .fees:
                // Exported whole, disc and all.
                Image("ic-del-fees").resizable()
            case .returnWindow:
                disc {
                    Image("ic-del-return").resizable().frame(width: 13.67, height: 13.67)
                }
            case .exchange:
                disc {
                    Image("ic-del-exchange").resizable().frame(width: 13, height: 13)
                }
            case .pickup:
                disc {
                    Image("ic-del-truck").resizable().frame(width: 14.33, height: 11.67).offset(y: 0.24)
                    // The return arrow riding in the truck's box.
                    Image("ic-del-truck-arrow")
                        .resizable()
                        .frame(width: 3.5, height: 6.33)
                        .rotationEffect(.degrees(-90))
                        .offset(x: -4.33, y: -2)
                }
            }
        }
        .frame(width: 32, height: 32)
        .accessibilityHidden(true)
    }

    private func disc<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        ZStack {
            Circle().fill(GlanceColor.bgOverlay)
            content()
        }
    }
}

// MARK: - Help us improve

/// `HELP US IMPROVE` (32:2741) — the page asking something back, in the feed's
/// signal-card voice: once answered, it says what it took from the answer.
struct FitQuestionCard: View {
    let question: FitQuestion
    var onAnswer: (String) -> Void = { _ in }

    @State private var answer: String?

    private let shape = RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Group {
                if let answer {
                    answered(answer)
                } else {
                    asking
                }
            }
            .padding(.top, 26.6)
        }
        .padding(.horizontal, 20.5)
        .padding(.top, 20.78)
        .padding(.bottom, 29.8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { surface }
        .clipShape(shape)
        .padding(.horizontal, gutter)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: answer)
    }

    private var header: some View {
        HStack(spacing: 12.9) {
            // The viewer, ringed in lavender — as the feed's signal card has her.
            CroppedImage(name: "profile-hero", crop: ImageCrop(width: 276, height: 287, x: -90, y: -5, reference: 104))
                .frame(width: 23.57, height: 23.57)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(GlanceColor.accentSecondary, lineWidth: 1))
                .shadow(color: Color(hex: 0x765AEA, opacity: 0.6), radius: 10)
                .accessibilityHidden(true)
            Text(question.label.uppercased())
                .font(.custom(GlanceTypeface.manropeMedium, size: 9))
                .tracking(3)
                .foregroundStyle(GlanceColor.accentSecondary)
        }
    }

    private var asking: some View {
        VStack(alignment: .leading, spacing: 19.8) {
            Text(question.text)
                .glanceText(.displaySmall)
                .foregroundStyle(GlanceColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 10.25) {
                ForEach(question.options, id: \.self) { option in
                    SecondaryButton(title: option, style: .labelLarge, height: 48, padding: Space.xl, fillsWidth: true) {
                        answer = option
                        onAnswer(option)
                    }
                }
            }
        }
    }

    private func answered(_ answer: String) -> some View {
        VStack(alignment: .leading, spacing: Space.md) {
            Text(answer)
                .glanceText(.displaySmall)
                .foregroundStyle(GlanceColor.textPrimary)
            Text(question.acknowledgement)
                .glanceText(.bodyCaption)
                .foregroundStyle(GlanceColor.textMuted)
                .fixedSize(horizontal: false, vertical: true)
                .transition(.opacity)
        }
    }

    /// White at 8% under `Inner Glow/Soft`, with two soft discs of light — one
    /// over the top edge, one off the bottom-right corner (32:2764, 32:2765).
    private var surface: some View {
        shape
            .fill(GlanceColor.bgOverlay)
            .overlay(alignment: .top) {
                let glow = SoftGlow(color: .white, peak: 0.28, reach: 120)
                glow.offset(x: 0.92, y: -51.76 - glow.reach)
            }
            .overlay(alignment: .bottomTrailing) {
                let glow = SoftGlow(color: .white, peak: 0.28, reach: 120)
                glow.offset(x: 25.9 + glow.reach, y: 36 + glow.reach)
            }
            .innerGlow(shape, radius: 20.5, color: Color.white.opacity(0.15))
    }
}

// MARK: - Where can you wear this?

/// `Where can you wear this?` (32:2766) — an occasion each, on a board of the
/// pieces that make the look.
struct WearBoardsSection: View {
    let outfits: [Outfit]
    var onStyle: (Outfit) -> Void
    var onSwap: (Outfit) -> Void
    var onAdd: (Outfit) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            SectionTitle(title: "Where can you wear this?")
            VStack(spacing: Space.xl) {
                ForEach(outfits) { outfit in
                    OutfitBoard(
                        outfit: outfit,
                        onStyle: { onStyle(outfit) },
                        onSwap: { onSwap(outfit) },
                        onAdd: { onAdd(outfit) }
                    )
                }
            }
        }
        .padding(.horizontal, gutter)
    }
}

/// `4 Product` / `3 Product` (32:2769, 32:2802).
private struct OutfitBoard: View {
    let outfit: Outfit
    var onStyle: () -> Void
    var onSwap: () -> Void
    var onAdd: () -> Void

    private let shape = RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
    /// The collage's own canvas (32:2775).
    private let canvas = CGSize(width: 297.72, height: 252)

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                ForEach(outfit.tiles) { tile in
                    OutfitTileView(tile: tile, onSwap: onSwap, onAdd: onAdd)
                        .frame(width: tile.frame.width, height: tile.frame.height)
                        .offset(x: tile.frame.x, y: tile.frame.y)
                }
            }
            .frame(width: canvas.width, height: canvas.height, alignment: .topLeading)
            .padding(.top, 30.94)
            .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            HStack(alignment: .bottom, spacing: Space.lg) {
                VStack(alignment: .leading, spacing: Space.xs) {
                    Text(outfit.title)
                        .glanceText(.displayMedium)
                        .foregroundStyle(GlanceColor.textPrimary)
                    Text(outfit.summary)
                        .glanceText(.bodyCaption)
                        .foregroundStyle(GlanceColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: 186, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                SecondaryButton(
                    title: "Style me",
                    icon: "ic-style-me-small",
                    hairline: GlanceColor.hairline,
                    action: onStyle
                )
            }
            .padding(.horizontal, Space.xl)
            .padding(.top, Space.xxs)
            .padding(.bottom, 23)
        }
        .frame(height: 398)
        .background {
            // `Ellipse 2465479` — a wash of light off the top-left corner.
            shape
                .fill(GlanceColor.bgOverlay)
                .glow(SoftGlow(color: .white, peak: 0.11, reach: 160), centeredAt: CGPoint(x: 9, y: -9))
        }
        .clipShape(shape)
        .overlay { shape.strokeBorder(Color(hex: 0x5D5D5D), lineWidth: 1) }
    }
}

private struct OutfitTileView: View {
    let tile: OutfitTile
    var onSwap: () -> Void
    var onAdd: () -> Void

    private let shape = RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)

    var body: some View {
        switch tile.content {
        case .piece(let image, let art, let crop):
            ZStack(alignment: .topLeading) {
                Color.white
                PieceArt(image: image, crop: crop)
                    .frame(width: art.width, height: art.height)
                    .offset(x: art.x, y: art.y)
            }
            .clipShape(shape)
            .overlay(alignment: .topTrailing) {
                if tile.swappable {
                    SwapPieceButton(action: onSwap)
                        .padding(7)
                }
            }
        case .add:
            Button(action: onAdd) {
                shape
                    .fill(GlanceColor.bgOverlay)
                    .overlay {
                        Image("ic-plus-add")
                            .resizable()
                            .frame(width: 14.58, height: 14.58)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add a piece")
        }
    }
}

/// A piece's image in its art box: the comp's crop of a flat-lay sprite, or a
/// cover fill.
private struct PieceArt: View {
    let image: String
    let crop: CompRect?

    var body: some View {
        GeometryReader { geometry in
            if let crop {
                Image(image)
                    .resizable()
                    .frame(width: crop.width, height: crop.height)
                    .offset(x: crop.x, y: crop.y)
            } else {
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }
}

/// `Icon Button / Circular / Small / Glass` (32:2782) — glass by name in the
/// comp itself, tinted dark the way its scrim sits on a white tile.
private struct SwapPieceButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image("ic-edit-small")
                .resizable()
                .frame(width: 10, height: 10)
                .frame(width: 24, height: 24)
                .liquidGlass(in: Circle(), tint: Color.black.opacity(0.6), interactive: true) { button in
                    button
                        .background(Circle().fill(Color.white.opacity(0.08)))
                        .background(Circle().fill(Color.black.opacity(0.6)))
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Swap this piece")
    }
}

// MARK: - More I think you'll like

/// `More I think you'll like` (32:2825) — two columns, stacked as the comp
/// stacks them, the second closing on a way to find more.
struct MoreLikeThisSection: View {
    let items: [SuggestedProduct]
    var onSelect: (SuggestedProduct) -> Void
    var onFindSimilar: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionTitle(title: "More I think you’ll like")
            HStack(alignment: .top, spacing: Space.xl) {
                VStack(spacing: Space.xl) {
                    ForEach(items.prefix(2)) { card($0) }
                }
                VStack(spacing: Space.xl) {
                    ForEach(items.dropFirst(2)) { card($0) }
                    FindSimilarCard(action: onFindSimilar)
                }
            }
        }
        .padding(.horizontal, gutter)
    }

    @ViewBuilder
    private func card(_ item: SuggestedProduct) -> some View {
        Button { onSelect(item) } label: {
            switch item.style {
            case .look: LookSuggestionCard(item: item)
            case .product: ProductSuggestionCard(item: item)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel([item.brand, item.title, item.price].compactMap { $0 }.joined(separator: ", "))
    }
}

/// The photograph on a suggestion card, on white, in its comp-sized art box.
private struct SuggestionPhoto: View {
    let item: SuggestedProduct

    var body: some View {
        GeometryReader { geometry in
            // The comp's column is 170pt; the art scales with the real one.
            let scale = geometry.size.width / 170
            Image(item.image)
                .resizable()
                .scaledToFill()
                .frame(width: item.art.width * scale, height: item.art.height * scale)
                .offset(x: item.art.x * scale, y: item.art.y * scale)
        }
        .background(Color.white)
        .clipped()
    }
}

/// The photograph fading into the card's colour, from 60% of the way down.
private struct TintFade: View {
    let tint: Color

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: tint.opacity(0), location: 0.6),
                .init(color: tint, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .allowsHitTesting(false)
    }
}

/// The white price pill (32:2834): now in SemiBold, before in Regular.
private struct SuggestionPrice: View {
    let price: String
    let was: String

    var body: some View {
        HStack(spacing: Space.xxs) {
            Text(price)
                .font(.custom(GlanceTypeface.manropeSemiBold, size: 12))
                .tracking(0.5)
                .foregroundStyle(Color.black)
            Text(was)
                .font(.custom(GlanceTypeface.manropeRegular, size: 12))
                .tracking(0.4)
                .foregroundStyle(GlanceColor.surfaceBright)
        }
        .padding(.horizontal, Space.sm)
        .padding(.vertical, Space.xxs)
        .background(Color.white, in: Capsule())
    }
}

/// `Card` (32:2829) — the photograph fades into the card's own colour, and the
/// price and name sit on it.
private struct LookSuggestionCard: View {
    let item: SuggestedProduct

    var body: some View {
        let tint = Color(hex: item.tint)

        ZStack(alignment: .topLeading) {
            tint
            SuggestionPhoto(item: item)
                .frame(height: 213.49)
                .overlay { TintFade(tint: tint) }
            VStack(alignment: .leading, spacing: 11.86) {
                SuggestionPrice(price: item.price, was: item.wasPrice)
                Text(item.title)
                    .glanceText(.displaySmall)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 14.33)
            .padding(.trailing, Space.lg)
            .padding(.top, 230.31)
        }
        .frame(height: 320.23)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
    }
}

/// `Non Fashion Cards` (32:2838) — a photograph over its brand and name, the
/// price on the photograph and a save button over it.
private struct ProductSuggestionCard: View {
    let item: SuggestedProduct

    var body: some View {
        let tint = Color(hex: item.tint)

        VStack(alignment: .leading, spacing: 0) {
            SuggestionPhoto(item: item)
                .frame(height: 226)
                .overlay { TintFade(tint: tint) }
                .overlay(alignment: .bottomLeading) {
                    SuggestionPrice(price: item.price, was: item.wasPrice)
                        .padding(.leading, Space.md)
                        .padding(.bottom, Space.sm)
                }
                .overlay(alignment: .topTrailing) {
                    WishlistButton(tone: .scrim)
                        .padding(Space.md)
                }

            VStack(alignment: .leading, spacing: Space.sm) {
                if let brand = item.brand {
                    Text(brand)
                        .glanceText(.labelSmall)
                }
                Text(item.title)
                    .glanceText(.displaySmall)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(GlanceColor.textPrimary)
            .padding(.horizontal, Space.lg)
            .padding(.top, Space.xxs)
            .padding(.bottom, Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint)
        }
        .background(Color(hex: 0x252525))
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
        .glanceCardShadow()
    }
}

/// `Find Similar Products` (32:2861) — a fan of looks over a halftone disc,
/// lit in lavender, as the way into more like this one.
struct FindSimilarCard: View {
    /// The comp's own height for its column: 324 on L2, 380 on a look's page.
    var height: CGFloat = 324
    /// The look on the fan's front card.
    var frontImage = "similar-front"
    var action: () -> Void

    private let shape = RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)

    var body: some View {
        Button(action: action) {
            VStack(spacing: 32) {
                SimilarFan(frontImage: frontImage)
                    .frame(width: 124, height: 124)
                VStack(spacing: Space.lg) {
                    Text("Find Similar Products")
                        .glanceText(.bodyMedium)
                        .foregroundStyle(GlanceColor.textPrimary)
                        .multilineTextAlignment(.center)
                    Image("ic-arrow-forward-dark")
                        .resizable()
                        .frame(width: 8, height: 7)
                        .frame(width: 32, height: 32)
                        .background(Color.white, in: Circle())
                }
                .frame(width: 124)
            }
            .padding(.top, 40)
            .frame(maxWidth: .infinity)
            .frame(height: height, alignment: .top)
            .background { surface }
            .clipShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Find similar products")
    }

    /// Three lavender discs blurred into a wash over the card (32:2862 …), and
    /// the larger sparkle off the fan's shoulder.
    private var surface: some View {
        let lavender = GlanceColor.accentSecondary
        return shape
            .fill(GlanceColor.bgOverlay)
            .glow(SoftGlow(color: lavender, peak: 0.14, reach: 200), centeredAt: CGPoint(x: -8.7, y: 20.4))
            .glow(SoftGlow(color: lavender, peak: 0.14, reach: 200), centeredAt: CGPoint(x: 85.6, y: 159.4))
            .glow(SoftGlow(color: lavender, peak: 0.14, reach: 200), centeredAt: CGPoint(x: 183.8, y: 322.5))
            .overlay(alignment: .topLeading) {
                Image("ic-sparkle-large")
                    .resizable()
                    .frame(width: 15.41, height: 13.91)
                    .offset(x: 130.63, y: 51.98)
            }
    }
}

/// `Frame 2147239555` — three looks fanned over a halftone disc.
private struct SimilarFan: View {
    var frontImage: String
    private let card = CGSize(width: 63.06, height: 83.98)
    private let shape = RoundedRectangle(cornerRadius: 9.76, style: .continuous)

    var body: some View {
        ZStack(alignment: .topLeading) {
            HalftoneDisc()
                .frame(width: 140, height: 140)
                .offset(x: -13.39, y: -3.15)

            backCard(Color(hex: 0xB4BBA5), angle: -18.09, box: CompRect(8.14, 18.89, 86.02, 99.41))
            backCard(Color(hex: 0x8A9279), angle: -3.09, box: CompRect(28.67, 20.33, 67.5, 87.27))

            // The front card tilts one way and its photograph the other, so the
            // look stands upright in a tilted frame.
            Image(frontImage)
                .resizable()
                .scaledToFill()
                .frame(width: 80.72, height: 107.6)
                .rotationEffect(.degrees(-11.94))
                .offset(x: 1.13, y: 6.73)
                .frame(width: card.width, height: card.height)
                .clipShape(shape)
                .modifier(FanCardFinish(shape: shape))
                .rotationEffect(.degrees(11.91))
                .frame(width: 79.03, height: 95.19)
                .offset(x: 35.9, y: 13.09)

            Image("ic-sparkle-small")
                .resizable()
                .frame(width: 8.63, height: 7.96)
                .offset(x: 17.88, y: 109.05)
        }
        .frame(width: 124, height: 124, alignment: .topLeading)
        .accessibilityHidden(true)
    }

    private func backCard(_ fill: Color, angle: Double, box: CompRect) -> some View {
        shape
            .fill(fill)
            .frame(width: card.width, height: card.height)
            .modifier(FanCardFinish(shape: shape))
            .rotationEffect(.degrees(angle))
            .frame(width: box.width, height: box.height)
            .offset(x: box.x, y: box.y)
    }
}

/// The fan's cards: a white hairline and a drop shadow, `0 4.9 4.9 #00000059`.
private struct FanCardFinish: ViewModifier {
    let shape: RoundedRectangle

    func body(content: Content) -> some View {
        content
            .overlay { shape.strokeBorder(Color.white, lineWidth: 0.65) }
            .shadow(color: Color.black.opacity(0.35), radius: 2.44, y: 4.88)
    }
}

/// The halftone disc behind the fan (32:2868). Figma exports it as a boolean of
/// several hundred dots, too large to bring across, so it is drawn instead: a
/// dot grid that thins and fades out from the middle.
private struct HalftoneDisc: View {
    var body: some View {
        Canvas { context, size in
            let pitch: CGFloat = 5
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            var y = pitch / 2
            while y < size.height {
                var x = pitch / 2
                while x < size.width {
                    let reach = hypot(x - center.x, y - center.y) / radius
                    if reach < 1 {
                        let dot = 1.5 * (1 - reach * 0.6)
                        context.fill(
                            Path(ellipseIn: CGRect(x: x - dot / 2, y: y - dot / 2, width: dot, height: dot)),
                            with: .color(Color.white.opacity(0.28 * (1 - reach)))
                        )
                    }
                    x += pitch
                }
                y += pitch
            }
        }
        .allowsHitTesting(false)
    }
}
