import SwiftUI

/// `TRAIN YOUR AI` (28037:12124) — the one card in the feed that asks rather
/// than tells. It carries its own three states: the question with its answers,
/// the answer as the viewer gave it, and Glance's acknowledgement.
struct SignalCardView: View {
    let card: SignalCard

    @State private var answer: String?

    private static let label = GlanceTextStyle(GlanceTypeface.interSemiBold, 10, tracking: 1.5, uppercased: true)
    private static let question = GlanceTextStyle(GlanceTypeface.serifRegular, 18, lineHeight: 23)
    private static let option = GlanceTextStyle(GlanceTypeface.interRegular, 14)

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            header

            if let answer {
                // The answer, then what Glance took from it.
                Text(answer)
                    .glanceText(Self.question)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(String(format: card.acknowledgement, answer.lowercased()))
                    .glanceText(.bodyS)
                    .foregroundStyle(GlanceColor.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            } else {
                Text(card.question)
                    .glanceText(Self.question)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: Space.md) {
                    ForEach(card.options, id: \.self) { option in
                        optionRow(option)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Space.lg)
        .background {
            let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)
            shape
                .fill(GlanceColor.bgSurface)
                .innerGlow(shape, radius: 34, color: Color.white.opacity(0.14))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: answer)
    }

    private var header: some View {
        HStack(spacing: Space.sm) {
            CroppedImage(name: card.avatar, crop: ImageCrop(width: 276, height: 287, x: -90, y: -5, reference: 104))
                .frame(width: 24, height: 24)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(GlanceColor.accentPrimary, lineWidth: 1))

            Text(card.label, style: Self.label)
                .glanceText(Self.label)
                .foregroundStyle(GlanceColor.textPrimary)
        }
    }

    private func optionRow(_ option: String) -> some View {
        Button {
            answer = option
        } label: {
            Text(option)
                .glanceText(Self.option)
                .foregroundStyle(GlanceColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Space.lg)
                .padding(.vertical, 13)
                .background(Capsule().fill(Color.white.opacity(0.04)))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
