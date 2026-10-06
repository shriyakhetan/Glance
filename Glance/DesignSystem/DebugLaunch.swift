import Foundation

/// Launch-argument hooks used while building the screens, so a specific route or
/// scroll position can be captured without driving the UI by hand.
///
/// Usage: `xcrun simctl launch booted <bundle-id> --route product --scrollTo 3`
enum DebugLaunch {
    #if DEBUG
    static var route: String? {
        value(for: "--route")
    }

    static var scrollTo: Int? {
        value(for: "--scrollTo").flatMap(Int.init)
    }

    /// `--chat 0` opens the assistant on that analysis card's reading.
    static var chat: Int? {
        value(for: "--chat").flatMap(Int.init)
    }

    /// `--gallery look` (or `signal`, `filler`, `tips`) launches straight
    /// into a component's variant gallery instead of Home.
    static var gallery: String? {
        value(for: "--gallery")
    }

    /// `--askStage feedReady` starts Home's composer at another point in the
    /// journey: `beforeOnboarding`, `feedReady`, `firstGeneration` (on the
    /// comp's 2:59), `feedIsReady` or `afterOnboarding`.
    static var askStage: String? {
        value(for: "--askStage")
    }

    private static func value(for flag: String) -> String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: flag), index + 1 < arguments.count else { return nil }
        return arguments[index + 1]
    }
    #else
    static var route: String? { nil }
    static var scrollTo: Int? { nil }
    static var chat: Int? { nil }
    static var gallery: String? { nil }
    static var askStage: String? { nil }
    #endif
}
