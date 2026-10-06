import SwiftUI

/// `Top` (32:3699, 6215:8493, 4201:5150) — back, the wordmark, recently
/// viewed, the two buttons on glass as an iOS 26 bar draws them. Pin it over a
/// page with `.safeAreaInset(edge: .top)`, so content blurs through beneath.
struct GlanceLogoBar: View {
    var onBack: () -> Void
    var onRecent: () -> Void = {}

    var body: some View {
        HStack(spacing: 0) {
            BarIconButton(icon: "ic-nav-back", size: CGSize(width: 15.5, height: 13.5), label: "Back", action: onBack)

            Spacer(minLength: 0)

            Image("glance-logo")
                .resizable()
                .frame(width: 86.75, height: 24.6)
                .accessibilityLabel("Glance")

            Spacer(minLength: 0)

            BarIconButton(icon: "ic-recently-viewed", size: CGSize(width: 22, height: 22), label: "Recently viewed", action: onRecent)
        }
        .padding(.horizontal, 14.4)
        .padding(.vertical, Space.xxs)
        // Bar items track the content column; the band behind stays full width.
        .glanceContentColumn()
        .fadingBarBackground()
    }
}
