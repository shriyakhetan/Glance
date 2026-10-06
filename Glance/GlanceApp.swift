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
                } else if DebugLaunch.gallery == "signal" {
                    SignalCardGallery()
                } else if DebugLaunch.gallery == "filler" {
                    PromptCardGallery()
                } else if DebugLaunch.gallery == "tips" {
                    TipCardGallery()
                } else {
                    HomeView()
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
