import SwiftUI

struct HomeView: View {
    private let header: HomeHeader
    private let blocks: [FeedBlock]

    @State private var path = NavigationPath()
    @State private var askSheet: AskGlanceContext?
    @State private var contentWidth: CGFloat = 0
    @State private var didOpenDebugRoute = false
    @Namespace private var transition

    /// Read from `GlanceLayout`, which also uses them to work out how many
    /// columns fit and how wide each is — so the spacing drawn here and the
    /// spacing those sums assume can't drift apart. 8 / 189 / 8 / 189 / 8 on a
    /// 402pt phone.
    private let gutter = GlanceLayout.feedGutter
    private let columnGap = GlanceLayout.feedColumnGap

    /// Vertical rhythm between stacked cards. A tailed card is followed by half
    /// the gap: its tail already hangs into the space below the body, so a full
    /// gap reads as a wider break than it does under a flat-bottomed card.
    private let rowGap = GlanceLayout.feedRowGap
    private var rowGapAfterTail: CGFloat { rowGap / 2 }

    /// The greeting keeps its own inset and its own break above the cards; the
    /// tighter spacing is for the mosaic, not the page.
    private let headerInset: CGFloat = Space.xl
    private let headerGap: CGFloat = Space.sm + Space.xl

    /// Where the composer is in the journey. This feed is the onboarded one —
    /// it already reads her style — so it leads with My Looks; `--askStage`
    /// starts it anywhere else.
    @State private var askStage = DebugLaunch.askStage.flatMap(AskGlanceStage.init(debugName:)) ?? .afterOnboarding

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
                        stage: askStage,
                        onAsk: { ask("Glance AI", "Ask me anything about your style.") },
                        onAttach: { ask("Add an image", "Add a photo and I'll read it for style cues.") },
                        onMyLooks: { ask("My Looks", "The looks I've put together for you.") },
                        // Refreshing takes the new looks in; from here on the
                        // composer is the onboarded one.
                        onRefresh: { askStage = .afterOnboarding }
                    )
                }
                // The first looks land when the countdown does.
                .task(id: askStage) {
                    guard case .firstGeneration(let until) = askStage else { return }
                    try? await Task.sleep(for: .seconds(max(0, until.timeIntervalSinceNow)))
                    if !Task.isCancelled { askStage = .feedIsReady }
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
                case .chat(let topic):
                    GlanceChatView(topic: topic)
                case .look(let id):
                    LookDetailView(look: LookRepository.shared.look(id: id))
                        .navigationTransition(.zoom(sourceID: Route.look(id), in: transition))
                case .tip(let card):
                    TipDetailView(tip: card)
                        .navigationTransition(.zoom(sourceID: Route.tip(card), in: transition))
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
                        .padding(.horizontal, headerInset)
                        .padding(.top, Space.xl)
                        .padding(.bottom, headerGap)

                    if columnCount > 2 {
                        masonry
                    } else {
                        authoredRows
                    }
                }
                // Clear the pinned composer; the comp lets the feed run
                // under its graded band.
                .padding(.bottom, AskGlanceBarMetrics.reservedHeight)
                // Measured inside the width cap, not outside it: `columnCount`
                // and `columnWidth` both divide the *content* width, so they
                // have to see the capped grid and not the full screen. This
                // `.background` must stay above the cap for that to hold.
                .background {
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear { contentWidth = geometry.size.width }
                            .onChange(of: geometry.size.width) { _, width in contentWidth = width }
                    }
                }
                // The feed earns more columns as it widens, so it takes the
                // whole canvas rather than the single reading column the
                // article-shaped screens use.
                .glanceContentColumn(GlanceLayout.maxFeedWidth)
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
                if DebugLaunch.route == "look" { path.append(Route.look(LookDetail.airport.id)) }
                if DebugLaunch.route == "tip", let tip = firstTip { path.append(Route.tip(tip)) }
            }
        }
        .scrollIndicators(.hidden)
        // Edge to edge: only the content is columned, never the canvas.
        .background(GlanceColor.bgBase)
    }

    /// The comp's arrangement: hand-paired columns with wide cards breaking
    /// between them. What a phone gets.
    private var authoredRows: some View {
        let rows = FeedLayout.rows(for: blocks)

        return ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
            Group {
                switch row {
                case .flow(let flow):
                    HStack(alignment: .top, spacing: columnGap) {
                        ForEach(Array(flow.columns.enumerated()), id: \.offset) { _, items in
                            column(items)
                        }
                    }
                case .wide(let item):
                    view(for: item)
                }
            }
            .padding(.horizontal, gutter)
            .padding(.bottom, index == rows.count - 1 ? 0 : gap(after: row))
            .id(index)
        }
    }

    /// Wider canvases: one continuous masonry, measured rather than paired, with
    /// the wide cards spanning two columns instead of breaking the flow.
    private var masonry: some View {
        let items = FeedLayout.items(for: blocks)

        return FeedMasonry(columns: columnCount, spacing: columnGap) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                view(for: item)
                    .feedSpan(item.keepsPhoneWidth ? bigLookSpan : item.isWide ? wideSpan : 1)
                    .feedGapBelow(gap(after: item))
                    .id(index)
            }
        }
        .padding(.horizontal, gutter)
    }

    private func ask(_ title: String, _ prompt: String) {
        askSheet = AskGlanceContext(title: title, prompt: prompt)
    }

    /// The feed's first tip, for `--route tip`.
    private var firstTip: TipCard? {
        for item in FeedLayout.items(for: blocks) {
            if case .tip(let tip) = item { return tip }
        }
        return nil
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

    /// Two on a phone, as the comp draws it, rising as the canvas widens.
    private var columnCount: Int {
        GlanceLayout.feedColumnCount(for: contentWidth)
    }

    /// How many columns a trend or routine card takes. Once the columns are
    /// wide enough on their own it stays in one, which keeps the masonry from
    /// stranding space above it.
    private var wideSpan: Int {
        guard let columnWidth else { return 2 }
        return GlanceLayout.wideCardSpan(columnWidth: columnWidth, count: columnCount)
    }

    /// How many columns the big look card takes on a wide canvas.
    private var bigLookSpan: Int {
        guard let columnWidth else { return 1 }
        return GlanceLayout.bigCardSpan(columnWidth: columnWidth, count: columnCount)
    }

    /// Every column is pinned to an equal, measured width. Left to its own
    /// devices an `HStack` hands extra room to whichever column holds the
    /// longest unbreakable word, which pushes the others off-balance.
    private var columnWidth: CGFloat? {
        guard contentWidth > 0 else { return nil }
        return GlanceLayout.feedColumnWidth(for: contentWidth, count: columnCount)
    }

    private func column(_ items: [FeedItem]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                view(for: item)
                    // Every card takes its own height. Offered a fixed one, a
                    // card whose photo is an aspect-fit box shrinks the photo
                    // to fit what's left after its text, leaving it narrower
                    // than the card with the tint showing down one side.
                    .fixedSize(horizontal: false, vertical: true)
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

    /// A wide row inherits its card's gap; a flowing run keeps the standard
    /// one, since its columns rarely end on the same kind of card.
    private func gap(after row: FeedRow) -> CGFloat {
        if case .wide(let item) = row { return gap(after: item) }
        return rowGap
    }

    @ViewBuilder
    private func view(for item: FeedItem) -> some View {
        switch item {
        case .look(let card):
            if let detailID = card.detailID {
                // The card zooms up into the look's page; its thumbs and
                // heart are buttons of their own and keep working in place.
                Button { path.append(Route.look(detailID)) } label: {
                    LookCardView(card: card) {
                        ask("Give feedback", "What didn't work for you about this look?")
                    }
                }
                .buttonStyle(FeedCardButtonStyle())
                .matchedTransitionSource(id: Route.look(detailID), in: transition)
            } else {
                LookCardView(card: card) {
                    ask("Give feedback", "What didn't work for you about this look?")
                }
            }
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
            // The card opens the tip's page, which it zooms up into; its
            // button goes where it says — an explanation, or the products.
            Button { path.append(Route.tip(card)) } label: {
                TipCardView(card: card) {
                    switch card.action {
                    case .explain: path.append(Route.chat(card.explanation))
                    case .shop: path.append(Route.tip(card))
                    }
                }
            }
            .buttonStyle(FeedCardButtonStyle())
            .matchedTransitionSource(id: Route.tip(card), in: transition)
        case .prompt(let card):
            PromptCardView(card: card) {
                path.append(Route.chat(card.chat))
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
            SignalCardView(card: card) { answer in
                path.append(Route.chat(card.chatTopic(answering: answer)))
            }
        case .poster(let card):
            PosterCardView(card: card) {
                ask("Glance AI", card.prompt)
            }
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
    /// The assistant (731:701), opened already talking about something.
    case chat(ChatTopic)
    /// A look's own page (6215:7530).
    case look(String)
    /// A tip's own page (4201:5148).
    case tip(TipCard)
}

#Preview {
    HomeView()
}
