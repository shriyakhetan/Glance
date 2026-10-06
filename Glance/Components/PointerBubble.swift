import SwiftUI

/// A rounded body with a tail pointing down from its bottom edge — the
/// composer's callouts (V7, 32:1634 and 32:1668) and the price tracker's
/// `$99 now` (32:2689).
///
/// The body keeps the system's continuous corners, and the tail is unioned
/// into it so the two read as one outline: drawn as separate shapes they leave
/// a seam where they meet, which glass and hairlines both show up.
struct PointerBubble: InsettableShape {
    var cornerRadius: CGFloat
    /// From the leading edge to the tail's tip. `nil` centres it.
    var tailX: CGFloat?
    var tailWidth: CGFloat
    var tailHeight: CGFloat
    private var inset: CGFloat = 0

    init(cornerRadius: CGFloat, tailX: CGFloat? = nil, tailWidth: CGFloat, tailHeight: CGFloat) {
        self.cornerRadius = cornerRadius
        self.tailX = tailX
        self.tailWidth = tailWidth
        self.tailHeight = tailHeight
    }

    func path(in rect: CGRect) -> Path {
        let frame = rect.insetBy(dx: inset, dy: inset)
        let body = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height - tailHeight)
        let tip = rect.minX + (tailX ?? rect.width / 2)
        let halfBase = max(0, tailWidth / 2 - inset)

        // The base sits a point inside the body so the union has nothing to
        // seam along.
        var tail = Path()
        tail.move(to: CGPoint(x: tip - halfBase, y: body.maxY - 1))
        tail.addLine(to: CGPoint(x: tip, y: frame.maxY))
        tail.addLine(to: CGPoint(x: tip + halfBase, y: body.maxY - 1))
        tail.closeSubpath()

        let radius = max(0, cornerRadius - inset)
        return RoundedRectangle(cornerRadius: radius, style: .continuous)
            .path(in: body)
            .union(tail)
    }

    func inset(by amount: CGFloat) -> PointerBubble {
        var bubble = self
        bubble.inset += amount
        return bubble
    }
}
