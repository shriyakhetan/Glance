import SwiftUI

@main
struct GlanceApp: App {
    init() {
        FontRegistration.registerAll()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)
        }
    }
}
