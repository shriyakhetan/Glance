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

/// The mascot as the `Filler` card (2:1011) and the composer's `Feed Ready`
/// state (32:1626) draw it. The exported art carries its own glow and a margin
/// around it, so the comps draw it at 131.88% of its box, nudged up and left,
/// and let the box crop the spare canvas away.
struct FillerMascot: View {
    var side: CGFloat

    var body: some View {
        Color.clear
            .frame(width: side, height: side)
            .overlay(alignment: .topLeading) {
                Image("ic-mascot-filler")
                    .resizable()
                    .frame(width: side * 1.3188, height: side * 1.3188)
                    .offset(x: -side * 0.1728, y: -side * 0.2196)
            }
            .clipped()
            .accessibilityHidden(true)
    }
}

/// A pinned top bar's icon button: a 40pt Liquid Glass disc inside a full 44pt
/// target, as iOS 26 draws a bar's buttons. Before iOS 26, the comp's bare glyph.
///
/// `contentShape` is what makes the target real: an `Image` inside a larger
/// `frame` only accepts taps on the glyph it actually draws, so a narrow arrow
/// ends up with an ~11pt tap area jammed against the screen edge.
struct BarIconButton: View {
    /// The glyph's asset and its own size in the comp.
    let icon: String
    var size: CGSize
    let label: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .frame(width: size.width, height: size.height)
                .frame(width: 40, height: 40)
                .liquidGlass(in: Circle(), interactive: true) { $0 }
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

/// A section heading — V7 `Display/Small`, the editorial voice.
struct SectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .glanceText(.displaySmall)
            .foregroundStyle(GlanceColor.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

/// V7's secondary button, `CTA (New Project)`, at whichever of the comp's sizes
/// a screen uses. On iOS 26 it is the system's secondary glass.
struct SecondaryButton: View {
    let title: String
    var icon: String?
    var iconSize: CGFloat = 12
    var style: GlanceTextStyle = .labelMedium
    var height: CGFloat = 32
    var padding: CGFloat = Space.lg
    var minWidth: CGFloat?
    var fillsWidth = false
    var hairline = Color.white.opacity(0.2)
    /// The component's trailing arrow — `Continue Chat →`.
    var showsArrow = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Space.sm) {
                if let icon {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                }
                Text(title)
                    .glanceText(style)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .lineLimit(1)
                if showsArrow {
                    // The 8×7 glyph sits in the comp's 12pt icon box.
                    Image("ic-arrow-forward")
                        .resizable()
                        .frame(width: 8, height: 7)
                        .frame(width: 12, height: 12)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, padding)
            .frame(minWidth: minWidth, maxWidth: fillsWidth ? .infinity : nil)
            .frame(height: height)
            .secondaryGlass(in: Capsule(), hairline: hairline)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
