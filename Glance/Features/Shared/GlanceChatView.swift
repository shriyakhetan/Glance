import SwiftUI

private struct ChatLine: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

/// The Glance assistant (731:701): a black screen, the wordmark between two
/// round buttons, and Glance's reply under its mascot with a few replies to
/// choose from. The composer takes anything else.
struct GlanceChatView: View {
    let topic: ChatTopic

    @Environment(\.dismiss) private var dismiss
    @State private var lines: [ChatLine] = []
    @State private var options: [String] = []
    /// How many of the topic's follow-ups have been asked.
    @State private var asked = 0
    @State private var draft = ""
    @FocusState private var inputFocused: Bool

    private static let bottomAnchor = "chat-bottom"

    private static let reply = GlanceTextStyle(GlanceTypeface.interMedium, 14, lineHeight: 20)
    private static let chip = GlanceTextStyle(GlanceTypeface.interMedium, 12, lineHeight: 18, tracking: 0.12)
    private static let placeholder = GlanceTextStyle(GlanceTypeface.interRegular, 12, lineHeight: 18.7)

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(lines) { line in
                        lineView(line).id(line.id)
                    }

                    if !options.isEmpty {
                        VStack(alignment: .leading, spacing: Space.md) {
                            ForEach(options, id: \.self) { option in
                                optionChip(option)
                            }
                        }
                        .padding(.top, Space.xs)
                    }

                    // Reserved as a view rather than padding: scrolling to it
                    // parks the composer's height below the last line, instead
                    // of tucking that line underneath the composer.
                    Color.clear
                        .frame(height: 124)
                        .id(Self.bottomAnchor)
                }
                .padding(.horizontal, Space.xl)
                .padding(.top, Space.xl)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onChange(of: lines.count) {
                withAnimation { proxy.scrollTo(Self.bottomAnchor, anchor: .bottom) }
            }
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .top, spacing: 0) { header }
        .background(Color.black.ignoresSafeArea())
        .overlay(alignment: .bottom) { composer }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .task {
            guard lines.isEmpty else { return }
            lines = [ChatLine(text: topic.opening, isUser: false)]
            options = topic.options
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 0) {
            circleButton(systemName: "arrow.left", label: "Back") { dismiss() }

            Spacer(minLength: Space.md)

            HStack(spacing: Space.xs) {
                Image("glance-wordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 98.5, height: 28)
                Image("ic-spark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 23)
            }

            Spacer(minLength: Space.md)

            circleButton(systemName: "plus", label: "New chat") {}
        }
        .padding(.horizontal, 15)
        .padding(.vertical, Space.md)
        .background(.black.opacity(0.6))
        .background(.ultraThinMaterial)
    }

    private func circleButton(systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: systemName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(GlanceColor.textPrimary)
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    // MARK: - Conversation

    @ViewBuilder
    private func lineView(_ line: ChatLine) -> some View {
        if line.isUser {
            Text(line.text)
                .glanceText(Self.reply)
                .foregroundStyle(GlanceColor.textPrimary)
                .padding(.horizontal, Space.lg)
                .padding(.vertical, Space.md)
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.08)))
                .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            VStack(alignment: .leading, spacing: Space.xxs) {
                MascotView(size: 32)
                Text(line.text)
                    .glanceText(Self.reply)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    // The comp wraps the reply at 317, not the full gutter.
                    .frame(maxWidth: 317, alignment: .leading)
            }
        }
    }

    private func optionChip(_ option: String) -> some View {
        Button { choose(option) } label: {
            Text(option)
                .glanceText(Self.chip)
                .foregroundStyle(GlanceColor.textPrimary)
                .padding(.horizontal, Space.lg)
                .frame(height: 32)
                .background {
                    Capsule().fill(LinearGradient(
                        colors: [Color(hex: 0xFFE7E7, opacity: 0.01), Color.white.opacity(0.08)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                }
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Composer

    private var composer: some View {
        HStack(spacing: Space.xs) {
            Button {} label: {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(GlanceColor.textPrimary)
                    .frame(width: 22.5, height: 22.5)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Attach")

            ZStack(alignment: .leading) {
                if draft.isEmpty {
                    Text("Ask Glance")
                        .glanceText(Self.placeholder)
                        .foregroundStyle(Color.white.opacity(0.3))
                        .allowsHitTesting(false)
                }
                TextField("", text: $draft)
                    .glanceText(Self.placeholder)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .focused($inputFocused)
                    .submitLabel(.send)
                    .onSubmit(send)
            }

            if !draft.isEmpty {
                Button(action: send) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(GlanceColor.accentPrimary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Send")
            }
        }
        .padding(.horizontal, Space.md)
        .frame(height: 44)
        .background(Capsule().fill(Color(hex: 0x111111, opacity: 0.6)))
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.3), lineWidth: 0.936))
        .padding(.horizontal, Space.xl)
        .padding(.bottom, Space.xxl)
        // The comp grades the bottom to black over a blur, the same treatment
        // the feed's composer sits on.
        .background {
            EdgeScrim(edge: .bottom)
                .padding(.top, -72)
                .ignoresSafeArea()
        }
    }

    // MARK: - Replies

    private func choose(_ option: String) {
        answer(option)
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draft = ""
        answer(text)
    }

    /// Records the reply, then either asks the next question in the topic or
    /// falls back to a canned answer.
    private func answer(_ text: String) {
        options = []
        lines.append(ChatLine(text: text, isUser: true))

        if asked < topic.followUps.count {
            let next = topic.followUps[asked]
            asked += 1
            lines.append(ChatLine(text: next.text, isUser: false))
            options = next.options
        } else if asked == topic.followUps.count, !topic.followUps.isEmpty, let closing = topic.closing {
            // Only once: after this the topic behaves like any other.
            asked += 1
            lines.append(ChatLine(text: closing, isUser: false))
        } else {
            lines.append(ChatLine(text: AskGlanceResponder.reply(to: text, topic: topic), isUser: false))
        }
    }
}

#Preview {
    NavigationStack {
        GlanceChatView(topic: ChatTopic(
            source: "Body Frame",
            opening: "Your shoulders and hips sit close to even, so shape comes from what you nip in rather than what you pad out.",
            options: ["Show me tops", "Trousers that work", "Not now"]
        ))
    }
    .preferredColorScheme(.dark)
}
