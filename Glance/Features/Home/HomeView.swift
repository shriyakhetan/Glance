import SwiftUI

struct HomeView: View {
    private let header: HomeHeader
    private let blocks: [FeedBlock]

    @State private var path = NavigationPath()
    @State private var askSheet: AskGlanceContext?
    @State private var contentWidth: CGFloat = 0
    @State private var didOpenDebugRoute = false
    @Namespace private var transition

    /// 24pt between the two columns, matching the vertical rhythm, with 16pt
    /// side gutters. The redrawn feed (28037:12124) is laid out on a 412pt frame
    /// as 24 / 170 / 24 / 170 / 24, so both the gutter and the column gap are 24
    /// and the columns take whatever is left — 165pt on a 402pt screen.
    private let gutter: CGFloat = Space.xl
    private let columnGap: CGFloat = Space.xl

    /// Vertical rhythm between stacked cards. A tailed card is followed by half
    /// the gap: its tail already hangs into the space below the body, so a full
    /// 24pt reads as a wider break than it does under a flat-bottomed card.
    private let rowGap: CGFloat = Space.xl
    private let rowGapAfterTail: CGFloat = Space.md

    init(repository: FeedRepository = MockFeedRepository()) {
        self.header = repository.header()
        self.blocks = repository.blocks()
    }

    var body: some View {
        NavigationStack(path: $path) {
            // Pinned to the feed only — it lives inside the stack's root, so it
            // does not hang over the pushed product or profile screens.
            feed
                .overlay(alignment: .bottom) {
                    AskGlanceBar(
                        onAsk: { ask("Glance AI", "Ask me anything about your style.") },
                        onAttach: { ask("Add an image", "Add a photo and I'll read it for style cues.") }
                    )
                }
                // The bar is measured from the physical bottom edge, so both the
                // feed and its overlay run past the home indicator. The feed's
                // own bottom padding is what keeps the last card clear.
                .ignoresSafeArea(edges: .bottom)
                .navigationDestination(for: Route.self) { route in
                switch route {
                case .profile:
                    ProfileView()
                        .navigationTransition(.zoom(sourceID: Route.profile, in: transition))
                case .product(let id):
                    ProductView(product: ProductRepository.shared.product(id: id))
                        .navigationTransition(.zoom(sourceID: Route.product(id), in: transition))
                }
            }
        }
        .tint(GlanceColor.accentPrimary)
        .sheet(item: $askSheet) { context in
            AskGlanceView(context: context)
        }
    }

    /// The scrolling masonry feed, without the pinned composer.
    private var feed: some View {
        ScrollViewReader { proxy in
            ScrollView {
                // Gaps are applied per card rather than as uniform stack
                // spacing, so a tailed card can tighten the one below it.
                LazyVStack(alignment: .leading, spacing: 0) {
                    headerView
                        .padding(.horizontal, gutter)
                        .padding(.top, Space.xl)
                        .padding(.bottom, Space.sm + rowGap)

                    ForEach(Array(blocks.enumerated()), id: \.element.id) { index, block in
                        Group {
                            switch block {
                            case .columns(let left, let right):
                                HStack(alignment: .top, spacing: columnGap) {
                                    column(left)
                                    column(right)
                                }
                            case .wide(let item):
                                view(for: item)
                            }
                        }
                        .padding(.horizontal, gutter)
                        .padding(.bottom, index == blocks.count - 1 ? 0 : gap(after: block))
                        .id(index)
                    }
                }
                // Clear the pinned composer; the comp lets the feed run
                // under its graded band.
                .padding(.bottom, AskGlanceBarMetrics.reservedHeight)
            }
            .task {
                // The lazy stack needs a beat to realise its children first.
                try? await Task.sleep(for: .milliseconds(400))
                if let target = DebugLaunch.scrollTo { proxy.scrollTo(target, anchor: .top) }
                // Only once: this task re-runs whenever Home reappears, so
                // without the guard, popping back re-pushes the route and
                // the screen looks like it refuses to dismiss.
                guard !didOpenDebugRoute else { return }
                didOpenDebugRoute = true
                if DebugLaunch.route == "profile" { path.append(Route.profile) }
                if DebugLaunch.route == "product" { path.append(Route.product(Product.unifringePolo.id)) }
            }
        }
        .scrollIndicators(.hidden)
        .background {
            GeometryReader { geometry in
                GlanceColor.bgBase
                    .onAppear { contentWidth = geometry.size.width }
                    .onChange(of: geometry.size.width) { _, width in contentWidth = width }
            }
        }
    }

    private func ask(_ title: String, _ prompt: String) {
        askSheet = AskGlanceContext(title: title, prompt: prompt)
    }

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: Space.sm) {
                Text(header.greeting)
                    .glanceText(.headingXL)
                    .foregroundStyle(GlanceColor.textPrimary)
                Text(header.subtitle)
                    .glanceText(.bodyM)
                    .foregroundStyle(GlanceColor.textTertiary)
            }
            Spacer(minLength: Space.lg)
            Button {
                path.append(Route.profile)
            } label: {
                // Figma frames the avatar on the face: the source is laid in at
                // 106.1×110.4 and pushed left, then clipped to a 40pt circle.
                Color.clear
                    .frame(width: 40, height: 40)
                    .overlay(alignment: .topLeading) {
                        Image(header.avatar)
                            .resizable()
                            .frame(width: 106.127, height: 110.385)
                            .offset(x: -34.62, y: -1.92)
                    }
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.14), lineWidth: 0.77))
            }
            .buttonStyle(.plain)
            .matchedTransitionSource(id: Route.profile, in: transition)
            .accessibilityLabel("Style Intelligence Profile")
        }
    }

    /// Both columns are pinned to an equal, measured width. Left to its own
    /// devices an `HStack` hands extra room to whichever column holds the
    /// longest unbreakable word, which pushes the other one off-balance.
    private var columnWidth: CGFloat? {
        guard contentWidth > 0 else { return nil }
        return (contentWidth - gutter * 2 - columnGap) / 2
    }

    private func column(_ items: [FeedItem]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                view(for: item)
                    .padding(.bottom, index == items.count - 1 ? 0 : gap(after: item))
            }
        }
        .frame(width: columnWidth)
        .frame(maxWidth: columnWidth == nil ? .infinity : nil, alignment: .top)
    }

    /// 24pt between cards, halved to 12pt below anything with a bubble tail.
    private func gap(after item: FeedItem) -> CGFloat {
        item.hasTail ? rowGapAfterTail : rowGap
    }

    /// A full-width block inherits its card's gap; a two-column run keeps the
    /// standard one, since its two columns rarely end on the same kind of card.
    private func gap(after block: FeedBlock) -> CGFloat {
        if case .wide(let item) = block { return gap(after: item) }
        return rowGap
    }

    @ViewBuilder
    private func view(for item: FeedItem) -> some View {
        switch item {
        case .look(let card):
            LookCardView(card: card)
        case .rational(let card):
            if let productID = card.productID {
                Button { path.append(Route.product(productID)) } label: {
                    RationalCardView(card: card)
                }
                .buttonStyle(FeedCardButtonStyle())
                .matchedTransitionSource(id: Route.product(productID), in: transition)
            } else {
                RationalCardView(card: card)
            }
        case .tip(let card):
            TipCardView(card: card)
        case .prompt(let card):
            PromptCardView(card: card) {
                ask("Glance AI", card.text)
            }
        case .brand(let card):
            BrandCardView(card: card)
        case .trend(let card):
            TrendCardView(
                card: card,
                onTryLooks: { ask("Try these looks", card.headline) },
                onFindOutfits: { ask("Find similar outfits", card.headline) },
                onAsk: { ask("Glance AI", card.headline) }
            )
        case .routine(let card):
            RoutineCardView(card: card)
        case .signal(let card):
            SignalCardView(card: card)
        }
    }
}

/// Cards should dip slightly on press without picking up a tint.
struct FeedCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

enum Route: Hashable {
    case profile
    case product(String)
}

#Preview {
    HomeView()
}
