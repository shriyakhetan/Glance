import Foundation

/// One turn Glance can take: what it asks, and the replies it offers.
struct ChatPrompt: Hashable {
    var text: String
    var options: [String] = []
}

/// What the assistant was opened about: Glance's opening line and the replies it
/// offers. Built by whatever screen opens the chat, so the answer arrives in
/// context rather than as a generic greeting.
struct ChatTopic: Identifiable, Hashable {
    let id = UUID()
    /// The card, product or section this conversation came from.
    var source: String
    var opening: String
    var options: [String] = []
    /// Asked one after another as each is answered, rather than all at once.
    /// The training flow uses this; a single-question topic leaves it empty.
    var followUps: [ChatPrompt] = []
    /// Said once the follow-ups run out.
    var closing: String?
}

