import SwiftUI

/// `Signal Card` (2831:1117) — the one card in the feed that asks rather than
/// tells. Two faces on one card: the question with its answers
/// (`State=Question`, 2831:1116) and, once one is picked and has lit up white
/// for a beat, an invitation to keep going (`State=Start Chat`, 2831:1118).
struct SignalCardView: View {
    let card: SignalCard
    /// `Start Chat`, with the answer she gave.
    var onStartChat: (String) -> Void = { _ in }

    @State private var answer: String?
    @State private var isInviting: Bool
    /// Off only in the variant gallery, to hold a card on its lit answer.
    private let turnsOver: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Starts the card on a given face — for the variant gallery.
    init(
        card: SignalCard,
        answer: String? = nil,
        isInviting: Bool = false,
        turnsOver: Bool = true,
        onStartChat: @escaping (String) -> Void = { _ in }
    ) {
        self.card = card
        self.turnsOver = turnsOver
        self.onStartChat = onStartChat
        _answer = State(initialValue: answer)
        _isInviting = State(initialValue: isInviting && answer != nil)
    }

    private static let cornerRadius: CGFloat = Radius.xl
    /// The comp's two glow discs, 170pt across.
    private static let glowDiameter: CGFloat = 170
    /// The comp's 170×300, scaled to the column. A floor, not a cap: a long
    /// question grows the card rather than clipping.
    private static let restingAspect: CGFloat = 170.0 / 300.0
    /// How long the picked answer stays lit before the card turns over.
    private static let holdBeforeTurning: Duration = .milliseconds(650)
    private static let pill = RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Spacer(minLength: Space.xl)
            faces
        }
        .padding(.horizontal, 19)
        .padding(.vertical, 23)
        .frame(maxWidth: .infinity, alignment: .leading)
        .aspectRatio(Self.restingAspect, contentMode: .fit)
        .background { surface }
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                .strokeBorder(GlanceColor.outlineVariant, lineWidth: 1)
        }
        .sensoryFeedback(.selection, trigger: answer)
        // The pick lights up, holds, then the card turns to its second face.
        .task(id: answer) {
            guard turnsOver, answer != nil, !isInviting else { return }
            try? await Task.sleep(for: Self.holdBeforeTurning)
            guard !Task.isCancelled else { return }
            withAnimation(.smooth(duration: 0.5)) { isInviting = true }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: Space.sm) {
            CroppedImage(name: card.avatar, crop: ImageCrop(width: 276, height: 287, x: -90, y: -5, reference: 104))
                .frame(width: 24, height: 24)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(GlanceColor.accentSecondary, lineWidth: 1))
                // `shadow(0 0 20px rgba(118,90,234,0.6))` — SwiftUI's radius is
                // half the CSS blur.
                .shadow(color: Color(hex: 0x765AEA, opacity: 0.6), radius: 10)

            Text(card.label, style: .labelBrand)
                .glanceText(.labelBrand)
                .foregroundStyle(GlanceColor.accentSecondary)
        }
    }

    // MARK: - Faces

    /// Both faces stay in the layout, the one turned away invisible, so the
    /// card is sized for the taller and keeps its height as it turns over —
    /// the cards stacked under it in the column stay where they are. Each is
    /// pinned to the foot of the card, as the comp anchors them.
    private var faces: some View {
        ZStack(alignment: .bottomLeading) {
            asking
                .face(shown: !isInviting, blurs: !reduceMotion)
            inviting
                .face(shown: isInviting, blurs: !reduceMotion)
        }
    }

    /// `State=Question` — the question over its answers.
    private var asking: some View {
        VStack(alignment: .leading, spacing: 20) {
            questionText(card.question)
            VStack(spacing: 10) {
                ForEach(card.options, id: \.self) { option in
                    answerButton(option)
                }
            }
        }
    }

    /// `State=Start Chat` — the invitation, and the way in.
    private var inviting: some View {
        VStack(alignment: .leading, spacing: 20) {
            questionText(card.invitation)
            Button {
                if let answer { onStartChat(answer) }
            } label: {
                HStack(spacing: Space.sm) {
                    Text(card.invitationAction)
                        .glanceText(.labelMedium)
                        .foregroundStyle(GlanceColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image("ic-arrow-forward")
                        .resizable()
                        .frame(width: 8, height: 7)
                        .frame(width: 12, height: 12)
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, Space.lg)
                .padding(.vertical, Space.sm)
                .secondaryGlass(in: Self.pill)
                .contentShape(Self.pill)
            }
            .buttonStyle(.plain)
        }
    }

    private func questionText(_ text: String) -> some View {
        Text(text)
            .glanceText(.displaySmall)
            .foregroundStyle(GlanceColor.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// `CTA (New Project)` (2831:1100) — a full-width pill on the secondary
    /// glass. Picked, it lights up white with dark ink.
    ///
    /// A 24pt corner rather than a capsule, as the comp has it: a long answer
    /// wraps to a second line, and a capsule would round that into a stadium.
    private func answerButton(_ option: String) -> some View {
        let isPicked = answer == option

        return Button {
            // One answer per card; the rest stop listening once it is given.
            guard answer == nil else { return }
            withAnimation(.easeOut(duration: 0.2)) { answer = option }
        } label: {
            Text(option)
                .glanceText(.labelMedium)
                .foregroundStyle(isPicked ? GlanceColor.textInverse : GlanceColor.textPrimary)
                // Wraps instead of truncating; a button label in a lazy stack
                // otherwise takes one line and cuts the rest off.
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Space.lg)
                .padding(.vertical, Space.sm)
                // Under the label, over the glass.
                .background {
                    Self.pill
                        .fill(Color.white)
                        .opacity(isPicked ? 1 : 0)
                }
                .secondaryGlass(in: Self.pill)
                .contentShape(Self.pill)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isPicked ? .isSelected : [])
    }

    // MARK: - Surface

    /// Black at 60% with a soft inner glow, lit by two faint discs: one
    /// centred on the top edge, one on the bottom-right corner (2831:1119,
    /// 2831:1120).
    private var surface: some View {
        let shape = RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
        return shape
            .fill(Color.black.opacity(0.6))
            .overlay(alignment: .top) {
                glow.offset(x: -1, y: -Self.glowDiameter / 2)
            }
            .overlay(alignment: .bottomTrailing) {
                glow.offset(x: Self.glowDiameter / 2 - 1, y: Self.glowDiameter / 2)
            }
            // `Inner Glow/Soft` — 20pt of white at 15% inside the edge.
            .innerGlow(shape, radius: 20, color: Color.white.opacity(0.15))
    }

    /// The exported ellipse is a pure radial gradient — white at the centre to
    /// clear at the rim, drawn at 20% — so it is reproduced exactly here rather
    /// than shipped as an SVG gradient.
    private var glow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [.white, .white.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: Self.glowDiameter / 2
                )
            )
            .opacity(0.2)
            .frame(width: Self.glowDiameter, height: Self.glowDiameter)
            .allowsHitTesting(false)
    }
}

private extension View {
    /// One face of the card. Turned away, it is invisible and out of reach of
    /// taps and VoiceOver, but keeps its place in the layout. The turn is a
    /// blur-and-fade, the way iOS swaps content in place.
    func face(shown: Bool, blurs: Bool) -> some View {
        self
            .opacity(shown ? 1 : 0)
            .blur(radius: shown || !blurs ? 0 : 6)
            .allowsHitTesting(shown)
            .accessibilityHidden(!shown)
    }
}

// MARK: - Variants

/// Both faces of the `Signal Card` set (2831:1117), plus the beat between:
/// the question, the answer lit up, and the invitation.
struct SignalCardGallery: View {
    private let card = SignalCard(
        avatar: "profile-hero",
        question: "Do you keep a phone for three years or more?",
        options: ["Yes", "No"]
    )

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 165), spacing: Space.xl, alignment: .top)], spacing: Space.xl) {
                variant("question") { SignalCardView(card: card) }
                variant("answer picked") { SignalCardView(card: card, answer: "Yes", turnsOver: false) }
                variant("start chat") { SignalCardView(card: card, answer: "Yes", isInviting: true) }
            }
            .padding(Space.xl)
        }
        .background(GlanceColor.bgBase)
    }

    private func variant<Content: View>(_ name: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            Text(name, style: .labelSection)
                .glanceText(.labelSection)
                .foregroundStyle(GlanceColor.textMuted)
            content()
        }
    }
}

#Preview("Signal Card variants") {
    SignalCardGallery()
        .preferredColorScheme(.dark)
}
