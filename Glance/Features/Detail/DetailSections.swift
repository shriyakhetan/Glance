import SwiftUI

// MARK: - Product rows

/// `Shop the look` / `Suggested Products` (6215:7547, 8961:8298) — a section
/// title, then the products as rows split by hairlines.
struct ShopProductList<Trailing: View>: View {
    let title: String
    let products: [ShopProduct]
    var onSelect: (ShopProduct) -> Void
    @ViewBuilder var trailing: Trailing

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            HStack {
                Text(title)
                    .glanceText(.displaySmall)
                    .foregroundStyle(GlanceColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: Space.md)
                trailing
            }

            VStack(spacing: Space.xl) {
                ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                    if index > 0 {
                        // `Vector 9948` — white at 20%, half a point.
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 0.5)
                    }
                    Button { onSelect(product) } label: {
                        ShopProductRow(product: product)
                    }
                    .buttonStyle(FeedCardButtonStyle())
                }
            }
        }
    }
}

extension ShopProductList where Trailing == EmptyView {
    init(title: String, products: [ShopProduct], onSelect: @escaping (ShopProduct) -> Void) {
        self.init(title: title, products: products, onSelect: onSelect) { EmptyView() }
    }
}

/// `Product Medium With Details` (6215:7548) — the thumbnail beside the
/// product's name, price and why Glance picked it.
struct ShopProductRow: View {
    let product: ShopProduct

    var body: some View {
        HStack(spacing: Space.lg) {
            ProductThumbnail(product: product)

            VStack(alignment: .leading, spacing: Space.md) {
                VStack(alignment: .leading, spacing: Space.xs) {
                    Text("\(product.brand) - \(product.name)")
                        .glanceText(.labelMedium)
                        .foregroundStyle(GlanceColor.textPrimary)
                        .lineLimit(1)

                    // `Price Container` — now in Body/Medium, before a size
                    // down at 40% and struck through.
                    HStack(spacing: 5.29) {
                        Text(product.price.current)
                            .glanceText(.bodyMedium)
                            .foregroundStyle(GlanceColor.textPrimary)
                        Text(product.price.original)
                            .glanceText(.bodyCaption)
                            .foregroundStyle(GlanceColor.textDisabled)
                            .strikethrough(true, color: GlanceColor.textDisabled)
                    }
                }

                Text(product.note)
                    .glanceText(.bodyCaption)
                    .foregroundStyle(GlanceColor.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

/// The 68×86 thumbnail: a cut-out stands at its own size on the light ground;
/// a photograph fills the frame.
struct ProductThumbnail: View {
    let product: ShopProduct

    private static let shape = RoundedRectangle(cornerRadius: 10.32, style: .continuous)

    var body: some View {
        Color(hex: 0xF0F0F0)
            .frame(width: 68, height: 86)
            .overlay {
                switch product.art {
                case .cutout(let thumb, _):
                    Image(product.image)
                        .resizable()
                        .frame(width: thumb.width, height: thumb.height)
                case .scene:
                    Image(product.image)
                        .resizable()
                        .scaledToFill()
                }
            }
            .clipShape(Self.shape)
            .overlay { Self.shape.strokeBorder(Color.white.opacity(0.1), lineWidth: 0.6) }
            .accessibilityHidden(true)
    }
}

// MARK: - Tiles

/// `New Card` (8961:7210) — a product on white over a dark panel: the brand in
/// capitals and the name, then the price as every product card sets it — now,
/// what it was, the saving, which drops to its own line when it won't fit.
///
/// Flexible below the photograph, so a grid can give every tile one height;
/// the price stays pinned to the foot.
struct ShopProductTile: View {
    let product: ShopProduct

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.white
                .frame(height: 234)
                .overlay { art }
                .clipped()
                .overlay(alignment: .topTrailing) {
                    WishlistButton(tone: .scrim)
                        .padding(.top, Space.md)
                        .padding(.trailing, 11.4)
                }

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: Space.sm) {
                    Text(product.brand.uppercased())
                        .glanceText(.labelMedium)
                        .foregroundStyle(GlanceColor.textPrimary)
                    Text(product.name)
                        .glanceText(.bodyCaption)
                        .foregroundStyle(GlanceColor.textTertiary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: Space.lg)

                PriceRow(price: product.price)
            }
            .padding(.horizontal, Space.md)
            .padding(.top, Space.md)
            .padding(.bottom, Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(hex: 0x272727))
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
    }

    @ViewBuilder
    private var art: some View {
        switch product.art {
        case .cutout(_, let tile):
            Image(product.image)
                .resizable()
                .frame(width: tile.width, height: tile.height)
        case .scene:
            Image(product.image)
                .resizable()
                .scaledToFill()
        }
    }
}

// MARK: - Controls

/// A 40pt round control on Liquid Glass — the look page's actions (6215:7533),
/// which the comp draws as a frosted disc in a white hairline.
struct GlassCircleLabel<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(width: 40, height: 40)
            .liquidGlass(in: Circle(), interactive: true) { view in
                view
                    .background(.ultraThinMaterial, in: Circle())
                    .background(Color.black.opacity(0.2), in: Circle())
                    .overlay { Circle().strokeBorder(Color.white.opacity(0.4), lineWidth: 1) }
            }
            .contentShape(Circle())
    }
}

/// A short confirmation that rises over the composer and goes on its own.
struct DetailToast: View {
    let text: String

    var body: some View {
        Text(text)
            .glanceText(.labelMedium)
            .foregroundStyle(GlanceColor.textPrimary)
            .padding(.horizontal, Space.lg)
            .frame(height: 40)
            .liquidGlass(in: Capsule()) { view in
                view.background(.ultraThinMaterial, in: Capsule())
            }
            .accessibilityAddTraits(.isStaticText)
    }
}
