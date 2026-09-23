import CoreText
import Foundation

/// Registers the bundled Inter and Libre Caslon Text faces with CoreText at launch,
/// so the app does not depend on a hand-maintained `UIAppFonts` list.
enum FontRegistration {
    private static var didRegister = false

    static func registerAll() {
        guard !didRegister else { return }
        didRegister = true

        let urls = Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? []
        for url in urls {
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                // Already-registered fonts are expected on hot reload; anything else is worth knowing.
                let code = CFErrorGetCode(error?.takeUnretainedValue())
                if code != CTFontManagerError.alreadyRegistered.rawValue {
                    print("[Glance] Could not register \(url.lastPathComponent): \(String(describing: error))")
                }
            }
        }
    }
}
