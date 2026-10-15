// Depth in Kira comes from a 1 pt hairline and the surface colour, never a shadow: every card,
// badge, tile and bubble carries a border. These modifiers draw it inside the shape, so a border
// never changes a view's size.
import SwiftUI

extension View {
    /// A 1 pt border inside a continuous rounded rectangle.
    func hairline(_ color: Color = .hairline, cornerRadius: CGFloat) -> some View {
        overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(color, lineWidth: 1)
        }
    }

    /// A 1 pt border inside a capsule: buttons, pills, tags.
    func capsuleHairline(_ color: Color = .hairline) -> some View {
        overlay { Capsule().strokeBorder(color, lineWidth: 1) }
    }

    /// A card: `fill` behind the content in a continuous rounded rectangle, with a hairline.
    func kiraCard(
        _ fill: Color = .surfaceRaised, border: Color = .hairline, cornerRadius: CGFloat = KiraRadius.large
    ) -> some View {
        background(fill, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .hairline(border, cornerRadius: cornerRadius)
    }
}
