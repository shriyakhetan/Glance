import SwiftUI

/// The `FREQUENCY` block on the Occasion card — the only editable read on this
/// screen. Every other block reports; here the viewer fills in the gaps.
///
/// The block reads as two lists. Above, under `AI READ`, sits only what Glance
/// actually inferred — **fixed**, since that is the app reporting itself.
/// Everything the viewer has a say in sits under `YOU`: the occasions they took
/// over (amber, theirs to step through Low / Medium / High, or hand back with
/// the ×) followed by the ones Glance has nothing on, each offering `+Add`.
struct OccasionFrequencyView: View {
    let title: String
    let accessory: String

    /// Seed order, never rearranged — the list above reads from it directly.
    @State private var rows: [OccasionRow]
    /// The order rows were taken over in, which is the order `YOU` lists them.
    @State private var pinOrder: [UUID] = []

    /// The pinned accent. Not a Foundations colour — Figma has no token for this
    /// state yet, so it comes from the interaction spec.
    private static let pinned = Color(hex: 0xE8C66A)

    private static let rowName = GlanceTextStyle(GlanceTypeface.interLight, 12)
    private static let reading = GlanceTextStyle(GlanceTypeface.interRegular, 12)

    init(title: String, accessory: String, rows: [OccasionRow]) {
        self.title = title
        self.accessory = accessory
        _rows = State(initialValue: rows)
        // A seed can already carry pins — otherwise they would belong to
        // neither list and vanish.
        _pinOrder = State(initialValue: rows.filter { $0.source == .you }.map(\.id))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            header

            VStack(spacing: Space.md) {
                ForEach(glanceRows) { row in
                    rowView(row)
                }
            }

            pinnedSection
        }
        .animation(.easeInOut(duration: 0.25), value: rows)
    }

    /// What Glance actually read. A gap it has nothing on is the viewer's to
    /// fill, so it belongs under `YOU`, not here.
    private var glanceRows: [OccasionRow] {
        rows.filter { $0.source == .ai && $0.isActive }
    }

    private var pinnedRows: [OccasionRow] {
        pinOrder.compactMap { id in rows.first { $0.id == id } }
    }

    /// Unread occasions, in the order they were seeded.
    private var openRows: [OccasionRow] {
        rows.filter { !$0.isActive }
    }

    // MARK: - Header

    private var header: some View {
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

    // MARK: - What the viewer owns

    private var pinnedSection: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            Text("You", style: .labelSection)
                .glanceText(.labelSection)
                .foregroundStyle(Self.pinned)

            if pinnedRows.isEmpty {
                Text("Nothing yet — add one below.")
                    .glanceText(Self.reading)
                    .foregroundStyle(GlanceColor.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: Space.md) {
                // What has been set, then what is still on offer.
                ForEach(pinnedRows) { row in
                    rowView(row)
                }
                ForEach(openRows) { row in
                    rowView(row)
                }
            }
        }
        .padding(.top, Space.sm)
    }

    // MARK: - Rows

    @ViewBuilder
    private func rowView(_ row: OccasionRow) -> some View {
        if let level = row.level {
            VStack(alignment: .leading, spacing: Space.xxs) {
                HStack(alignment: .firstTextBaseline, spacing: Space.sm) {
                    // No per-row tag either way: each list now sits under a
                    // heading that names its source.
                    Text(row.name)
                        .glanceText(Self.rowName)
                        .foregroundStyle(GlanceColor.textPrimary)
                    Spacer(minLength: Space.md)

                    HStack(spacing: Space.sm) {
                        Text(level.label)
                            .glanceText(Self.reading)
                            .foregroundStyle(GlanceColor.textPrimary)

                        if row.canRemove {
                            Button { clear(row) } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(GlanceColor.textMuted)
                                    // The glyph alone is a 11pt target; the
                                    // shape gives it a real one.
                                    .frame(width: 22, height: 22)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Remove \(row.name)")
                        }
                    }
                }

                track(row, level: level)

            }
        } else {
            HStack {
                Text(row.name)
                    .glanceText(Self.rowName)
                    .foregroundStyle(GlanceColor.textTertiary)
                Spacer(minLength: Space.md)
                Button { add(row) } label: {
                    Text("+Add")
                        .font(.custom(GlanceTypeface.interMedium, size: 11))
                        .foregroundStyle(GlanceColor.textPrimary)
                        .padding(.horizontal, Space.xs)
                        .padding(.vertical, Space.xxs)
                        .background(Capsule().fill(Color.white.opacity(0.1)))
                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.04), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add a frequency for \(row.name)")
            }
        }
    }

    /// A 2pt track with a handle at the reading. Tapping anywhere along it steps
    /// to the next level — the row is a three-way switch, not a drag.
    private func track(_ row: OccasionRow, level: FrequencyLevel) -> some View {
        let tint = row.source == .ai ? GlanceColor.textPrimary : Self.pinned
        return GeometryReader { geometry in
            let width = geometry.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(hex: 0xF1F5F9, opacity: 0.1))
                    .frame(height: 2)
                Capsule()
                    .fill(tint)
                    .frame(width: width * level.fill, height: 2)
                Circle()
                    .fill(tint)
                    .frame(width: 10, height: 10)
                    .offset(x: width * level.fill - 5)
            }
            .frame(height: geometry.size.height)
        }
        .frame(height: 10)
        // Padded out to a real target, then made solid so the gap around the
        // 2pt track is tappable too.
        .padding(.vertical, Space.xxs)
        .contentShape(Rectangle())
        // An `AI READ` is Glance reporting itself and stays put; only the rows
        // the viewer owns respond.
        .onTapGesture { if row.source == .you { cycle(row) } }
        .accessibilityElement()
        .accessibilityLabel("\(row.name) frequency")
        .accessibilityValue(level.label)
        .accessibilityHint(row.source == .you ? "Tap to change" : "")
    }

    // MARK: - Editing

    private func add(_ row: OccasionRow) {
        update(row) {
            // Starts in the middle, so it can be nudged either way straight away.
            $0.level = .medium
            $0.source = .you
        }
        pinOrder.append(row.id)
    }

    /// Steps a row the viewer owns through Low → Medium → High and back.
    private func cycle(_ row: OccasionRow) {
        update(row) {
            $0.level = ($0.level ?? .low).next
        }
    }

    /// Hands the row back: it leaves `YOU` and reappears among Glance's own, in
    /// the position it started in.
    private func clear(_ row: OccasionRow) {
        update(row) {
            $0.level = nil
            $0.source = .ai
        }
        pinOrder.removeAll { $0 == row.id }
    }

    private func update(_ row: OccasionRow, _ change: (inout OccasionRow) -> Void) {
        guard let index = rows.firstIndex(where: { $0.id == row.id }) else { return }
        change(&rows[index])
    }
}
