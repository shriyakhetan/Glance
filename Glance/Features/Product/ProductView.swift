import SwiftUI

/// The product page — `T-Shirt Product - L2 - New 01` (V7, 32:2523).
struct ProductView: View {
    let product: Product

    @Environment(\.dismiss) private var dismiss
    @State private var isWishlisted = false
    /// Nothing is picked until she picks it; the recommendation says which.
    @State private var selectedSize: String?
    @State private var selectedColor: UUID?
    @State private var askSheet: AskGlanceContext?

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                ScrollView {
                    // The comp spaces its sections 40pt apart; each sets its own
                    // 24pt gutter, so the gallery can run to the edge.
                    VStack(alignment: .leading, spacing: 40) {
                        ProductHeroSection(
                            product: product,
                            isWishlisted: $isWishlisted,
                            onBuy: { ask("Buy on Amazon", product.name) },
                            onStyleMe: { ask("Style me", product.name) }
                        )
                        .id(0)

                        ProductMatchSection(match: product.match).id(1)

                        SizeSection(
                            guess: product.sizeGuess,
                            sizes: product.availableSizes,
                            selected: $selectedSize,
                            onSizeChart: { ask("Size chart", product.name) },
                            onUpdateSize: { ask("Update size", product.name) }
                        )
                        .id(2)

                        ColourSection(colors: product.colors, more: product.moreColors, selected: $selectedColor).id(3)

                        PriceTrendSection(trend: product.priceTrend) {
                            ask(product.priceTrend.buyLabel, product.name)
                        }
                        .id(4)

                        DeliverySection(delivery: product.delivery).id(5)

                        FitQuestionCard(question: product.fitQuestion).id(6)

                        WearBoardsSection(
                            outfits: product.outfits,
                            onStyle: { ask("Style me", $0.title) },
                            onSwap: { ask("Swap a piece", $0.title) },
                            onAdd: { ask("Add a piece", $0.title) }
                        )
                        .id(7)

                        MoreLikeThisSection(
                            items: product.moreLikeThis,
                            onSelect: { ask($0.title, $0.brand ?? product.name) },
                            onFindSimilar: { ask("Find similar", product.name) }
                        )
                        .id(8)
                    }
                    .padding(.top, Space.xl)
                    // Clear the composer: chips, pill and the gap beneath them.
                    .padding(.bottom, AskGlanceBarMetrics.reservedHeightWithChips + Space.lg)
                    .glanceContentColumn()
                }
                .scrollIndicators(.hidden)
                // Pinned, and the scroll view still draws behind it — so content
                // blurs through as it passes underneath.
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

    /// `Top` (32:3699) — back, the wordmark, recently viewed.
    private var topBar: some View {
        GlanceLogoBar(onBack: { dismiss() })
    }


    /// The composer in its `on L2` state: this product's prompts ride above the
    /// pill as glass chips.
    private var bottomBar: some View {
        AskGlanceBar(
            stage: .onL2,
            onAsk: { ask("Glance AI", product.name) },
            onAttach: { ask("Add an image", product.name) }
        ) {
            AskGlanceChips(titles: product.suggestionChips) { ask($0, product.name) }
        }
    }

    private func ask(_ title: String, _ prompt: String) {
        askSheet = AskGlanceContext(title: title, prompt: prompt)
    }
}

#Preview {
    NavigationStack {
        ProductView(product: .unifringePolo)
    }
    .preferredColorScheme(.dark)
}
