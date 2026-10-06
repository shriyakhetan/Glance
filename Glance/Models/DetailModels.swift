import Foundation

/// A product as a detail page lists it — as a row beside its name, price and
/// why it was picked (`Shop the look`, 6215:7547), or as a tile
/// (`More I think you'll like`, 8961:7210).
struct ShopProduct: Identifiable, Hashable {
    /// How the photograph sits in its frame.
    enum Art: Hashable {
        /// A cut-out on the light ground, at its size in the comp's 68×86
        /// thumbnail and its 194×234 tile.
        case cutout(thumb: CGSize, tile: CGSize)
        /// A photograph of the product in a setting, filling the frame.
        case scene
    }

    let id = UUID()
    var image: String
    var art: Art
    var brand: String
    var name: String
    var price: PriceTag
    /// Why Glance picked it, in a line.
    var note: String
}

/// A look's own page (`Look L2`, 6215:7530): the look, the pieces in it, and
/// more like them.
struct LookDetail: Identifiable, Hashable {
    let id: String
    var title: String
    var image: String
    /// `Shop the look`.
    var pieces: [ShopProduct]
    /// `More I think you'll like`.
    var more: [ShopProduct]
}
