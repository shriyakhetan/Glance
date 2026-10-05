import CoreImage
import SwiftUI
import UIKit

/// Derives a card's scrim colour from its own photograph, so the fade at the
/// foot of the image settles into a colour that belongs to the picture.
///
/// The recipe, in three steps: average the band of the photo the scrim covers,
/// convert to HSL, then keep the hue but force the lightness and cap the
/// saturation — dark enough for white text, muted enough not to shout, and
/// near-greys snapped to true grey so a neutral photo doesn't pick up a cast.
///
/// The V7 look card's own colours check out against it: its scrim `#284358`
/// is H206 S0.38 **L0.25**, and the panel under it, `#203546`, is the same hue
/// and saturation at **L0.20**.
enum ImageTone {
    /// The scrim over the photo.
    static let scrimLightness = 0.25
    /// The panel the scrim settles into, a step darker on the same hue.
    static let panelLightness = 0.20
    static let saturationCap = 0.55
    static let greySnap = 0.05

    /// The share of the photo, from the bottom, that is averaged — the band
    /// the caption scrim covers (112 of the comp's 302).
    static let sampledBand = 0.37

    /// `name`'s tone at `lightness`, or `fallback` if the photo can't be read.
    static func color(for name: String, lightness: Double, fallback: Color) -> Color {
        guard let source = averageColor(of: name) else { return fallback }
        var hsl = HSL(rgb: source)
        hsl.l = lightness
        hsl.s = min(hsl.s, saturationCap)
        if hsl.s < greySnap { hsl.s = 0 }
        let (r, g, b) = hsl.rgb
        return Color(.sRGB, red: r, green: g, blue: b)
    }

    // MARK: - Sampling

    private static let context = CIContext(options: [.workingColorSpace: NSNull()])
    /// Keyed by image name. Sampling is one Core Image pass, but cards ask on
    /// every render, so each photo is read once.
    private static let cache = NSCache<NSString, UIColor>()

    private static func averageColor(of name: String) -> (r: Double, g: Double, b: Double)? {
        if let cached = cache.object(forKey: name as NSString) {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
            cached.getRed(&r, green: &g, blue: &b, alpha: nil)
            return (Double(r), Double(g), Double(b))
        }

        guard let cgImage = UIImage(named: name)?.cgImage else { return nil }
        let image = CIImage(cgImage: cgImage)
        let extent = image.extent
        // Core Image's origin is bottom-left, so the foot of the photo is y = 0.
        let band = CGRect(x: extent.minX, y: extent.minY, width: extent.width, height: extent.height * sampledBand)

        guard let average = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: image,
            kCIInputExtentKey: CIVector(cgRect: band)
        ])?.outputImage else { return nil }

        var pixel = [UInt8](repeating: 0, count: 4)
        context.render(
            average,
            toBitmap: &pixel,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)
        )

        let rgb = (r: Double(pixel[0]) / 255, g: Double(pixel[1]) / 255, b: Double(pixel[2]) / 255)
        cache.setObject(UIColor(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: 1), forKey: name as NSString)
        return rgb
    }
}

/// Hue 0…360, saturation and lightness 0…1.
private struct HSL {
    var h: Double
    var s: Double
    var l: Double

    init(rgb: (r: Double, g: Double, b: Double)) {
        let (r, g, b) = rgb
        let maxC = max(r, g, b), minC = min(r, g, b)
        let d = maxC - minC

        l = (maxC + minC) / 2
        h = 0
        s = 0

        if d != 0 {
            s = d / (1 - abs(2 * l - 1))

            if maxC == r { h = ((g - b) / d).truncatingRemainder(dividingBy: 6) }
            else if maxC == g { h = (b - r) / d + 2 }
            else { h = (r - g) / d + 4 }

            h *= 60
            if h < 0 { h += 360 }
        }
    }

    /// Back to RGB, each channel rounded to an 8-bit step as the recipe does.
    var rgb: (Double, Double, Double) {
        let c = (1 - abs(2 * l - 1)) * s
        let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = l - c / 2

        let (r, g, b): (Double, Double, Double)
        switch h {
        case ..<60: (r, g, b) = (c, x, 0)
        case ..<120: (r, g, b) = (x, c, 0)
        case ..<180: (r, g, b) = (0, c, x)
        case ..<240: (r, g, b) = (0, x, c)
        case ..<300: (r, g, b) = (x, 0, c)
        default: (r, g, b) = (c, 0, x)
        }

        func channel(_ v: Double) -> Double { ((v + m) * 255).rounded() / 255 }
        return (channel(r), channel(g), channel(b))
    }
}
