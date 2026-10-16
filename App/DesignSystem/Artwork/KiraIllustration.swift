/**
 Illustration (design system): a flat spot illustration painted from the art-* tokens, so it
 follows the theme. 84–96 pt on cards, 120–140 pt in empty states and heroes. One meaning per
 illustration: never `piggyBank` for a debt or `cardPaidOff` for savings. No faces: those are Kuku's.
 */
import Domain
import SwiftUI

/** The spot illustrations (index.d.ts IllustrationName). */
enum KiraIllustrationName: String, CaseIterable {
    /** The Kira Score plant for the vulnerable band (Rentan). */
    case sprout
    /** The Kira Score plant for the coping band (Bertahan). */
    case growing
    /** The Kira Score plant for the healthy band (Sehat); also "it worked". */
    case bloom
    /** The rooster piggy bank: emergency fund and savings. */
    case piggyBank = "piggy-bank"
    /** A card paid off: debt payoff and celebrations. */
    case cardPaidOff = "card-paid-off"
    /** Kira Peduli, the help sheet's head. */
    case care
    /** Recording, by chat or receipt. */
    case receipt
    /** Protection (BPJS, insurance); also "it failed" in dialogs. */
    case umbrella
    /** Legality checks and account security. */
    case shield
    /** Bills and instalments. */
    case calendar
    /** The financial ladder. */
    case stairs
    /** Learning modules. */
    case book
    /** The weekly summary. */
    case letter
    /** Privacy and the app lock. */
    case padlock
    /** The community directory. */
    case community

    /** The Kira Score plant of a band (design system: plantFor). */
    static func plant(for band: ScoreBand) -> Self {
        switch band {
        case .vulnerable: .sprout
        case .coping: .growing
        case .healthy: .bloom
        }
    }
}

/** A spot illustration, hidden from VoiceOver unless it carries meaning the text around it does not. */
struct KiraIllustration: View {
    private let name: KiraIllustrationName
    private let size: CGFloat
    private let label: LocalizedStringResource?

    init(_ name: KiraIllustrationName, size: CGFloat = 120, label: LocalizedStringResource? = nil) {
        self.name = name
        self.size = size
        self.label = label
    }

    var body: some View {
        Image(decorative: "illustration-\(name.rawValue)")
            .resizable()
            .frame(width: size, height: size)
            .artworkLabel(label)
    }
}

#if DEBUG
    #Preview { GalleryIllustrations().galleryPage() }
#endif
