import SwiftUI

/// The speech-bubble silhouette used by the skin-tip, mascot prompt and trending
/// cards: a `radius/xl` rounded rectangle with a tail dropping from its bottom
/// edge.
///
/// Traced as **one continuous outline** rather than a rounded rect plus a
/// triangle. Two subpaths wind in opposite directions, so under the non-zero
/// fill rule their overlap cancels to a winding of zero and leaves a
/// transparent hairline between body and tail.
struct BubbleShape: Shape {
    var cornerRadius: CGFloat = Radius.xl
    var tailHeight: CGFloat = 16
    var tailWidth: CGFloat = 26
    /// Distance from the trailing edge to the tail's tip.
    var tailInset: CGFloat = 22

    func path(in rect: CGRect) -> Path {
        let bodyHeight = max(0, rect.height - tailHeight)
        let radius = max(0, min(cornerRadius, min(rect.width, bodyHeight) / 2))
        let bottom = rect.minY + bodyHeight

        // The tail has to leave from the straight run of the bottom edge; over a
        // corner arc there is no body for it to join onto.
        let tipX = min(rect.maxX - tailInset, rect.maxX - radius)
        let baseLeft = max(rect.minX + radius, tipX - tailWidth)

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))

        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.maxX, y: bottom - radius))
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: bottom - radius),
            radius: radius,
            startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false
        )

        // Bottom edge, trailing to leading, detouring down through the tail.
        path.addLine(to: CGPoint(x: tipX, y: bottom))
        path.addLine(to: CGPoint(x: tipX, y: rect.maxY))
        path.addLine(to: CGPoint(x: baseLeft, y: bottom))
        path.addLine(to: CGPoint(x: rect.minX + radius, y: bottom))
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: bottom - radius),
            radius: radius,
            startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false
        )

        path.closeSubpath()
        return path
    }
}
