import SwiftUI
import UIKit

/// `Add Photo` (693:181) — the chooser that opens from a visual-source tile.
///
/// Presented by hand rather than through `.sheet`, because the comp specifies
/// its own scrim (black at 70%) and `.sheet` owns its dimming.
struct AddPhotoSheet: View {
    var onCamera: () -> Void
    var onGallery: () -> Void
    var onDismiss: () -> Void

    @State private var drag: CGFloat = 0

    private let corner: CGFloat = 32

    // Sheet-local styles: `Heading/Inter/H2` and `Body/Large|Small` from the
    // node's own tokens, which the app's scale doesn't carry.
    private static let headline = GlanceTextStyle(GlanceTypeface.interSemiBold, 20, lineHeight: 28)
    private static let optionTitle = GlanceTextStyle(GlanceTypeface.interSemiBold, 16, lineHeight: 24)
    private static let optionDetail = GlanceTextStyle(GlanceTypeface.interRegular, 12, lineHeight: 18)

    var body: some View {
        VStack(spacing: Space.xl) {
            Capsule()
                .fill(Color.white.opacity(0.1))
                .opacity(0.5)
                .frame(width: 39, height: 2)

            Text("Add Your Photo")
                .glanceText(Self.headline)
                .foregroundStyle(GlanceColor.textPrimary)

            VStack(spacing: Space.md) {
                option(
                    icon: "ic-camera",
                    iconSize: CGSize(width: 28.667, height: 24.667),
                    title: "Take a Photo",
                    detail: "For a quick start - front camera, good lighting.",
                    action: onCamera
                )
                option(
                    icon: "ic-gallery",
                    iconSize: CGSize(width: 28.667, height: 26),
                    title: "Upload a Photo",
                    detail: "Choose a clear front-facing photo from your gallery.",
                    action: onGallery
                )
            }
        }
        .padding(.top, Space.md)
        .padding(.horizontal, Space.xl)
        .padding(.bottom, 48)
        .frame(maxWidth: .infinity)
        .background {
            shape
                .fill(Color(hex: 0x111111, opacity: 0.6))
                .background(.ultraThinMaterial, in: shape)
        }
        .overlay {
            // Only the top edge is drawn. Stroked all the way round, the
            // hairline runs down the screen's own edges and reads as a border
            // on the app rather than the lip of a sheet — so the stroke is
            // masked to the band holding the top edge and its two corners.
            shape
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                .mask {
                    VStack(spacing: 0) {
                        Rectangle().frame(height: corner)
                        Spacer(minLength: 0)
                    }
                }
        }
        .offset(y: max(0, drag))
        .gesture(
            DragGesture()
                .onChanged { drag = $0.translation.height }
                .onEnded { value in
                    if value.translation.height > 60 {
                        onDismiss()
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { drag = 0 }
                    }
                }
        )
    }

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(topLeadingRadius: corner, topTrailingRadius: corner, style: .continuous)
    }

    private func option(
        icon: String,
        iconSize: CGSize,
        title: String,
        detail: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 62, height: 62)
                    .overlay {
                        Image(icon)
                            .resizable()
                            .frame(width: iconSize.width, height: iconSize.height)
                    }

                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .glanceText(Self.optionTitle)
                        .foregroundStyle(GlanceColor.textPrimary)
                    Text(detail)
                        .glanceText(Self.optionDetail)
                        .foregroundStyle(Color.white.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, Space.lg)
            .padding(.vertical, 20)
            .background {
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .fill(LinearGradient(
                        colors: [Color(hex: 0x111111, opacity: 0.16), Color(hex: 0x111111, opacity: 0)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
            }
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
            }
        }
        .buttonStyle(.plain)
    }
}

/// `UIImagePickerController` in camera mode — SwiftUI has no camera capture of
/// its own, and `PhotosPicker` only reads the library.
struct CameraPicker: UIViewControllerRepresentable {
    var onCapture: (Data) -> Void
    var onCancel: () -> Void

    static var isAvailable: Bool { UIImagePickerController.isSourceTypeAvailable(.camera) }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.cameraDevice = .front
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let parent: CameraPicker

        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0.9) {
                parent.onCapture(data)
            } else {
                parent.onCancel()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
        }
    }
}
