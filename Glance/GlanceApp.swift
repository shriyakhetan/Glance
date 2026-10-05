import SwiftUI

@main
struct GlanceApp: App {
    init() {
        FontRegistration.registerAll()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if DebugLaunch.gallery == "look" {
                    LookCardGallery()
                } else {
                    HomeView()
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
