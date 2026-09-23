import SwiftUI

/// `BEAUTY · 95% MATCH` — the overline pair that tags a card.
struct MatchTagView: View {
    let tag: MatchTag
    var ink: Color = GlanceColor.textSecondary
    var showsIcon: Bool = false
    /// A social read that leads the tag — `2.2K LIKE DIOR · BEAUTY`.
    var prefix: String?

    var body: some View {
        HStack(spacing: Space.xs) {
            if showsIcon {
                Image("ic-beauty-sparkle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14.57, height: 12)
                    .frame(width: 18, height: 18)
            }
            HStack(spacing: Space.xxs) {
                if let prefix {
                    Text(prefix, style: .labelOverline)
                        .glanceText(.labelOverline)
                    Circle()
                        .fill(ink)
                        .frame(width: 1.5, height: 1.5)
                }
                Text(tag.category, style: .labelOverline)
                    .glanceText(.labelOverline)
                // The comp drops the match score when a social read leads the
                // tag — all three will not fit a 165pt column.
                if prefix == nil {
                    Circle()
                        .fill(ink)
                        .frame(width: 1.5, height: 1.5)
                    Text(tag.match, style: .labelOverline)
                        .glanceText(.labelOverline)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        }
        .foregroundStyle(ink)
    }
}

/// The glassy pill used for feed tools, suggestion chips and filters.
/// How a chip is drawn. `outlined` is the hairline-on-glass chip the product
/// screen uses; `plain` is the borderless wash on the trending card.
enum GlanceChipTone {
    case outlined
    case plain
    /// For a chip sitting directly on photography: black at 50%, so the label
    /// holds against whatever is behind it.
    case scrim
}

struct GlanceChip: View {
    let title: String
    var icon: String?
    var systemIcon: String?
    var isSelected: Bool = false
    var tone: GlanceChipTone = .outlined
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6.35) {
                if let icon {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                } else if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: 13, weight: .medium))
                }
                Text(title)
                    .glanceText(.headingS)
            }
            .foregroundStyle(isSelected ? GlanceColor.textInverse : Color.white.opacity(0.8))
            .padding(.horizontal, Space.md)
            .padding(.vertical, Space.sm)
            .background(
                Capsule().fill(fill)
            )
            .overlay(
                Capsule().strokeBorder(
                    isSelected || tone != .outlined ? Color.clear : Color.white.opacity(0.3),
                    lineWidth: 0.5
                )
            )
        }
        .buttonStyle(.plain)
    }

    private var fill: Color {
        if isSelected { return GlanceColor.bgInverse }
        switch tone {
        case .plain: return Color.white.opacity(0.04)
        case .scrim: return .black.opacity(0.5)
        case .outlined: return GlanceColor.bgOverlay
        }
    }
}

/// A square-ish icon-only variant of `GlanceChip`.
struct GlanceIconChip: View {
    let icon: String
    var iconSize = CGSize(width: 15, height: 12)
    var tone: GlanceChipTone = .outlined
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize.width, height: iconSize.height)
                .frame(width: 18, height: 18)
                .padding(7)
                .background(Circle().fill(tone == .plain ? Color.white.opacity(0.04) : GlanceColor.bgOverlayStrong))
                .overlay(Circle().strokeBorder(
                    tone == .plain ? Color.clear : Color.white.opacity(0.3),
                    lineWidth: 0.5
                ))
        }
        .buttonStyle(.plain)
    }
}

/// Small solid badge — `TRENDING NEWS`, `HIGH CONFIDENCE`, `50% Off`.
struct GlanceBadge: View {
    let title: String
    var background: Color
    var ink: Color = GlanceColor.textPrimary
    var style: GlanceTextStyle = .labelSection
    var radius: CGFloat = 4

    var body: some View {
        Text(title, style: style)
            .glanceText(style)
            .foregroundStyle(ink)
            .padding(.horizontal, Space.md)
            .padding(.vertical, Space.xs)
            .background(RoundedRectangle(cornerRadius: radius, style: .continuous).fill(background))
    }
}

/// The Glance mascot (338:310), without its blurred ground glow.
///
/// The asset is just the body and eyes — the comp's blurred ellipse underneath
/// is dropped. Inside the comp's 48pt frame that body measures 34.34×27.43 at
/// (7.5, 10.5), so those numbers are kept and scaled rather than stretching the
/// artwork to fill a square, which would distort the character.
struct MascotView: View {
    /// Side of the mascot's own frame; the body scales from it.
    var size: CGFloat = 48

    private static let frameSide: CGFloat = 48
    private static let bodyWidth: CGFloat = 34.3399
    private static let bodyHeight: CGFloat = 27.4286
    private static let bodyOrigin = CGPoint(x: 7.5, y: 10.5)

    var body: some View {
        let scale = size / Self.frameSide
        Color.clear
            .frame(width: size, height: size)
            .overlay(alignment: .topLeading) {
                Image("ic-mascot-large")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Self.bodyWidth * scale, height: Self.bodyHeight * scale)
                    .offset(x: Self.bodyOrigin.x * scale, y: Self.bodyOrigin.y * scale)
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

/// Icon button for the pinned top bars, with a full 44pt touch target.
///
/// `contentShape` is what makes that target real: an `Image` inside a larger
/// `frame` only accepts taps on the glyph it actually draws, so a narrow icon
/// like `chevron.left` ends up with an ~11pt tap area jammed against the screen
/// edge — which reads as a button that simply does not work.
struct BarIconButton: View {
    let systemName: String
    let label: String
    var alignment: Alignment = .leading
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .regular))
                .frame(width: 44, height: 44, alignment: alignment)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

/// A section heading in the editorial serif voice.
struct SectionTitle: View {
    let title: String
    var body: some View {
        Text(title)
            .glanceText(.displayL)
            .foregroundStyle(GlanceColor.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Uppercase tracked label — `MY VISUAL SOURCES`, `WHAT GLANCE KNOWS`.
struct SectionLabel: View {
    let title: String
    var ink: Color = GlanceColor.textMuted
    var body: some View {
        Text(title, style: .labelSection)
            .glanceText(.labelSection)
            .foregroundStyle(ink)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
