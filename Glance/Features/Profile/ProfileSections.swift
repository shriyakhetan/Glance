import SwiftUI

/// The card every section on this screen sits on (2490:1671, 2490:1757):
/// `surfaceContainerLow` inside an `outlineVariant` hairline, lit from within by
/// `Inner Glow/Faint` — white at 8%, radius 10.
private struct ProfileCard: ViewModifier {
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background {
                shape
                    .fill(GlanceColor.bgBase)
                    .innerGlow(shape, radius: 10, color: Color.white.opacity(0.08))
            }
            .overlay { shape.strokeBorder(GlanceColor.hairline, lineWidth: 1) }
    }
}

private extension View {
    func profileCard(cornerRadius: CGFloat = Radius.xl) -> some View {
        modifier(ProfileCard(cornerRadius: cornerRadius))
    }
}

// MARK: - Vibe chips

/// `vibe-chips` (2490:1661) — the aesthetics Glance reads in her. Tapping one
/// marks it as hers.
struct VibeChipsView: View {
    let chips: [VibeChip]
    @Binding var selected: Set<UUID>

    var body: some View {
        FlowLayout(spacing: Space.sm) {
            ForEach(chips) { chip in
                let isOn = selected.contains(chip.id)
                Button {
                    if isOn { selected.remove(chip.id) } else { selected.insert(chip.id) }
                } label: {
                    Text(chip.text)
                        .glanceText(.labelMedium)
                        .foregroundStyle(GlanceColor.textPrimary)
                        .padding(.horizontal, Space.lg)
                        .padding(.vertical, Space.md)
                        .profileCard(cornerRadius: Radius.md)
                        .overlay {
                            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                                .strokeBorder(GlanceColor.accentSecondary, lineWidth: 1)
                                .opacity(isOn ? 1 : 0)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
        .sensoryFeedback(.selection, trigger: selected)
        .animation(.easeOut(duration: 0.15), value: selected)
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

/// `Your Analysis` (2490:1668) — four 240pt cards in a row that pages card by
/// card, the next one showing at the edge.
struct AnalysisSection: View {
    let cards: [AnalysisCard]
    /// The card's call to action opens the assistant on that reading (731:701).
    var onAsk: (AnalysisCard) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            SectionTitle(title: "Personal Analysis")
                .padding(.horizontal, Space.xl)

            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: Space.md) {
                    ForEach(cards) { card in
                        cardView(card)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, Space.xl, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
        }
    }

    /// 2490:1671 — what it reads, the portrait with its reading beside it, the
    /// reading in the editorial voice, and a call to action.
    private func cardView(_ card: AnalysisCard) -> some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            VStack(alignment: .leading, spacing: Space.md) {
                Text(card.title)
                    .glanceText(.labelMedium)
                    .foregroundStyle(GlanceColor.textPrimary)
                imageArea(card)
            }

            VStack(alignment: .leading, spacing: Space.md) {
                VStack(alignment: .leading, spacing: Space.sm) {
                    Text(card.headline)
                        .glanceText(.displaySmall)
                        .foregroundStyle(GlanceColor.textPrimary)
                    Text(card.detail)
                        .glanceText(.bodyCaption)
                        .foregroundStyle(GlanceColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SecondaryButton(title: card.cta, padding: Space.md, hairline: Color.white.opacity(0.08)) {
                    onAsk(card)
                }
            }
        }
        .padding(Space.xl)
        // 302 is a floor, not a cap: a longer reading grows the card.
        .frame(width: 240, alignment: .topLeading)
        .frame(minHeight: 302, alignment: .top)
        .profileCard()
    }

    /// `Image Area` (192×80). The tag is painted *before* the portrait, as in
    /// Figma, so the circle occludes the tag's leading end rather than the tag
    /// covering her hair.
    private func imageArea(_ card: AnalysisCard) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear.frame(width: 192, height: 80)

            metricTag(card)
                // Pinned 59pt in and centred on the row, half a point low.
                .frame(height: 80, alignment: .center)
                .offset(y: 0.5)
                .padding(.leading, 59)

            portrait(card)
        }
    }

    private func metricTag(_ card: AnalysisCard) -> some View {
        let shape = RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
        return VStack(alignment: .leading, spacing: Space.xxxs) {
            Text(card.metricLabel)
                .glanceText(.labelSmall)
                .opacity(0.5)
            Text(card.metricValue.uppercased())
                .glanceText(.labelMedium)
        }
        .foregroundStyle(GlanceColor.textPrimary)
        .lineLimit(1)
        .fixedSize()
        // Asymmetric: the leading padding clears the circle overlapping it.
        .padding(.leading, 28)
        .padding(.trailing, Space.lg)
        .padding(.vertical, Space.sm)
        .background { shape.fill(LinearGradient.secondarySheen) }
        .overlay { shape.strokeBorder(GlanceColor.hairline, lineWidth: 0.5) }
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
            .accessibilityHidden(true)
    }

    private var sparkle: some View {
        Image("ic-check")
            .resizable()
            .frame(width: 5.937, height: 5.937)
    }
}

// MARK: - Dimension cards

/// `dim-card` (2490:1757) — one area Glance has read, as titled blocks of
/// rows, meters and swatches.
struct DimensionCardView: View {
    let card: DimensionCard

    /// `YOUR GO TO` — what she has told Glance.
    private static let yoursInk = Color(hex: 0xF6AB00)

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            VStack(alignment: .leading, spacing: card.headerSpacing) {
                Text(card.title)
                    .glanceText(.displaySmall)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text(card.subtitle)
                    .glanceText(.bodyCaption)
                    .foregroundStyle(GlanceColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Figma pads each block 16 inside its own frame and leaves 12
            // between frames, so consecutive blocks stand 44pt apart.
            ForEach(card.blocks) { block in
                blockView(block)
                    .padding(.vertical, Space.lg)
            }
        }
        .padding(Space.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .profileCard()
    }

    @ViewBuilder
    private func blockView(_ block: DimensionBlock) -> some View {
        switch block {
        case .facts(let title, let tag, let rows, let spacing):
            VStack(alignment: .leading, spacing: Space.lg) {
                blockHeader(title, tag)
                VStack(spacing: spacing) {
                    ForEach(rows) { row in
                        HStack(alignment: .top) {
                            Text(row.label)
                                .glanceText(.bodyCaption)
                                .foregroundStyle(GlanceColor.textSecondary)
                            Spacer(minLength: Space.md)
                            Text(row.value)
                                .glanceText(.labelMedium)
                                .foregroundStyle(GlanceColor.textPrimary)
                                .multilineTextAlignment(.trailing)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }

        case .meters(let title, let tag, let rows, let spacing, let rowInset):
            VStack(alignment: .leading, spacing: Space.lg) {
                blockHeader(title, tag)
                VStack(spacing: spacing) {
                    ForEach(rows) { row in
                        VStack(spacing: Space.sm) {
                            HStack {
                                Text(row.label)
                                    .glanceText(.bodyCaption)
                                    .foregroundStyle(GlanceColor.textSecondary)
                                Spacer(minLength: Space.md)
                                Text(row.reading)
                                    .glanceText(.labelMedium)
                                    .foregroundStyle(GlanceColor.textPrimary)
                            }
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.white.opacity(0.12))
                                    Capsule()
                                        .fill(GlanceColor.textPrimary)
                                        .frame(width: geometry.size.width * Double(row.percent) / 100)
                                }
                            }
                            .frame(height: 2)
                        }
                        .padding(.bottom, rowInset)
                        .accessibilityElement(children: .combine)
                    }
                }
            }

        case .palette(let title, let tag, let swatches):
            VStack(alignment: .leading, spacing: Space.lg) {
                blockHeader(title, tag)
                HStack(alignment: .top, spacing: Space.md) {
                    ForEach(swatches) { swatch in
                        VStack(spacing: Space.xs) {
                            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                                .fill(Color(hex: swatch.color))
                                .frame(width: 40, height: 40)
                            Text(swatch.name)
                                .glanceText(.labelSmall)
                                .foregroundStyle(GlanceColor.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityElement(children: .combine)
                    }
                }
            }
            // The palette closes the card on 24 rather than 16 (2490:1808).
            .padding(.bottom, Space.sm)
        }
    }

    private func blockHeader(_ title: String, _ tag: BlockTag) -> some View {
        HStack {
            Text(title.uppercased())
                .foregroundStyle(GlanceColor.textPrimary)
            Spacer(minLength: Space.md)
            Text(tag.text.uppercased())
                .foregroundStyle(tag.source == .yours ? Self.yoursInk : GlanceColor.accentSecondary)
        }
        .glanceText(.labelMedium)
    }
}
