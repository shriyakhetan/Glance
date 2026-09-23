import SwiftUI

/// The recurring surface on this screen: `bg/surface` inside a hairline border,
/// lit from within by `Inner Glow/Strong` — `#FFFFFF2B` at radius 34.
private struct ProfileSurface: ViewModifier {
    var cornerRadius: CGFloat = Radius.xl

    func body(content: Content) -> some View {
        content
            .background {
                let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                // `shadow(inset 0 0 34 rgba(255,255,255,0.17))`
                shape
                    .fill(GlanceColor.bgSurface)
                    .innerGlow(shape, radius: 34, color: Color.white.opacity(0.17))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            }
    }
}

private extension View {
    func profileSurface(cornerRadius: CGFloat = Radius.xl) -> some View {
        modifier(ProfileSurface(cornerRadius: cornerRadius))
    }
}

// MARK: - Visual sources

struct PhotoStripSection: View {
    let sources: [VisualSource]
    let imageData: [UUID: Data]
    var onPick: (VisualSource) -> Void

    /// `Images` (338:213) lays five 82.5pt tiles at a 12pt gap — 460.5pt of row
    /// inside a 354pt frame, so the strip scrolls rather than shrinking to fit.
    private let tileWidth: CGFloat = 82.5
    private let tileHeight: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            SectionLabel(title: "My Visual Sources")

            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: Space.md) {
                    ForEach(sources) { source in
                        Button { onPick(source) } label: {
                            VStack(spacing: Space.xxs) {
                                tile(source)
                                if !source.isSpare {
                                    Text(source.label)
                                        .glanceText(.captionMedium)
                                        .foregroundStyle(GlanceColor.textMuted)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .frame(width: tileWidth)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
        }
    }

    @ViewBuilder
    private func tile(_ source: VisualSource) -> some View {
        let shape = RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
        if let data = imageData[source.id], let image = UIImage(data: data) {
            // A picked photo has no art direction to honour, so just cover.
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: tileWidth, height: tileHeight)
                .clipShape(shape)
        } else if let name = source.image {
            CroppedImage(name: name, crop: source.crop)
                .frame(width: tileWidth, height: tileHeight)
                .clipShape(shape)
        } else {
            shape
                .fill(source.isSpare ? GlanceColor.bgSurfaceElevated : Color(hex: 0x111111, opacity: 0.2))
                .frame(width: tileWidth, height: tileHeight)
                .overlay {
                    shape.strokeBorder(
                        GlanceColor.borderDefault,
                        style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                    )
                }
                .overlay {
                    Text("+")
                        .glanceText(.headingXLRegular)
                        .foregroundStyle(GlanceColor.textDisabled)
                }
        }
    }
}

// MARK: - Vibe chips

struct VibeChipsView: View {
    let chips: [VibeChip]
    @Binding var selected: Set<UUID>

    var body: some View {
        FlowLayout(spacing: Space.sm) {
            ForEach(chips) { chip in
                let isOn = selected.contains(chip.id)
                Button {
                    if chip.isAdd { return }
                    if isOn { selected.remove(chip.id) } else { selected.insert(chip.id) }
                } label: {
                    Text(chip.text)
                        .glanceText(.bodySMedium)
                        .foregroundStyle(chip.isAdd ? GlanceColor.textTertiary : GlanceColor.textPrimary)
                        .padding(.horizontal, chip.isAdd ? Space.lg : 20)
                        .padding(.vertical, 13)
                        .background {
                            let shape = RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                            if chip.isAdd {
                                shape.fill(Color.black.opacity(0.1))
                            } else {
                                shape
                                    .fill(GlanceColor.bgSurface)
                                    .innerGlow(shape, radius: 34, color: Color.white.opacity(0.17))
                            }
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                                .strokeBorder(
                                    isOn ? GlanceColor.accentPrimary : Color.white.opacity(0.1),
                                    style: StrokeStyle(lineWidth: 1, dash: chip.isAdd ? [4, 4] : [])
                                )
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// Wraps chips onto as many rows as they need.
struct FlowLayout: Layout {
    var spacing: CGFloat = Space.sm

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Personal analysis

struct AnalysisSection: View {
    let cards: [AnalysisCard]
    /// The card's call to action opens the assistant on that reading (731:701).
    var onAsk: (AnalysisCard) -> Void

    /// The card's reading: Inter Regular 11 at a 1.4 line height (631:835).
    private static let cardDetail = GlanceTextStyle(GlanceTypeface.interRegular, 11, lineHeight: 11 * 1.4)

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            SectionLabel(title: "Personal Analysis")
                .padding(.horizontal, Space.xl)

            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: Space.md) {
                    ForEach(cards) { card in
                        cardView(card)
                            .frame(width: 240)
                    }
                }
                .padding(.horizontal, Space.xl)
            }
            .scrollIndicators(.hidden)
        }
    }

    /// 631:777 — a 240×263 card: an 80pt image row with the metric chip beside
    /// it, the reading, and a per-card call to action.
    private func cardView(_ card: AnalysisCard) -> some View {
        VStack(spacing: Space.xl) {
            imageArea(card)

            VStack(alignment: .leading, spacing: Space.sm) {
                HStack(alignment: .firstTextBaseline, spacing: Space.sm) {
                    Text(card.title)
                        .font(.custom(GlanceTypeface.serifMedium, size: 12))
                    Spacer(minLength: 0)
                    Text(card.value)
                        .font(.custom(GlanceTypeface.interSemiBold, size: 14))
                }
                .foregroundStyle(GlanceColor.textPrimary)

                Text(card.detail)
                    .glanceText(Self.cardDetail)
                    .foregroundStyle(Color.white.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }
            // The comp gives this block 55pt — enough for the row plus two
            // lines — and lets a longer reading push the card taller.
            .frame(maxWidth: .infinity, minHeight: 55, alignment: .topLeading)

            Button { onAsk(card) } label: {
                Text(card.cta)
                    .font(.custom(GlanceTypeface.interMedium, size: 11))
                    .foregroundStyle(GlanceColor.textPrimary)
                    .padding(.horizontal, Space.lg)
                    .padding(.vertical, Space.sm)
                    .background(Capsule().fill(Color(hex: 0x2A2A2A)))
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(Space.xl)
        // 263 is a floor, not a cap: an expanded card grows. Content stays top
        // aligned, so the comp's ~3pt of slack falls below the pill.
        .frame(minHeight: 263, alignment: .top)
        .profileSurface()
    }

    /// `Image Area` (192×80). The chip is painted *before* the portrait, as in
    /// Figma, so the circle occludes the chip's leading end rather than the chip
    /// covering her hair.
    private func imageArea(_ card: AnalysisCard) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear.frame(height: 80)

            metricChip(card)
                // Pinned 59pt in and centred on the row.
                .frame(height: 80, alignment: .center)
                .padding(.leading, 59)

            portrait(card)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func metricChip(_ card: AnalysisCard) -> some View {
        VStack(alignment: .leading, spacing: Space.xxxs) {
            Text(card.metricLabel.uppercased())
                .font(.custom(GlanceTypeface.interSemiBold, size: 8))
                .tracking(0.64)
                .opacity(0.5)
            Text(card.metricValue.uppercased())
                .font(.custom(GlanceTypeface.interBold, size: 12))
                .tracking(0.24)
        }
        .foregroundStyle(GlanceColor.textPrimary)
        .lineLimit(1)
        .fixedSize()
        // Asymmetric: the leading padding clears the circle overlapping it.
        .padding(.leading, 28)
        .padding(.trailing, Space.lg)
        .padding(.vertical, Space.sm)
        .background {
            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                .fill(Color.white.opacity(0.12))
                .overlay(
                    // Figma says `0.5px solid white`, but at 1x that rasterises
                    // to a whisper — the comp's edge is only ~10 levels above
                    // the fill. Drawn at full white it becomes a hard line on a
                    // 3x screen, so match the rendered value, not the nominal.
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        }
    }

    /// The 80pt ring: a 76pt circle inset 2pt, the ring artwork over it, and the
    /// two sparkles Figma places just outside it.
    private func portrait(_ card: AnalysisCard) -> some View {
        Color.clear
            .frame(width: 80, height: 80)
            .overlay {
                Circle()
                    .fill(Color.black.opacity(0.2))
                    .overlay {
                        if let image = card.portrait {
                            CroppedImage(name: image, crop: card.crop)
                        }
                    }
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Color(hex: 0x212121), lineWidth: 0.369))
                    .frame(width: 76, height: 76)
            }
            .overlay {
                Image("ic-analysis-ring")
                    .resizable()
                    .scaledToFit()
            }
            .overlay(alignment: .topLeading) {
                sparkle.offset(x: 66.37, y: 8.55)
            }
            .overlay(alignment: .topLeading) {
                sparkle.offset(x: -1, y: 49.27)
            }
    }

    private var sparkle: some View {
        Image("ic-check")
            .resizable()
            .frame(width: 5.937, height: 5.937)
    }
}

// MARK: - Training banner

struct TrainingBanner: View {
    let prompt: GapPrompt
    var onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: Space.sm) {
                MascotView(size: 48)
                Text(prompt.title)
                    .glanceText(.displayL)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(prompt.body)
                    .glanceText(.bodyS)
                    .foregroundStyle(GlanceColor.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onStart) {
                Text(prompt.cta)
                    .glanceText(.bodySMedium)
                    .foregroundStyle(Color(hex: prompt.ctaInk))
                    .padding(.horizontal, Space.lg)
                    .padding(.vertical, Space.sm)
                    .background(Capsule().fill(Color(hex: prompt.ctaBackground)))
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Space.xxl)
        .padding(.vertical, 40)
        .profileSurface()
    }
}

// MARK: - Dimension cards

struct DimensionCardView: View {
    let card: DimensionCard

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: Space.md) {
                Text(card.title)
                    .glanceText(.displayL)
                    .foregroundStyle(GlanceColor.textPrimary)
                Text(card.subtitle)
                    .glanceText(.bodyS)
                    .foregroundStyle(GlanceColor.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, Space.lg)

            // Figma pads each block 16 inside its own frame and leaves 12
            // between frames (689:1053 / 1076 / 1099), so consecutive blocks
            // stand 44pt apart — not the 16 a single gap would give.
            VStack(alignment: .leading, spacing: Space.md) {
                ForEach(card.blocks) { block in
                    blockView(block)
                        .padding(.vertical, Space.lg)
                }
            }
        }
        .padding(.horizontal, Space.xxl)
        .padding(.top, Space.xl)
        // The last block already carries 16 of its own; with this the content
        // clears the completeness bar on the bottom edge by 40.
        .padding(.bottom, Space.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .profileSurface()
        .overlay(alignment: .bottomLeading) {
            // Completeness bar pinned to the card's bottom edge.
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08))
                    // A soft cap where the bar starts, as in the comp.
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 18)
                        .blur(radius: 9.5)
                    Capsule()
                        .fill(Color(hex: card.progressColor))
                        .frame(width: geometry.size.width * card.completeness)
                }
                .frame(height: 6)
                .offset(y: geometry.size.height - 6)
            }
            .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
    }

    @ViewBuilder
    private func blockView(_ block: DimensionBlock) -> some View {
        switch block {
        case .facts(let title, let accessory, let rows):
            VStack(alignment: .leading, spacing: Space.lg) {
                blockHeader(title, accessory)
                VStack(spacing: Space.sm) {
                    ForEach(rows) { row in
                        HStack(alignment: .top) {
                            Text(row.label)
                                .glanceText(.bodySLight)
                                .foregroundStyle(GlanceColor.textTertiary)
                            Spacer(minLength: Space.md)
                            Text(row.value)
                                .glanceText(.bodyS)
                                .foregroundStyle(GlanceColor.textPrimary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            }

        case .meters(let title, let accessory, let rows):
            // A block that still has unread rows breathes wider (689:1147);
            // one that is fully read sits tighter (689:1080).
            let hasPrompt = rows.contains(where: \.isPrompt)
            VStack(alignment: .leading, spacing: Space.lg) {
                blockHeader(title, accessory)
                // Wider than Figma's 12: at that pitch a track sits right under
                // the next label and the rows read as one block of text.
                VStack(spacing: 20) {
                    ForEach(rows) { row in
                        if let reading = row.reading {
                            VStack(spacing: Space.sm) {
                                HStack {
                                    Text(row.label)
                                        .glanceText(.bodySLight)
                                        .foregroundStyle(GlanceColor.textTertiary)
                                    Spacer(minLength: Space.md)
                                    Text(reading)
                                        .glanceText(.bodyS)
                                        .foregroundStyle(GlanceColor.textPrimary)
                                }
                                if let percent = row.percent {
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            Capsule().fill(Color(hex: 0xF1F5F9, opacity: 0.1))
                                            Capsule()
                                                .fill(GlanceColor.textPrimary)
                                                .frame(width: geometry.size.width * Double(percent) / 100)
                                        }
                                    }
                                    .frame(height: 2)
                                }
                            }
                            .padding(.bottom, hasPrompt ? Space.xxs : 0)
                        } else {
                            HStack {
                                Text(row.label)
                                    .glanceText(.bodySLight)
                                    .foregroundStyle(GlanceColor.textTertiary)
                                Spacer(minLength: Space.md)
                                Button {} label: {
                                    Text("+Add")
                                        .font(.custom(GlanceTypeface.interMedium, size: 11))
                                        .foregroundStyle(GlanceColor.textPrimary)
                                        .padding(.horizontal, Space.xs)
                                        .padding(.vertical, Space.xxs)
                                        .background(Capsule().fill(Color.white.opacity(0.1)))
                                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.04), lineWidth: 0.5))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }

        case .frequency(let title, let accessory, let rows):
            OccasionFrequencyView(title: title, accessory: accessory, rows: rows)

        case .palette(let title, let accessory, let swatches):
            VStack(alignment: .leading, spacing: Space.lg) {
                blockHeader(title, accessory)
                HStack(alignment: .top, spacing: Space.md) {
                    ForEach(swatches) { swatch in
                        VStack(spacing: Space.xs) {
                            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                                .fill(Color(hex: swatch.color))
                                .frame(width: 40, height: 40)
                            Text(swatch.name)
                                .glanceText(.captionRegular)
                                .foregroundStyle(GlanceColor.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private func blockHeader(_ title: String, _ accessory: String) -> some View {
        HStack {
            Text(title, style: .labelSection)
                .glanceText(.labelSection)
                .foregroundStyle(GlanceColor.textPrimary)
            Spacer(minLength: Space.md)
            Text(accessory, style: .labelSection)
                .glanceText(.labelSection)
                .foregroundStyle(GlanceColor.textAccent)
        }
    }
}
