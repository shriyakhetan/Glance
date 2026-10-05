import PhotosUI
import SwiftUI

struct ProfileView: View {
    private let profile: StyleProfile

    @Environment(\.dismiss) private var dismiss
    /// Regular means the canvas is wider than the arch, which changes how the
    /// hero glow has to be cropped. Slide Over reports compact, and there the
    /// phone treatment is the right one.
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var name: String
    @State private var selectedVibes: Set<UUID> = []
    /// The analysis card whose call to action opened the assistant.
    @State private var chatTopic: ChatTopic?
    @State private var sourceImages: [UUID: Data] = [:]
    /// The tile the `Add Photo` sheet is choosing a source for.
    @State private var sheetTarget: VisualSource?
    @State private var pickerTarget: VisualSource?
    @State private var cameraTarget: VisualSource?
    @State private var photoItem: PhotosPickerItem?
    @FocusState private var nameFocused: Bool
    /// How far the page has scrolled, so the hero's glow can answer to it.
    @State private var scrollOffset: CGFloat = 0

    private let gutter = Space.xl
    /// The comp puts the arch's crown 180pt below the top of the frame.
    private let archTop: CGFloat = 180
    /// Floors the tallest screen the app runs on — an iPad Pro 13" in portrait
    /// is 1376pt, and the arch is clipped, so it has to reach past that or its
    /// cropped bottom edge shows.
    private let archHeight: CGFloat = 1600

    init(repository: ProfileRepository = MockProfileRepository()) {
        let profile = repository.profile()
        self.profile = profile
        _name = State(initialValue: profile.name)
    }

    var body: some View {
        ScrollViewReader { proxy in
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroCard
                    .padding(.horizontal, gutter)
                    .padding(.top, Space.lg)

                PhotoStripSection(
                    sources: profile.sources,
                    imageData: sourceImages,
                    onPick: { openAddPhoto($0) }
                )
                .padding(.horizontal, gutter)
                .padding(.top, 40)
                .id(1)

                editorial
                    .padding(.horizontal, gutter)
                    .padding(.top, 40)
                    .id(2)

                AnalysisSection(cards: profile.analysis, onAsk: openChat)
                    .padding(.top, 40)
                    .id(3)

                TrainingBanner(prompt: profile.training, onStart: openTraining)
                    .padding(.horizontal, gutter)
                    .padding(.top, 40)
                    .id(4)

                SectionLabel(title: "What Glance knows")
                    .padding(.horizontal, gutter)
                    .padding(.top, 40)

                VStack(spacing: 20) {
                    ForEach(Array(profile.dimensions.enumerated()), id: \.element.id) { index, card in
                        DimensionCardView(card: card)
                            .id(5 + index)
                    }
                }
                .padding(.horizontal, gutter)
                .padding(.top, Space.lg)
            }
            .padding(.bottom, 60)
            .glanceContentColumn()
        }
        .task {
            try? await Task.sleep(for: .milliseconds(500))
            if let target = DebugLaunch.scrollTo { proxy.scrollTo(target, anchor: .top) }
            if DebugLaunch.sheet == "addPhoto", let source = profile.sources.first(where: { $0.image == nil }) { openAddPhoto(source) }
            if DebugLaunch.focus == "name" { nameFocused = true }
            if let index = DebugLaunch.chat {
                if profile.analysis.indices.contains(index) { openChat(profile.analysis[index]) } else { openTraining() }
            }
        }
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top
        } action: { _, offset in
            scrollOffset = max(0, offset)
        }
        // Pinned, with content blurring through as it passes underneath.
        .safeAreaInset(edge: .top, spacing: 0) { topBar }
        .background {
            // Above the crown the page is the ordinary base; the arch brings its
            // own slightly violet fill with it.
            //
            // The arch has to be an overlay, not a `ZStack` sibling: a ZStack
            // sizes to its tallest child, so the oversized arch would stretch it
            // and — as a background gets centred in its slot — shove the crown
            // hundreds of points off the top of the screen. An overlay never
            // resizes its host.
            GlanceColor.bgBase
                .overlay(alignment: .top) { arch }
                .ignoresSafeArea()
        }
        // 693:181 — presented by hand so the scrim is the comp's black at 70%.
        .overlay { addPhotoLayer }
        .navigationDestination(item: $chatTopic) { topic in
            GlanceChatView(topic: topic)
        }
        .navigationBarBackButtonHidden()
        // Owned rather than delegated to `UINavigationBar`, so the header
        // expands with the zoom transition instead of sliding in from the right.
        .toolbar(.hidden, for: .navigationBar)
        .photosPicker(isPresented: Binding(get: { pickerTarget != nil }, set: { if !$0 { pickerTarget = nil } }),
                      selection: $photoItem, matching: .images)
        .onChange(of: photoItem) { _, item in
            guard let item, let target = pickerTarget else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    sourceImages[target.id] = data
                }
                pickerTarget = nil
                photoItem = nil
            }
        }
        .fullScreenCover(item: $cameraTarget) { target in
            CameraPicker(
                onCapture: { data in
                    sourceImages[target.id] = data
                    cameraTarget = nil
                },
                onCancel: { cameraTarget = nil }
            )
            .ignoresSafeArea()
        }
    }

    /// The container stays in the hierarchy and its children come and go, so the
    /// sheet's own move transition runs. Inserting the container instead makes
    /// SwiftUI fade the whole layer in, and the slide never plays.
    private var addPhotoLayer: some View {
        ZStack(alignment: .bottom) {
            if sheetTarget != nil {
                Color.black.opacity(0.7)
                    .onTapGesture { closeAddPhoto() }
                    .transition(.opacity)
            }

            if let target = sheetTarget {
                AddPhotoSheet(
                    onCamera: {
                        closeAddPhoto()
                        // No camera in the simulator; the sheet just closes there.
                        if CameraPicker.isAvailable { cameraTarget = target }
                    },
                    onGallery: {
                        closeAddPhoto()
                        pickerTarget = target
                    },
                    onDismiss: { closeAddPhoto() }
                )
                // Anchored to the physical bottom, so it enters from the screen
                // edge rather than from above the home indicator.
                .glanceContentColumn()
                .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(sheetTarget != nil)
    }

    private static let sheetMotion = Animation.spring(response: 0.38, dampingFraction: 0.86)

    private func openAddPhoto(_ source: VisualSource) {
        withAnimation(Self.sheetMotion) { sheetTarget = source }
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

    /// `Start Training` opens the assistant on the first of the four questions;
    /// the rest follow as each is answered.
    private func openTraining() {
        guard let opening = profile.training.opening else { return }
        chatTopic = ChatTopic(
            source: "Training",
            opening: opening.text,
            options: opening.options,
            followUps: profile.training.followUps,
            closing: profile.training.closing
        )
    }

    private func closeAddPhoto() {
        withAnimation(Self.sheetMotion) { sheetTarget = nil }
    }

    /// The hero's lit arch.
    ///
    /// `ArchGlow` is 640pt on purpose: wider than a phone, so its straight
    /// sides fall outside the viewport and only the crown reads. A regular
    /// width is wider than the arch itself, so those sides — and the seam where
    /// the arch's `#0E0A19` fill meets `bgBase` — would be on show. There it is
    /// cropped to the content column and the cut feathered, which is what a
    /// phone gets for free by running the fill past its screen edges.
    @ViewBuilder
    private var arch: some View {
        // Tall enough to floor the visible screen; the comp's full 3020 would
        // only add blur cost off-screen.
        let glow = ArchGlow(scroll: scrollOffset)
            .frame(width: ArchGlow.width, height: archHeight)

        if sizeClass == .regular {
            glow
                .frame(width: GlanceLayout.maxContentWidth)
                .mask(archEdgeFade)
                .offset(y: archTop)
        } else {
            glow.offset(y: archTop)
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

    private var topBar: some View {
        HStack(spacing: 0) {
            BarIconButton(systemName: "chevron.left", label: "Back") { dismiss() }

            Spacer(minLength: 0)

            Text("Style Intelligence Profile")
                .glanceText(.headingL)

            Spacer(minLength: 0)

            // Balances the leading button so the title sits centred.
            Color.clear.frame(width: 44, height: 44)
        }
        .foregroundStyle(GlanceColor.textPrimary)
        .padding(.horizontal, Space.lg)
        // Back button and title line up with the content column; the fading
        // band behind them still runs the full width.
        .glanceContentColumn()
        .fadingBarBackground()
    }

    private var heroCard: some View {
        VStack(spacing: Space.lg) {
            // Figma crops the portrait onto the face inside a 104pt ring.
            Color.clear
                .frame(width: 104, height: 104)
                .overlay(alignment: .topLeading) {
                    Image(profile.avatar)
                        .resizable()
                        .frame(width: 276, height: 287)
                        .offset(x: -90, y: -5)
                }
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.white.opacity(0.14), lineWidth: 2))

            VStack(spacing: Space.sm) {
                nameField

                Text(profile.subtitle)
                    .glanceText(.bodyM)
                    .foregroundStyle(GlanceColor.textDisabled)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                HStack(spacing: Space.md) {
                    HStack(spacing: Space.xxs) {
                        Image("ic-location")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text(profile.location)
                            .glanceText(.bodyM)
                    }
                    Rectangle()
                        .fill(GlanceColor.borderDefault)
                        .frame(width: 1, height: 12)
                    HStack(spacing: Space.xxs) {
                        Image("ic-weather")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text(profile.weather)
                            .glanceText(.bodyM)
                    }
                }
                .foregroundStyle(GlanceColor.textDisabled)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Space.xxl)
        .padding(.vertical, Space.lg)
    }

    /// The field is always present rather than swapped in on tap. Creating the
    /// `TextField` and asking for focus in the same tick drops the request —
    /// the field does not exist yet — so the keyboard never appeared.
    private var nameField: some View {
        ZStack {
            // The prompt is drawn by hand: a `TextField`'s own placeholder
            // renders system grey, and the comp wants full-strength ink in the
            // display serif. Non-interactive so taps reach the field beneath.
            // Shown whenever the field is empty — including while editing, where
            // it drops back to a faint watermark behind the caret. Only real
            // text takes it away, and clearing the field brings it back.
            if name.isEmpty {
                Text(profile.namePlaceholder)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .opacity(nameFocused ? 0.25 : 1)
                    .animation(.easeInOut(duration: 0.2), value: nameFocused)
                    .allowsHitTesting(false)
            }

            TextField("", text: $name)
                .foregroundStyle(GlanceColor.textPrimary)
                .multilineTextAlignment(.center)
                .focused($nameFocused)
                .submitLabel(.done)
                .onSubmit { nameFocused = false }
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                // Full width, so the whole row is a hit target. Centred text in
                // an empty field is otherwise a caret-wide tap area.
                .frame(maxWidth: .infinity)
        }
        .font(.custom(GlanceTypeface.serifBold, size: 28))
        // A 28pt line is a thin thing to hit. The row is padded out to a proper
        // target and made solid, so a tap anywhere across it lands.
        .padding(.vertical, Space.sm)
        .contentShape(Rectangle())
        // Only while empty: once there is text, this would compete with the
        // field's own tap and steal caret placement.
        .onTapGesture { if name.isEmpty { nameFocused = true } }
        .accessibilityLabel("Your name")
    }

    private var editorial: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            VStack(alignment: .leading, spacing: Space.sm) {
                (
                    Text(profile.editorialLead)
                        .font(.custom(GlanceTypeface.serifRegular, size: 20))
                    + Text(profile.editorialEmphasis)
                        .font(.custom(GlanceTypeface.serifBoldItalic, size: 20))
                        .foregroundColor(Color(hex: 0xC2B0FF))
                    + Text(profile.editorialTail)
                        .font(.custom(GlanceTypeface.serifRegular, size: 20))
                )
                .foregroundStyle(GlanceColor.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

                Text(profile.editorialBody)
                    .glanceText(.bodyM)
                    .foregroundStyle(GlanceColor.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VibeChipsView(chips: profile.vibes, selected: $selectedVibes)
        }
    }
}

#Preview {
    NavigationStack { ProfileView() }
        .preferredColorScheme(.dark)
}
