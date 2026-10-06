import SwiftUI

/// What opened the assistant, so the stub can answer in context.
struct AskGlanceContext: Identifiable {
    let id = UUID()
    var title: String
    var prompt: String
}

private struct ChatLine: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

/// A stub assistant. `Ask Glance` and `Try On` open this rather than being dead
/// buttons; replies come from `AskGlanceResponder`, which a real service can replace.
struct AskGlanceView: View {
    let context: AskGlanceContext

    @Environment(\.dismiss) private var dismiss
    @State private var lines: [ChatLine] = []
    @State private var draft = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: Space.lg) {
                            ForEach(lines) { line in
                                bubble(line).id(line.id)
                            }
                        }
                        .padding(Space.xl)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .onChange(of: lines.count) {
                        withAnimation { proxy.scrollTo(lines.last?.id, anchor: .bottom) }
                    }
                }

                composer
            }
            .background(GlanceColor.bgBase)
            .navigationTitle(context.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .glanceText(.headingS)
                }
            }
        }
        .presentationDetents([.large])
        .task {
            guard lines.isEmpty else { return }
            lines = [ChatLine(text: AskGlanceResponder.opening(for: context), isUser: false)]
        }
    }

    private func bubble(_ line: ChatLine) -> some View {
        Text(line.text)
            .glanceText(.bodyM)
            .foregroundStyle(line.isUser ? GlanceColor.textInverse : GlanceColor.textPrimary)
            .padding(.horizontal, Space.lg)
            .padding(.vertical, Space.md)
            .background(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(line.isUser ? GlanceColor.bgInverse : GlanceColor.bgSurfaceElevated)
            )
            .frame(maxWidth: .infinity, alignment: line.isUser ? .trailing : .leading)
    }

    private var composer: some View {
        HStack(spacing: Space.md) {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(GlanceColor.textSecondary)
            TextField("Ask Glance", text: $draft)
                .glanceText(.bodyM)
                .foregroundStyle(GlanceColor.textPrimary)
                .focused($inputFocused)
                .submitLabel(.send)
                .onSubmit(send)
            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(draft.isEmpty ? GlanceColor.textDisabled : GlanceColor.accentPrimary)
            }
            .disabled(draft.isEmpty)
        }
        .padding(.horizontal, Space.lg)
        .padding(.vertical, Space.md)
        // The same glass as the bar that opened this sheet.
        .liquidGlass(in: Capsule(), interactive: true) { field in
            field
                .background(Capsule().fill(GlanceColor.bgOverlay))
                .overlay(Capsule().strokeBorder(GlanceColor.borderSubtle, lineWidth: 1))
        }
        .padding(.horizontal, Space.xl)
        .padding(.bottom, Space.lg)
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draft = ""
        lines.append(ChatLine(text: text, isUser: true))
        lines.append(ChatLine(text: AskGlanceResponder.reply(to: text), isUser: false))
    }
}

/// Canned replies. Swap this for a real assistant client without touching the view.
enum AskGlanceResponder {
    static func opening(for context: AskGlanceContext) -> String {
        "Looking at “\(context.prompt)”. I read your warm-neutral palette and relaxed-smart leaning, so I'll bias towards pieces that move between casual and slightly elevated. What would you like to explore?"
    }

    static func reply(to message: String) -> String {
        "Noted — “\(message)”. In the full build this is where a live answer lands. For now: your saved fit is a relaxed L, and your go-to palette runs espresso, sand and sage."
    }

    /// A reply that knows which card the conversation started from.
    static func reply(to message: String, topic: ChatTopic) -> String {
        if message.lowercased().hasPrefix("not now") {
            return "No problem. It'll be here under \(topic.source) whenever you want to pick it up."
        }
        return "On it — “\(message)”. A live answer lands here in the full build; for now I'm reading your \(topic.source.lowercased()) alongside your warm-neutral palette and relaxed-smart leaning."
    }
}
