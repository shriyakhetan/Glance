import SwiftUI
import UIKit

/// How an image is framed inside its container, mirroring the two levels Figma
/// actually exports:
///
/// 1. An **art rect** — a sized, offset box, in the comp's own points. The feed's
///    cards are drawn 180pt wide, so `reference` is 180 and everything scales
///    from there.
/// 2. A **cover fill** inside that rect, which may itself be biased up or down
///    rather than centred.
///
/// So Figma's `290×385 at (-55, 0)` inside a 180-wide card becomes
/// `ImageCrop(width: 290, height: 385, x: -55, y: 0)`.
struct ImageCrop: Hashable {
    /// Art rect width in comp points.
    var width: CGFloat = 180
    /// Art rect height in comp points. `nil` matches the container's height.
    var height: CGFloat?
    /// Art rect origin in comp points, relative to the container's origin.
    var x: CGFloat = 0
    var y: CGFloat = 0
    /// Vertical bias of the cover-fill inside the art rect: 0 top … 1 bottom.
    var fillBias: CGFloat = 0.5
    /// The container width these numbers were measured against.
    var reference: CGFloat = 180
}

/// Renders `name` into the container using `crop`'s art rect and fill bias.
///
/// `scaledToFill` can only centre its overflow, which is why the geometry is
/// resolved by hand here.
struct CroppedImage: View {
    let name: String
    var crop: ImageCrop = ImageCrop()

    var body: some View {
        GeometryReader { geometry in
            let box = geometry.size
            let scale = box.width / crop.reference
            let rect = CGSize(
                width: crop.width * scale,
                height: (crop.height.map { $0 * scale }) ?? box.height
            )
            let art = coverSize(for: rect)

            Image(name)
                .resizable()
                .frame(width: art.width, height: art.height)
                // Centre the cover horizontally, bias it vertically, then place
                // the whole art rect at its designed offset.
                .offset(
                    x: -(art.width - rect.width) / 2 + crop.x * scale,
                    y: -(art.height - rect.height) * crop.fillBias + crop.y * scale
                )
                .frame(width: box.width, height: box.height, alignment: .topLeading)
        }
        .clipped()
    }

    /// Smallest aspect-preserving size that covers `rect`.
    /// `UIImage(named:)` hits UIKit's own cache, so this is cheap in layout.
    private func coverSize(for rect: CGSize) -> CGSize {
        guard let source = UIImage(named: name)?.size, source.width > 0, source.height > 0 else {
            return rect
        }
        let scale = max(rect.width / source.width, rect.height / source.height)
        return CGSize(width: source.width * scale, height: source.height * scale)
    }
}
