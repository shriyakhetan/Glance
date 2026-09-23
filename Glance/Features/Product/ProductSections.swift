import Charts
import SwiftUI

private let gutter = Space.xl

// MARK: - Gallery, price, purchase buttons

struct ProductGallerySection: View {
    let product: Product
    @Binding var imageIndex: Int
    @Binding var isWishlisted: Bool
    var onTryOn: () -> Void
    var onBuy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            ScrollView(.horizontal) {
                HStack(spacing: 15.19) {
                    ForEach(Array(product.images.enumerated()), id: \.offset) { index, name in
                        Image(name)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 218.59, height: 291.45)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
                            .id(index)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, gutter)
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: Binding(
                get: { imageIndex },
                set: { imageIndex = $0 ?? 0 }
            ))
            .frame(height: 291.45)

            PageDots(count: product.images.count, index: imageIndex)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: Space.xs) {
                Text(product.brand)
                    .glanceText(.displayL)
                    .foregroundStyle(GlanceColor.textPrimary)
                Text(product.name)
                    .glanceText(.headingM)
                    .foregroundStyle(GlanceColor.textMuted)
                HStack(spacing: 6.13) {
                    Text(product.price)
                        .glanceText(.headingL)
                        .foregroundStyle(GlanceColor.textPrimary)
                    Text(product.originalPrice)
                        .glanceText(.headingM)
                        .foregroundStyle(GlanceColor.textPrimary.opacity(0.4))
                        .strikethrough()
                    Text(product.discount)
                        .glanceText(.captionMedium)
                        .foregroundStyle(GlanceColor.textPrimary)
                        .padding(.horizontal, 12.26)
                        .padding(.vertical, 6.13)
                        .background(Capsule().fill(Color.white.opacity(0.12)))
                }
            }
            .padding(.horizontal, gutter)

            HStack(spacing: Space.md) {
                Button(action: onBuy) {
                    HStack(spacing: Space.sm) {
                        Text("Buy on")
                            .glanceText(.headingS)
                            .fixedSize()
                            .foregroundStyle(.black)
                        Image("ic-amazon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 54, height: 23)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.black)
                    }
                    .frame(height: 22)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(GlanceColor.bgInverse))
                }
                .buttonStyle(.plain)
                .fixedSize()

                Button(action: onTryOn) {
                    HStack(spacing: Space.xxs) {
                        Image("ic-tryon-union")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 11, height: 11.36)
                        Text("Try On")
                            .glanceText(.headingS)
                            .foregroundStyle(GlanceColor.textPrimary)
                    }
                    .frame(height: 40)
                    .padding(.horizontal, Space.xl)
                    .background(Capsule().fill(GlanceColor.bgOverlaySubtle))
                }
                .buttonStyle(.plain)

                Button { isWishlisted.toggle() } label: {
                    Image("ic-heart")
                        .renderingMode(isWishlisted ? .template : .original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14.55, height: 14.55)
                        .foregroundStyle(Color(hex: 0xFB3C3C))
                        .padding(13)
                        .background(Circle().fill(GlanceColor.bgOverlaySubtle))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isWishlisted ? "Remove from wishlist" : "Add to wishlist")
            }
            .padding(.horizontal, gutter)
        }
        .padding(.vertical, gutter)
    }
}

// MARK: - Reviews

struct ReviewsSection: View {
    let product: Product
    @Binding var reviewIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            SectionTitle(title: "Reviews & Insights")

            HStack {
                HStack(alignment: .bottom, spacing: Space.xxs) {
                    Image("ic-star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                    Text(product.rating)
                        .glanceText(.headingXL)
                        .foregroundStyle(GlanceColor.textPrimary)
                    Text(product.ratingCount)
                        .glanceText(.headingM)
                        .foregroundStyle(Color.white.opacity(0.3))
                }
                Spacer()
                Button {} label: {
                    HStack(spacing: Space.xxs) {
                        Text("View all reviews")
                            .glanceText(.captionRegular)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(GlanceColor.textPrimary)
                    .padding(.horizontal, Space.lg)
                    .frame(height: 31)
                    .background(Capsule().fill(GlanceColor.bgOverlaySubtle))
                }
                .buttonStyle(.plain)
            }

            GeometryReader { geo in
                ScrollView(.horizontal) {
                    HStack(spacing: Space.lg) {
                        ForEach(Array(product.reviews.enumerated()), id: \.element.id) { index, review in
                            reviewCard(review)
                                .frame(width: geo.size.width)
                                .id(index)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: Binding(
                    get: { reviewIndex },
                    set: { reviewIndex = $0 ?? 0 }
                ))
            }
            .frame(height: 314)
        }
        .padding(gutter)
    }

    private func reviewCard(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(review.highlight)
                .glanceText(.displayM)
                .foregroundStyle(GlanceColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 35 - Space.xl)

            Image("ic-quote")
                .resizable()
                .scaledToFit()
                .frame(width: 23, height: 20)
                .padding(.top, Space.xl)

            Text(review.body)
                .glanceText(.bodyS)
                .foregroundStyle(GlanceColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Space.sm)

            Spacer(minLength: Space.lg)

            Text(review.author)
                .glanceText(.bodyS)
                .foregroundStyle(GlanceColor.textDisabled)

            PageDots(count: product.reviews.count, index: reviewIndex)
                .frame(maxWidth: .infinity)
                .padding(.top, Space.lg)
        }
        .padding(gutter)
        .frame(height: 314, alignment: .top)
        .glassPanel(cornerRadius: Radius.xl, rimOpacity: 0.15, rimRadius: 20)
    }
}

// MARK: - AI summary

struct AISummarySection: View {
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            HStack(spacing: Space.sm) {
                Image(systemName: "sparkle")
                    .font(.system(size: 12))
                    .foregroundStyle(GlanceColor.textAccent)
                Text("AI review Summary")
                    .glanceText(.headingS)
                    .foregroundStyle(GlanceColor.textPrimary)
            }
            Text(summary)
                .glanceText(.displayM)
                .foregroundStyle(GlanceColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, 24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(gutter)
        .background(alignment: .trailing) {
            // The soft four-point spark that watermarks the summary.
            Image(systemName: "sparkle")
                .font(.system(size: 150))
                .foregroundStyle(Color.white.opacity(0.05))
                .offset(x: 40)
                .allowsHitTesting(false)
        }
        .clipped()
    }
}

// MARK: - Size

struct SizeGuessSection: View {
    let product: Product
    @Binding var selectedSize: String

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            VStack(alignment: .leading, spacing: Space.lg) {
                HStack(alignment: .bottom, spacing: Space.md) {
                    Text("My Size Guess")
                        .glanceText(.displayL)
                        .foregroundStyle(GlanceColor.textPrimary)
                    Text(product.sizeGuess.confidence, style: .labelOverline)
                        .glanceText(.labelOverline)
                        .foregroundStyle(Color(hex: 0x906FFF))
                        .padding(.horizontal, Space.sm)
                        .frame(height: 24)
                        .background(Capsule().fill(Color(hex: 0x906FFF, opacity: 0.1)))
                }

                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Text(product.sizeGuess.size)
                            .font(.custom(GlanceTypeface.serifRegular, size: 40))
                            .foregroundStyle(GlanceColor.textPrimary)
                        Text("Recommended", style: .labelOverline)
                            .glanceText(.labelOverline)
                            .foregroundStyle(GlanceColor.textPrimary.opacity(0.6))
                    }
                    .frame(width: 72)
                    .padding(.leading, 21)

                    Rectangle()
                        .fill(GlanceColor.borderSubtle)
                        .frame(width: 1, height: 66)
                        .padding(.horizontal, Space.xl)

                    Text(product.sizeGuess.rationale)
                        .glanceText(.captionRegular)
                        .foregroundStyle(GlanceColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, Space.lg)
                .frame(maxWidth: .infinity, minHeight: 98)
                .glassPanel()
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Available sizes")
                    .glanceText(.captionMedium)
                    .foregroundStyle(GlanceColor.textPrimary)
                HStack(spacing: Space.sm) {
                    ForEach(product.availableSizes, id: \.self) { size in
                        let isSelected = size == selectedSize
                        Button { selectedSize = size } label: {
                            Text(size)
                                .glanceText(.captionRegular)
                                .foregroundStyle(isSelected ? GlanceColor.textInverse : GlanceColor.textPrimary)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(isSelected ? GlanceColor.bgInverse : GlanceColor.bgOverlaySubtle))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(gutter)
    }
}

// MARK: - Colors

struct ColorsSection: View {
    let product: Product
    @Binding var selectedColor: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            SectionTitle(title: "Colors")
            HStack(alignment: .top, spacing: Space.md) {
                ForEach(product.colors) { option in
                    Button { selectedColor = option.id } label: {
                        VStack(spacing: Space.xxs) {
                            swatch(image: option.image, isSelected: option.id == selectedColor)
                            Text(option.name)
                                .glanceText(.captionMedium)
                                .foregroundStyle(GlanceColor.textMuted)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(width: 66.67)
                }

                ZStack {
                    swatch(image: "color-more", isSelected: false)
                        .overlay(
                            RoundedRectangle(cornerRadius: 13.89, style: .continuous)
                                .fill(Color.black.opacity(0.7))
                        )
                    Text("+\(product.moreColors)")
                        .glanceText(.headingL)
                        .foregroundStyle(GlanceColor.textPrimary)
                }
                .frame(width: 66.67, height: 90)
            }
        }
        .padding(gutter)
    }

    private func swatch(image: String, isSelected: Bool) -> some View {
        Image(image)
            .resizable()
            .scaledToFill()
            .frame(width: 66.67, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 13.89, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 13.89, style: .continuous)
                    .strokeBorder(isSelected ? Color.white : Color.white.opacity(0.35), lineWidth: 1.31)
            )
    }
}

// MARK: - Price trend

struct PriceTrendSection: View {
    let product: Product
    @Binding var range: PriceRange

    private var points: [PricePoint] { product.history(for: range) }

    private var axisDates: [Date] {
        guard let first = points.first?.date, let last = points.last?.date, points.count > 2 else { return [] }
        return [first, points[points.count / 2].date, last]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            VStack(alignment: .leading, spacing: Space.lg) {
                SectionTitle(title: "Price Trends")

                HStack(alignment: .top) {
                    stat(product.priceStats.low, "6 month low")
                    Spacer()
                    stat(product.priceStats.typical, "typical price")
                    Spacer()
                    stat(product.priceStats.high, "6 month high")
                }

                chart
                    .frame(height: 200)
                    // Room for the trailing date label, which sits on the plot edge.
                    .padding(.trailing, 14)

                HStack(spacing: 7.53) {
                    ForEach(PriceRange.allCases) { option in
                        Button { withAnimation(.easeInOut(duration: 0.25)) { range = option } } label: {
                            Text(option.rawValue)
                                .glanceText(.captionMedium)
                                .foregroundStyle(option == range ? Color(hex: 0x0D0D0D) : GlanceColor.textPrimary)
                                .frame(height: 30.9)
                                .frame(maxWidth: .infinity)
                                .background(Capsule().fill(option == range ? GlanceColor.bgInverse : GlanceColor.bgOverlaySubtle))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            offerCard
        }
        .padding(gutter)
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 3.77) {
            Text(value)
                .glanceText(.headingS)
                .foregroundStyle(GlanceColor.textPrimary.opacity(0.8))
            Text(label)
                .glanceText(.captionRegular)
                .foregroundStyle(GlanceColor.textMuted)
        }
    }

    private var chart: some View {
        Chart {
            ForEach(points) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Price", point.price)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .foregroundStyle(GlanceColor.textPrimary)
            }

            if let last = points.last {
                RuleMark(x: .value("Date", last.date))
                    .lineStyle(StrokeStyle(lineWidth: 0.94))
                    .foregroundStyle(Color.white.opacity(0.2))

                PointMark(
                    x: .value("Date", last.date),
                    y: .value("Price", last.price)
                )
                .symbolSize(56)
                .foregroundStyle(GlanceColor.textPrimary)
                .annotation(position: .topLeading, spacing: Space.sm) {
                    VStack(alignment: .leading, spacing: 1.88) {
                        Text(String(format: "$%.2f", last.price))
                            .glanceText(.captionBold)
                            .foregroundStyle(GlanceColor.textPrimary)
                        Text(last.date.formatted(.dateTime.month(.abbreviated).day().year()))
                            .glanceText(.captionRegular)
                            .foregroundStyle(GlanceColor.textTertiary)
                    }
                    .padding(.horizontal, 9.42)
                    .padding(.vertical, 5.65)
                    .background(RoundedRectangle(cornerRadius: 7.53, style: .continuous).fill(Color(hex: 0x333232)))
                }
            }
        }
        .chartYScale(domain: 0...80)
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 40, 60, 80]) { value in
                AxisGridLine().foregroundStyle(GlanceColor.bgOverlay)
                AxisValueLabel {
                    Text("$\(value.as(Int.self) ?? 0)")
                        .glanceText(.captionRegular)
                        .foregroundStyle(GlanceColor.textDisabled)
                }
            }
        }
        .chartXAxis {
            // Three anchors — start, middle, today — as in the comp.
            AxisMarks(values: axisDates) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date.formatted(.dateTime.month(.abbreviated).day()))
                            .glanceText(.captionRegular)
                            .foregroundStyle(GlanceColor.textDisabled)
                    }
                }
            }
        }
    }

    private var offerCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: Space.xs) {
                HStack(alignment: .firstTextBaseline, spacing: Space.xxs) {
                    Text(product.offer.price)
                        .font(.custom(GlanceTypeface.serifBold, size: 20))
                        .foregroundStyle(.white)
                    Text(product.offer.strikethrough)
                        .font(.custom(GlanceTypeface.serifRegular, size: 16))
                        .strikethrough()
                        .foregroundStyle(GlanceColor.textTertiary)
                }
                HStack(spacing: Space.xxs) {
                    Text("with your")
                        .glanceText(.bodyS)
                    Text(product.offer.card)
                        .font(.custom(GlanceTypeface.serifBoldItalic, size: 12))
                }
                .foregroundStyle(GlanceColor.textPrimary)
            }

            Spacer(minLength: Space.md)

            VStack(alignment: .trailing, spacing: 10) {
                Text(product.offer.saveExtra)
                    .glanceText(.bodyS)
                    .foregroundStyle(Color.white.opacity(0.9))
                    .padding(.horizontal, Space.sm)
                    .padding(.vertical, Space.xxs)
                    .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color(hex: 0x021605)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(Color.white, lineWidth: 0.5)
                    )
                    .shadow(color: Color(hex: 0x85C183, opacity: 0.9), radius: 5, x: -2, y: 0)

                HStack(spacing: 7) {
                    Text("+\(product.offer.additionalOffers) offers")
                        .glanceText(.bodyS)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(GlanceColor.textPrimary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 19)
        .glassPanel(rimOpacity: 0.08, rimRadius: 10)
    }
}

// MARK: - Why it works

struct WhyItWorksSection: View {
    let items: [WhyItWorks]

    private let columns = [GridItem(.flexible(), spacing: Space.md), GridItem(.flexible(), spacing: Space.md)]

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            SectionTitle(title: "Why it works for you")
            LazyVGrid(columns: columns, alignment: .leading, spacing: Space.md) {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: Space.lg) {
                        Text(item.title)
                            .glanceText(.displayM)
                            .foregroundStyle(GlanceColor.textPrimary)
                        Text(item.detail)
                            .glanceText(.bodyS)
                            .foregroundStyle(GlanceColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
                    .padding(Space.lg)
                    .glassPanel(cornerRadius: Radius.lg, rimOpacity: 0.12, rimRadius: 16)
                }
            }
        }
        .padding(gutter)
    }
}

// MARK: - Delivery

struct DeliverySection: View {
    let delivery: Delivery

    private let columns = [GridItem(.flexible(), spacing: Space.md), GridItem(.flexible(), spacing: Space.md)]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionTitle(title: "Delivery & Returns")

            VStack(alignment: .leading, spacing: Space.xs) {
                Text(delivery.headline)
                    .glanceText(.headingS)
                    .foregroundStyle(GlanceColor.textTertiary)
                HStack(spacing: Space.xxs) {
                    Text(delivery.deliveredToLabel)
                        .glanceText(.bodySMedium)
                        .foregroundStyle(GlanceColor.textTertiary)
                    Text(delivery.pincode)
                        .glanceText(.bodySMedium)
                        .foregroundStyle(GlanceColor.textPrimary)
                }
                HStack(spacing: Space.sm) {
                    Image(systemName: "airplane")
                        .font(.system(size: 12))
                        .foregroundStyle(GlanceColor.textSecondary)
                    Text(delivery.note)
                        .glanceText(.displayS)
                        .foregroundStyle(GlanceColor.textPrimary)
                }
                .padding(.top, Space.xs)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, gutter)
            .padding(.vertical, 19)
            .glassPanel(cornerRadius: 20, rimOpacity: 0.08, rimRadius: 10)

            LazyVGrid(columns: columns, alignment: .leading, spacing: Space.xl) {
                ForEach(delivery.facts) { fact in
                    HStack(spacing: Space.md) {
                        Image(fact.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 16)
                            .opacity(0.4)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(GlanceColor.bgOverlaySubtle))
                            .overlay(Circle().strokeBorder(GlanceColor.borderSubtle, lineWidth: 1))
                        VStack(alignment: .leading, spacing: Space.xxs) {
                            Text(fact.label)
                                .glanceText(.captionMedium)
                                .foregroundStyle(GlanceColor.textPrimary.opacity(0.4))
                            Text(fact.value)
                                .glanceText(.bodySMedium)
                                .foregroundStyle(GlanceColor.textPrimary)
                        }
                    }
                }
            }
        }
        .padding(gutter)
    }
}

// MARK: - Wear suggestions

struct WearSuggestionSection: View {
    let occasion: WearOccasion
    var onTryOn: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            SectionTitle(title: "Where can you wear this?")

            VStack(alignment: .leading, spacing: 0) {
                Image(occasion.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 170)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: 0x0D0C0C))
                    .overlay(alignment: .topTrailing) {
                        Image("ic-edit")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.white.opacity(0.21)))
                            .padding(Space.lg)
                    }

                VStack(alignment: .leading, spacing: Space.md) {
                    Text(occasion.title)
                        .glanceText(.displayFeature)
                        .foregroundStyle(Color(hex: 0xC4BD8A))
                    Text(occasion.summary)
                        .glanceText(.displayS)
                        .foregroundStyle(GlanceColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, gutter)
                .padding(.top, Space.xl)

                HStack(alignment: .center, spacing: Space.md) {
                    Text(occasion.tip)
                        .glanceText(.captionRegular)
                        .foregroundStyle(GlanceColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 173, alignment: .leading)
                    Spacer(minLength: 0)
                    Button(action: onTryOn) {
                        HStack(spacing: Space.xxs) {
                            Image("ic-tryon-union")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 11, height: 11.36)
                            Text("Try On")
                                .glanceText(.headingS)
                                .foregroundStyle(GlanceColor.textPrimary)
                        }
                        .frame(width: 104, height: 40)
                        .background(Capsule().fill(GlanceColor.bgOverlay))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, gutter)
                .padding(.top, Space.xl)
                .padding(.bottom, gutter)
            }
            .background(Color(hex: 0x575757, opacity: 0.2))
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 10)
                    .blur(radius: 8)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
                    .allowsHitTesting(false)
            }
        }
        .padding(gutter)
    }
}

// MARK: - Also works for

struct AlsoWorksForSection: View {
    let items: [AlsoWorksFor]
    var onTryOn: (AlsoWorksFor) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            SectionTitle(title: "Also works for")
            HStack(spacing: 10) {
                ForEach(items) { item in
                    card(item)
                }
            }
        }
        .padding(gutter)
    }

    private func card(_ item: AlsoWorksFor) -> some View {
        ZStack(alignment: .bottomLeading) {
            Color(hex: 0xA68E70)

            Image(item.image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 320)
                .clipped()

            CardScrim(tint: Color(hex: item.tint))
                .frame(height: 192)
                .frame(maxHeight: .infinity, alignment: .bottom)

            VStack(alignment: .leading, spacing: Space.sm) {
                Text(item.title)
                    .glanceText(.displayS)
                Text(item.detail)
                    .glanceText(.bodyS)
                    .fixedSize(horizontal: false, vertical: true)
                Button { onTryOn(item) } label: {
                    HStack(spacing: 9) {
                        Image("ic-tryon-union")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 11, height: 11.4)
                        Text("Try On")
                            .glanceText(.bodySMedium)
                    }
                    .foregroundStyle(GlanceColor.textPrimary)
                    .frame(height: 30)
                    .padding(.horizontal, Space.lg)
                    .background(Capsule().fill(Color.black.opacity(0.2)))
                }
                .buttonStyle(.plain)
                .padding(.top, Space.xxs)
            }
            .foregroundStyle(GlanceColor.textPrimary)
            .padding(Space.lg)
        }
        .frame(height: 320)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Image("ic-edit")
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color(hex: 0x111111, opacity: 0.6)))
                .padding(10)
        }
        .glanceCardShadow()
    }
}
