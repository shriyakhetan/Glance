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

    /// `--sheet addPhoto` opens Profile's source chooser on appear. Sheets can't
    /// be reached otherwise: `simctl` has no way to tap.
    static var sheet: String? {
        value(for: "--sheet")
    }

    /// `--focus name` puts the caret in Profile's name field on appear, so the
    /// keyboard can be captured without a tap.
    static var focus: String? {
        value(for: "--focus")
    }

    /// `--chat 0` opens the assistant on that analysis card's reading.
    static var chat: Int? {
        value(for: "--chat").flatMap(Int.init)
    }

    private static func value(for flag: String) -> String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: flag), index + 1 < arguments.count else { return nil }
        return arguments[index + 1]
    }
    #else
    static var route: String? { nil }
    static var scrollTo: Int? { nil }
    static var sheet: String? { nil }
    static var focus: String? { nil }
    static var chat: Int? { nil }
    #endif
}
