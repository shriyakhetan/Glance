import SwiftUI

/// A tip's own page (`Skin Tip`, 4201:5148): the tip as it was in the feed —
/// it zooms up out of its card — then what Glance suggests buying for it,
/// and the composer in its `on L2` state with the tip's own replies.
struct TipDetailView: View {
    let tip: TipCard

    @Environment(\.dismiss) private var dismiss
    @State private var askSheet: AskGlanceContext?
    @State private var chatTopic: ChatTopic?

    private static let suggestionsAnchor = "suggestions"

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: Space.xl) {
                        // The comp's 194pt card, as it sits in a column. Here its
                        // button explains the tip, or brings its products up.
                        TipCardView(card: tip) {
                            switch tip.action {
                            case .explain:
                                chatTopic = tip.explanation
                            case .shop:
                                withAnimation(.smooth) { proxy.scrollTo(Self.suggestionsAnchor, anchor: .top) }
                            }
                        }
                        .frame(width: 194)

                        if !tip.suggestions.isEmpty {
                            ShopProductList(title: "Suggested Products", products: tip.suggestions) { product in
                                ask("\(product.brand) \(product.name)", tip.headline)
                            }
                            .id(Self.suggestionsAnchor)
                        }
                    }
                    .padding(.horizontal, Space.lg)
                    .padding(.top, Space.xl)
                    // Clear the chips, the pill and the gap beneath them.
                    .padding(.bottom, AskGlanceBarMetrics.reservedHeightWithChips + Space.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glanceContentColumn()
                }
                .scrollIndicators(.hidden)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                GlanceLogoBar(onBack: { dismiss() })
            }

            AskGlanceBar(
                stage: .onL2,
                onAsk: { ask("Glance AI", tip.headline) },
                onAttach: { ask("Add an image", tip.headline) }
            ) {
                AskGlanceChips(titles: tip.chips) { ask($0, tip.headline) }
            }
        }
        // The composer is measured from the physical bottom edge.
        .ignoresSafeArea(edges: .bottom)
        .background(.black)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $askSheet) { AskGlanceView(context: $0) }
        .navigationDestination(item: $chatTopic) { GlanceChatView(topic: $0) }
    }

    private func ask(_ title: String, _ prompt: String) {
        askSheet = AskGlanceContext(title: title, prompt: prompt)
    }
}
