import SwiftUI

/// `D0- Profile` (Surface Art Design Library, 2490:1619) — what Glance has read
/// about her, from a first photo and her browsing.
struct ProfileView: View {
    private let profile: StyleProfile

    @Environment(\.dismiss) private var dismiss
    /// Regular means the canvas is wider than the arch, which changes how the
    /// hero glow has to be cropped. Slide Over reports compact, and there the
    /// phone treatment is the right one.
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selectedVibes: Set<UUID> = []
    /// The analysis card whose call to action opened the assistant.
    @State private var chatTopic: ChatTopic?
    /// How far the page has scrolled, so the hero's glow can answer to it.
    @State private var scrollOffset: CGFloat = 0

    private let gutter = Space.xl
    private let avatarSide: CGFloat = 104

    init(repository: ProfileRepository = MockProfileRepository()) {
        profile = repository.profile()
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                // The comp stacks its sections 40pt apart; the analysis row sets
                // its own gutter so its cards can run off the trailing edge.
                VStack(alignment: .leading, spacing: 40) {
                    hero
                        .id(0)

                    editorial
                        .padding(.horizontal, gutter)
                        .id(1)

                    AnalysisSection(cards: profile.analysis, onAsk: openChat)
                        .id(2)

                    knows
                        .padding(.horizontal, gutter)
                }
                .padding(.top, Space.lg)
                .padding(.bottom, 60)
                .glanceContentColumn()
            }
            .task {
                try? await Task.sleep(for: .milliseconds(500))
                if let target = DebugLaunch.scrollTo { proxy.scrollTo(target, anchor: .top) }
                if let index = DebugLaunch.chat, profile.analysis.indices.contains(index) {
                    openChat(profile.analysis[index])
                }
            }
        }
        .scrollIndicators(.hidden)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top
        } action: { _, offset in
            scrollOffset = max(0, offset)
        }
        // Pinned, with content blurring through as it passes underneath.
        .safeAreaInset(edge: .top, spacing: 0) { topBar }
        .background(.black)
        .navigationDestination(item: $chatTopic) { topic in
            GlanceChatView(topic: topic)
        }
        .navigationBarBackButtonHidden()
        // Owned rather than delegated to `UINavigationBar`, so the header
        // expands with the zoom transition instead of sliding in from the right.
        .toolbar(.hidden, for: .navigationBar)
    }

    /// Opens the assistant already talking about that reading, rather than on a
    /// blank greeting.
    private func openChat(_ card: AnalysisCard) {
        chatTopic = ChatTopic(
            source: card.title,
            opening: card.chatOpening,
            options: card.chatOptions
        )
    }

    /// The hero's lit arch.
    ///
    /// `ArchGlow` is 640pt on purpose: wider than a phone, so its straight
    /// sides fall outside the viewport and only the crown reads. A regular
    /// width is wider than the arch itself, so its sides would be on show.
    /// There it is cropped to the content column and the cut feathered, which
    /// is what a phone gets for free by running the arch past its screen edges.
    @ViewBuilder
    private var arch: some View {
        let glow = ArchGlow(scroll: scrollOffset)
            .frame(width: ArchGlow.width, height: ArchGlow.height)

        if sizeClass == .regular {
            glow
                .frame(width: GlanceLayout.maxContentWidth)
                .mask(archEdgeFade)
        } else {
            glow
        }
    }

    /// Opaque across the column, dissolving over the last 40pt either side.
    private var archEdgeFade: some View {
        let fade = 40 / GlanceLayout.maxContentWidth
        return LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: fade),
                .init(color: .black, location: 1 - fade),
                .init(color: .clear, location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Back on glass, as an iOS 26 bar draws its buttons, with the title
    /// centred between it and a matching spacer.
    private var topBar: some View {
        HStack(spacing: 0) {
            BarIconButton(icon: "ic-nav-back", size: CGSize(width: 15.5, height: 13.5), label: "Back") { dismiss() }

            Spacer(minLength: 0)

            Text("Style Intelligence Profile")
                .glanceText(.headlineS)
                .foregroundStyle(GlanceColor.textPrimary)
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)

            // Balances the leading button so the title sits centred.
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 14.4)
        .padding(.vertical, Space.xxs)
        // Back button and title line up with the content column; the fading
        // band behind them still runs the full width.
        .glanceContentColumn()
        .fadingBarBackground()
    }

    /// `Hero` (2490:1640) — her photo inside a lit ring, and where and when
    /// Glance is reading her.
    private var hero: some View {
        VStack(spacing: Space.lg) {
            // Figma crops the portrait onto the face inside a 104pt ring.
            Color.clear
                .frame(width: avatarSide, height: avatarSide)
                .overlay(alignment: .topLeading) {
                    Image(profile.avatar)
                        .resizable()
                        .frame(width: 276, height: 287)
                        .offset(x: -90, y: -5)
                }
                .clipShape(Circle())
                .innerGlow(Circle(), radius: 34, color: Color.white.opacity(0.17))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.08), lineWidth: 2))
                .accessibilityHidden(true)

            VStack(spacing: Space.sm) {
                Text(profile.subtitle)
                    .glanceText(.bodyMedium)
                    .foregroundStyle(GlanceColor.textSecondary)
                    .multilineTextAlignment(.center)

                // The comp parts these with a 12pt line between 12pt gaps, but
                // the line carries no stroke — only its spacing shows.
                HStack(spacing: Space.xl) {
                    heroFact(icon: "ic-location", text: profile.location)
                    heroFact(icon: "ic-weather", text: profile.weather)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Space.xxl)
        .padding(.vertical, Space.lg)
        // The comp hangs the crown on the avatar's centre line (the glow at
        // y 180, the avatar spanning 128…232). Riding in the hero, it scrolls
        // with her photo. Left pinned behind the page, it stayed put while
        // the copy slid over it.
        .background(alignment: .top) {
            arch.offset(y: Space.lg + avatarSide / 2)
        }
    }

    private func heroFact(icon: String, text: String) -> some View {
        HStack(spacing: Space.xxs) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .accessibilityHidden(true)
            Text(text)
                .glanceText(.labelLarge)
                .foregroundStyle(GlanceColor.textSecondary)
        }
    }

    /// `Header` + `vibe-chips` (2490:1655) — the read in the editorial voice,
    /// then the aesthetics it found.
    private var editorial: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            VStack(alignment: .leading, spacing: Space.sm) {
                // One `Text`, so the italic wraps with the line around it.
                let emphasis = Text(profile.editorialEmphasis)
                    .font(.custom(GlanceTypeface.playfairItalic, size: GlanceTextStyle.displayMedium.size))
                    .foregroundStyle(GlanceColor.accentSecondary)
                Text("\(profile.editorialLead)\(emphasis)\(profile.editorialTail)")
                    .glanceText(.displayMedium)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                Text(profile.editorialBody)
                    .glanceText(.bodyMedium)
                    .foregroundStyle(GlanceColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VibeChipsView(chips: profile.vibes, selected: $selectedVibes)
        }
    }

    /// `What Glance Knows` (2490:1756) — one card per area it has read.
    private var knows: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            SectionTitle(title: "What Glance Knows")

            VStack(spacing: Space.xl) {
                ForEach(Array(profile.dimensions.enumerated()), id: \.element.id) { index, card in
                    DimensionCardView(card: card)
                        .id(3 + index)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { ProfileView() }
        .preferredColorScheme(.dark)
}
