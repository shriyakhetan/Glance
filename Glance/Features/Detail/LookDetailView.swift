import SwiftUI

/// A look's own page (`Look L2`, 6215:7530): the look large, what can be done
/// with it, the pieces in it, and more like them. Opened from its look card,
/// which zooms into it.
struct LookDetailView: View {
    let look: LookDetail

    @Environment(\.dismiss) private var dismiss
    @State private var liked = false
    @State private var disliked = false
    @State private var askSheet: AskGlanceContext?
    @State private var toast: String?
    /// The tallest product tile's height, which every tile in the grid —
    /// `Find Similar` too — is given.
    @State private var tileHeight: CGFloat?

    private static let imageSize = CGSize(width: 240, height: 424)
    /// How far the actions and the lock screen button hang past the photo.
    private static let overhang: CGFloat = 20

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(look.title)
                        .glanceText(.displaySmall)
                        .foregroundStyle(GlanceColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, Space.xl)
                        .accessibilityAddTraits(.isHeader)

                    lookImage
                        .frame(maxWidth: .infinity)
                        .padding(.top, Space.xl)
                        .padding(.bottom, Self.overhang)

                    ShopProductList(title: "Shop the look", products: look.pieces, onSelect: open) {
                        changeOutfitButton
                    }
                    .padding(.horizontal, Space.lg)
                    .padding(.top, Space.xxl)

                    moreLikeThis
                        .padding(.top, Space.xxl)
                }
                .padding(.top, Space.lg)
                // Clear the composer and the gap beneath it.
                .padding(.bottom, AskGlanceBarMetrics.reservedHeight + Space.lg)
                .glanceContentColumn()
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .top, spacing: 0) {
                GlanceLogoBar(onBack: { dismiss() })
            }

            if let toast {
                DetailToast(text: toast)
                    .padding(.bottom, AskGlanceBarMetrics.reservedHeight + Space.sm)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            AskGlanceBar(
                stage: .onL2,
                onAsk: { ask("Glance AI", look.title) },
                onAttach: { ask("Add an image", look.title) }
            )
        }
        // The composer is measured from the physical bottom edge.
        .ignoresSafeArea(edges: .bottom)
        .background(.black)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $askSheet) { AskGlanceView(context: $0) }
        .sensoryFeedback(.selection, trigger: liked)
        .sensoryFeedback(.selection, trigger: disliked)
        .task(id: toast) {
            guard toast != nil else { return }
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.smooth) { toast = nil }
        }
    }

    // MARK: - The look

    /// `2` (6215:7531) — the photograph at 240×424 on its own corners, with
    /// its actions hung over the right edge and the lock screen button over
    /// its foot, each half on and half off.
    private var lookImage: some View {
        Color.white
            .frame(width: Self.imageSize.width, height: Self.imageSize.height)
            .overlay {
                // `image 5795` — 293×522, a touch wider than the frame, set
                // from the top so the face keeps its place.
                Image(look.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 293.4, height: 521.6)
                    .offset(x: 0.73, y: (521.6 - Self.imageSize.height) / 2 - 1.33)
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
            .overlay(alignment: .topTrailing) {
                actions
                    .offset(x: Self.overhang, y: 140)
            }
            .overlay(alignment: .bottom) {
                lockScreenButton
                    .offset(y: Self.overhang)
            }
            .accessibilityElement(children: .contain)
    }

    /// `Frame 2147240032` — like, not for me, share.
    private var actions: some View {
        VStack(spacing: Space.md) {
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.6)) { liked.toggle() }
            } label: {
                GlassCircleLabel {
                    Image(systemName: liked ? "heart.fill" : "heart")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(liked ? Color(hex: 0xFF3B30) : GlanceColor.textPrimary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(liked ? "Remove from wishlist" : "Save to wishlist")

            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.6)) { disliked.toggle() }
            } label: {
                GlassCircleLabel {
                    Image(disliked ? "ic-thumb-down-filled" : "ic-thumb-down")
                        .resizable()
                        .frame(width: disliked ? 20 : 16, height: disliked ? 20 : 16)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Less like this")
            .accessibilityAddTraits(disliked ? .isSelected : [])

            ShareLink(
                item: Image(look.image),
                subject: Text(look.title),
                preview: SharePreview(look.title, image: Image(look.image))
            ) {
                GlassCircleLabel {
                    Image("ic-share-forward")
                        .resizable()
                        .frame(width: 14.6, height: 13.6)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Share")
        }
    }

    /// `CTA` (6215:7586) — a glass pill at the photograph's foot.
    private var lockScreenButton: some View {
        Button {
            withAnimation(.smooth) { toast = "Added to your Lock Screen" }
        } label: {
            Text("Add to Lockscreen")
                .glanceText(.labelMedium)
                .foregroundStyle(GlanceColor.textPrimary)
                .frame(width: 160, height: 40)
                .liquidGlass(in: Capsule(), interactive: true) { view in
                    view
                        .background(.ultraThinMaterial, in: Capsule())
                        .background(Color.black.opacity(0.2), in: Capsule())
                        .overlay { Capsule().strokeBorder(Color.white.opacity(0.4), lineWidth: 1) }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: toast) { _, new in new != nil }
    }

    /// `Change Outfit` — the page's one filled button, white with black ink.
    private var changeOutfitButton: some View {
        Button { ask("Change Outfit", look.title) } label: {
            Text("Change Outfit")
                .glanceText(.labelMedium)
                .foregroundStyle(Color.black)
                .frame(width: 115, height: 32)
                .background(Color.white, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(FeedCardButtonStyle())
    }

    // MARK: - More

    /// `Similar Products` (6215:7588) — two columns of products, the way into
    /// more closing the second.
    private var moreLikeThis: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            SectionTitle(title: "More I think you’ll like")
                .padding(.horizontal, Space.lg)

            HStack(alignment: .top, spacing: Space.sm) {
                VStack(spacing: Space.sm) {
                    ForEach(look.more.prefix(2)) { tile($0) }
                }
                VStack(spacing: Space.sm) {
                    ForEach(look.more.dropFirst(2)) { tile($0) }
                    FindSimilarCard(height: tileHeight ?? 366, frontImage: "similar-front-jacket") { ask("Find similar", look.title) }
                }
            }
            .padding(.horizontal, GlanceLayout.feedGutter)
        }
    }

    /// Each tile reports its height and is held to the tallest, so the grid's
    /// four tiles stand level whatever their names and prices wrap to.
    private func tile(_ product: ShopProduct) -> some View {
        Button { open(product) } label: {
            ShopProductTile(product: product)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                    if height > (tileHeight ?? 0) { tileHeight = height }
                }
                .frame(height: tileHeight)
        }
        .buttonStyle(FeedCardButtonStyle())
    }

    private func open(_ product: ShopProduct) {
        ask("\(product.brand) \(product.name)", look.title)
    }

    private func ask(_ title: String, _ prompt: String) {
        askSheet = AskGlanceContext(title: title, prompt: prompt)
    }
}

#Preview {
    NavigationStack {
        LookDetailView(look: LookRepository.shared.look(id: "airport"))
    }
    .preferredColorScheme(.dark)
}
