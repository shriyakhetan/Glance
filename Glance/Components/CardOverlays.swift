import SwiftUI

/// The heart the updated feed puts on nearly every card (28037:12124). Outlined
/// on the artwork until it is tapped, then filled red.
///
/// Each card owns its own state for now; a real build would hand this to the
/// wishlist repository, which is why the toggle is kept behind a binding-free
/// initialiser rather than being wired to the model.
struct WishlistButton: View {
    /// How the button sits on what is behind it. `solid` fills white once liked,
    /// as the feed comp draws it on photography; `glass` keeps the translucent
    /// dark disc throughout, which is what the tip card asks for (27641:10006).
    enum Tone {
        case solid
        case glass
    }

    var isOn: Bool = false
    var tone: Tone = .solid

    @State private var liked: Bool

    init(isOn: Bool = false, tone: Tone = .solid) {
        self.isOn = isOn
        self.tone = tone
        _liked = State(initialValue: isOn)
    }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.6)) { liked.toggle() }
        } label: {
            Image(systemName: liked ? "heart.fill" : "heart")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(liked ? Color(hex: 0xFF3B30) : GlanceColor.textPrimary)
                .frame(width: 32, height: 32)
                .background {
                    switch tone {
                    case .solid:
                        Circle().fill(liked ? .white : .black.opacity(0.28))
                    case .glass:
                        Circle()
                            .fill(.black.opacity(0.2))
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .contentShape(Circle())
                .scaleEffect(liked ? 1.06 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(liked ? "Remove from wishlist" : "Save to wishlist")
    }
}

/// `Trending card` (28119:1632) — the tag that marks a live read, wherever one
/// appears: on a card's artwork (`2k bought this`, `Popular brand`) and as the
/// story line on the trending card.
///
/// A single component on purpose. It carried two different treatments before —
/// a dark scrim on the artwork, a tinted gradient on the trending panel — and
/// the two drifted apart the moment the design changed.
struct TrendingTag: View {
    let text: String
    /// The arrow is the mark of a *live* read; a plain label goes without it.
    var showsTrend: Bool = true

    private static let label = GlanceTextStyle(GlanceTypeface.interSemiBold, 10, tracking: 0.2)

    var body: some View {
        HStack(spacing: 2) {
            if showsTrend {
                Image("ic-trend-arrow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 7.5)
            }
            Text(text)
                .glanceText(Self.label)
                .foregroundStyle(GlanceColor.textPrimary)
                .lineLimit(1)
        }
        .padding(.horizontal, 6.5)
        .padding(.vertical, 4.5)
        .background {
            let shape = RoundedRectangle(cornerRadius: 4, style: .continuous)
            shape
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial, in: shape)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5)
        }
    }
}
