import SwiftUI

struct ProductView: View {
    let product: Product

    @Environment(\.dismiss) private var dismiss
    @State private var selectedSize: String
    @State private var selectedColor: UUID?
    @State private var isWishlisted = false
    @State private var imageIndex = 0
    @State private var reviewIndex = 0
    @State private var priceRange: PriceRange = .threeMonths
    @State private var askSheet: AskGlanceContext?

    private let gutter = Space.xl

    init(product: Product) {
        self.product = product
        _selectedSize = State(initialValue: product.sizeGuess.size)
        _selectedColor = State(initialValue: product.colors.first?.id)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ProductGallerySection(
                        product: product,
                        imageIndex: $imageIndex,
                        isWishlisted: $isWishlisted,
                        onTryOn: { ask("Try On", product.name) },
                        onBuy: { ask("Buy on Amazon", product.name) }
                    )

                    section(spacing: Space.sm) {
                        SectionTitle(title: product.matchTitle)
                        Text(product.matchBody)
                            .glanceText(.bodyM)
                            .foregroundStyle(GlanceColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .id(1)

                    ReviewsSection(product: product, reviewIndex: $reviewIndex).id(2)

                    AISummarySection(summary: product.aiSummary).id(3)

                    SizeGuessSection(product: product, selectedSize: $selectedSize).id(4)

                    ColorsSection(product: product, selectedColor: $selectedColor).id(5)

                    PriceTrendSection(product: product, range: $priceRange).id(6)

                    WhyItWorksSection(items: product.whyItWorks).id(7)

                    DeliverySection(delivery: product.delivery).id(8)

                    WearSuggestionSection(occasion: product.occasion) {
                        ask("Try On", product.occasion.title)
                    }
                    .id(9)

                    AlsoWorksForSection(items: product.alsoWorksFor) { item in
                        ask("Try On", item.title)
                    }
                    .id(10)
                }
                // Clear the composer: chips + pill + the gap beneath them.
                .padding(.bottom, AskGlanceBarMetrics.reservedHeight + 56)
            }
            .scrollIndicators(.hidden)
            // Pinned, and the scroll view still draws behind it — so content
            // blurs through the material as it passes underneath.
            .safeAreaInset(edge: .top, spacing: 0) { topBar }
            .task {
                try? await Task.sleep(for: .milliseconds(500))
                if let target = DebugLaunch.scrollTo { proxy.scrollTo(target, anchor: .top) }
            }
            }

            bottomBar
        }
        // The composer is measured from the physical bottom edge, so the stack
        // runs past the home indicator and its blurred band reaches the bottom.
        .ignoresSafeArea(edges: .bottom)
        .background(GlanceColor.bgBase)
        .navigationBarBackButtonHidden()
        // The header rides with the content rather than in `UINavigationBar`.
        // The bar runs its own push animation, which slides its items in from
        // the trailing edge and fights the zoom transition; owning the header
        // means it expands out of the feed card along with everything else.
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $askSheet) { AskGlanceView(context: $0) }
    }

    private var topBar: some View {
        HStack(spacing: 0) {
            BarIconButton(systemName: "arrow.left", label: "Back") { dismiss() }

            Spacer(minLength: 0)

            HStack(spacing: 1) {
                Text("glance")
                    .glanceText(.headingL)
                Image(systemName: "sparkles")
                    .font(.system(size: 11))
            }
            .accessibilityElement()
            .accessibilityLabel("Glance")

            Spacer(minLength: 0)

            BarIconButton(
                systemName: "clock.arrow.circlepath",
                label: "Recently viewed",
                alignment: .trailing
            ) {}
        }
        .foregroundStyle(GlanceColor.textPrimary)
        .padding(.horizontal, Space.lg)
        .fadingBarBackground()
    }

    private func ask(_ title: String, _ prompt: String) {
        askSheet = AskGlanceContext(title: title, prompt: prompt)
    }

    private func section<Content: View>(spacing: CGFloat = Space.md, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: spacing, content: content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(gutter)
    }

    /// The same composer as the home feed, with this screen's suggestion chips
    /// riding above the pill.
    private var bottomBar: some View {
        AskGlanceBar(
            onAsk: { ask("Glance AI", product.name) },
            onAttach: { ask("Add an image", product.name) }
        ) {
            ScrollView(.horizontal) {
                HStack(spacing: Space.sm) {
                    ForEach(product.suggestionChips, id: \.self) { chip in
                        GlanceChip(title: chip) { ask(chip, product.name) }
                    }
                }
                .padding(.horizontal, gutter)
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    NavigationStack {
        ProductView(product: .unifringePolo)
    }
    .preferredColorScheme(.dark)
}
