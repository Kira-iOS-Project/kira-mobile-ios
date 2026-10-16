/**
 Mascot (design system): Kuku the slow loris, hugging a branch in the wild. Calm, glad or proud,
 never sad; in onboarding, empty states, the weekly summary and celebrations, and (face crop) as
 Kira's chat avatar. Never in the Kira Peduli sheet, on heavy arrears, in error messages, or as a
 pet. 200–250 pt in onboarding and celebrations, 120–160 pt in empty states; below 48 pt use the
 logo. The colours follow the theme: each expression has a light and a dark image.
 */
import SwiftUI

/** Kuku the slow loris in one of three expressions. */
struct KiraMascot: View {
    /** Kuku's three expressions; there is no sad one. */
    enum Expression: String, CaseIterable {
        /** Default: onboarding, empty states, weekly summary. */
        case tenang
        /** First transaction saved, emergency-fund milestone. */
        case senang
        /** A debt paid off, a band reached. */
        case bangga

        var label: LocalizedStringResource {
            switch self {
            case .tenang: "ds.mascot.tenang"
            case .senang: "ds.mascot.senang"
            case .bangga: "ds.mascot.bangga"
            }
        }
    }

    /** How much of Kuku shows. */
    enum Crop: CaseIterable {
        /** The whole loris on its branch. */
        case full
        /** The head only, for the chat avatar. */
        case face
    }

    private let expression: Expression
    private let size: CGFloat
    private let isFramed: Bool
    private let crop: Crop

    /** `isFramed` puts Kuku in a soft green circle; turn it off when Kuku stands on a Scenery. */
    init(_ expression: Expression = .tenang, size: CGFloat = 160, isFramed: Bool = true, crop: Crop = .full) {
        self.expression = expression
        self.size = size
        self.isFramed = isFramed
        self.crop = crop
    }

    var body: some View {
        art.artworkLabel(expression.label)
    }

    @ViewBuilder private var art: some View {
        if crop == .face {
            Image(decorative: "kuku-\(expression.rawValue)-wajah").resizable().frame(width: size, height: size)
        } else if isFramed {
            let inset = size * 8 / 240
            Image(decorative: "kuku-\(expression.rawValue)").resizable()
                .frame(width: size, height: size)
                .background(Circle().fill(.iluHijauMuda).padding(inset))
                .clipShape(Circle().inset(by: inset))
        } else {
            Image(decorative: "kuku-\(expression.rawValue)").resizable().frame(width: size, height: size)
        }
    }
}

#if DEBUG
    #Preview { GalleryBrand().galleryPage() }
#endif
