/**
 Icon (design system): a line icon for actions and navigation. It takes the colour around it
 (ink, ink-muted or pandan) and is hidden from VoiceOver: the control that holds it carries the
 name. `isFilled` is the design system's duotone, for the active destination: the outline over
 its .fill variant at 20 % opacity, as the design system paints a duotone icon's fill.
 */
import SwiftUI

/** A design-system icon at `size` points, drawn with its SF Symbol. */
struct KiraIcon: View {
    private let name: KiraIconName
    private let size: CGFloat
    private let weight: Font.Weight
    private let isFilled: Bool

    init(_ name: KiraIconName, size: CGFloat = KiraSize.icon, weight: Font.Weight = .medium, isFilled: Bool = false) {
        self.name = name
        self.size = size
        self.weight = weight
        self.isFilled = isFilled
    }

    var body: some View {
        ZStack {
            if isFilled { Image(systemName: name.systemName).symbolVariant(.fill).opacity(0.2) }
            Image(systemName: name.systemName)
        }
        .font(.system(size: size * 0.75, weight: weight))
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

#if DEBUG
    #Preview { GalleryIcons().galleryPage() }
#endif
