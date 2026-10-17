/**
 Mascot (design system): Kuku the slow loris, hugging a branch in the wild, as the owner's guide
 "Kira.Mascot · Kuku — Identitas & panduan" draws it. Three expressions and no more: Tenang (calm),
 Senang (happy) and Bangga (proud), never sad; in onboarding, empty states, the weekly summary and
 small celebrations (an account paid off, a band reached, an emergency-fund milestone), and (face
 crop) as Kira's chat avatar. Never in the Kira Peduli sheet, on heavy arrears, in error messages
 or lock-screen notifications, and never as a pet: no clothes, no cage, no extra accessories.
 200–250 pt in onboarding and celebrations, 120–160 pt in empty states. Kuku keeps the guide's
 proportions and colours in both themes, so each expression is one image; only the ground circle
 behind Kuku follows the theme.
 */
import SwiftUI

/** Kuku the slow loris in one of three expressions. */
struct KiraMascot: View {
    /** Kuku's three expressions; there is no sad one. */
    enum Expression: String, CaseIterable {
        /** Tenang, "Tidak perlu buru-buru.": onboarding, empty states, the weekly summary. */
        case calm
        /** Senang, "Satu langkah sudah tercatat.": a transaction saved, a step done. */
        case happy
        /** Bangga, "Ini hasil langkah kecilmu.": an account paid off, a band reached. */
        case proud

        var label: LocalizedStringResource {
            switch self {
            case .calm: "ds.mascot.calm"
            case .happy: "ds.mascot.happy"
            case .proud: "ds.mascot.proud"
            }
        }
    }

    /** How much of Kuku shows. */
    enum Crop: CaseIterable {
        /** The whole loris on its branch. */
        case full
        /**
         The head only. The calm face is the guide's chat avatar whole: Kuku on its round ground with
         the pandan sparkle that marks Kira's replies.
         */
        case face
    }

    private let expression: Expression
    private let size: CGFloat
    private let isFramed: Bool
    private let crop: Crop

    /** `isFramed` puts Kuku on the guide's soft ground circle; turn it off when Kuku stands on a Scenery. */
    init(_ expression: Expression = .calm, size: CGFloat = 160, isFramed: Bool = true, crop: Crop = .full) {
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
            Image(decorative: "mascot-\(expression.rawValue)-face").resizable().frame(width: size, height: size)
        } else if isFramed {
            let inset = size * 8 / 240
            Image(decorative: "mascot-\(expression.rawValue)").resizable()
                .frame(width: size, height: size)
                .background(Circle().fill(.artMascotGround).padding(inset))
                .clipShape(Circle().inset(by: inset))
        } else {
            Image(decorative: "mascot-\(expression.rawValue)").resizable().frame(width: size, height: size)
        }
    }
}

#if DEBUG
    #Preview { GalleryBrand().galleryPage() }
#endif
