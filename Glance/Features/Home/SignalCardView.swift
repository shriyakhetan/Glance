import SwiftUI

/// `Signal Card` (V7, 2:773) — the one card in the feed that asks rather than
/// tells. It carries its own three states: the question with its answers, the
/// answer as the viewer gave it, and Glance's acknowledgement.
struct SignalCardView: View {
    let card: SignalCard

    @State private var answer: String?

    /// V7 `Display/Small` is Playfair Display, which the app doesn't bundle;
    /// it takes the app's editorial serif at the comp's 18/22.
    private static let question = GlanceTextStyle(GlanceTypeface.serifRegular, 18, lineHeight: 22)
    private static let cornerRadius: CGFloat = Radius.xl
    /// The comp's two glow discs, 170pt across.
    private static let glowDiameter: CGFloat = 170

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            // The comp sets the question 48pt below the header (2:780).
            Group {
                if let answer {
                    answered(answer)
                } else {
                    asking
                }
            }
            .padding(.top, 48)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 19)
        .padding(.top, 23)
        .padding(.bottom, 29)
        .background { surface }
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                .strokeBorder(GlanceColor.outlineVariant, lineWidth: 1)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: answer)
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

    // MARK: - States

    private var asking: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(card.question)
                .glanceText(Self.question)
                .foregroundStyle(GlanceColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ForEach(card.options, id: \.self) { option in
                    optionRow(option)
                }
            }
        }
    }

    /// The answer, then what Glance took from it.
    private func answered(_ answer: String) -> some View {
        VStack(alignment: .leading, spacing: Space.md) {
            Text(answer)
                .glanceText(Self.question)
                .foregroundStyle(GlanceColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(String(format: card.acknowledgement, answer.lowercased()))
                .glanceText(.bodyCaption)
                .foregroundStyle(GlanceColor.textMuted)
                .fixedSize(horizontal: false, vertical: true)
                .transition(.opacity)
        }
    }

    /// `Answer` (2:783) — a full-width pill on a faint diagonal sheen.
    ///
    /// A 24pt corner rather than a capsule, as the comp has it: a long answer
    /// wraps to a second line, and a capsule would round that into a stadium.
    private func optionRow(_ option: String) -> some View {
        let shape = RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)

        return Button {
            answer = option
        } label: {
            Text(option)
                .glanceText(.labelMedium)
                .foregroundStyle(GlanceColor.textPrimary)
                // Wraps instead of truncating; a button label in a lazy stack
                // otherwise takes one line and cuts the rest off.
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Space.lg)
                .padding(.vertical, Space.md)
                .background {
                    shape.fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 1, green: 231 / 255, blue: 231 / 255, opacity: 0.005), location: 0.049),
                                .init(color: Color.white.opacity(0.08), location: 0.984)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
                .overlay { shape.strokeBorder(GlanceColor.outlineVariant, lineWidth: 1) }
                .contentShape(shape)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Surface

    /// Black at 60% with a soft inner glow, lit by two faint discs: one
    /// centred on the top edge, one on the bottom-right corner (2:774, 2:775).
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
