// Illustration (design system): a flat spot illustration painted from the ilu-* tokens, so it
// follows the theme. 84–96 pt on cards, 120–140 pt in empty states and heroes. One meaning per
// illustration: never celengan for a debt or kartu-lunas for savings. No faces: those are Kuku's.
import Domain
import SwiftUI

/// The spot illustrations (index.d.ts IllustrationName).
enum KiraIllustrationName: String, CaseIterable {
    /// The Kira Score plant for Rentan.
    case tunas
    /// The Kira Score plant for Bertahan.
    case tumbuh
    /// The Kira Score plant for Sehat; also "it worked".
    case mekar
    /// The rooster piggy bank: emergency fund and savings.
    case celengan
    /// A card paid off: debt payoff and celebrations.
    case kartuLunas = "kartu-lunas"
    /// Kira Peduli, the help sheet's head.
    case peduli
    /// Recording, by chat or receipt.
    case struk
    /// Protection (BPJS, insurance); also "it failed" in dialogs.
    case payung
    /// Legality checks and account security.
    case perisai
    /// Bills and instalments.
    case kalender
    /// The financial ladder.
    case tangga
    /// Learning modules.
    case buku
    /// The weekly summary.
    case surat
    /// Privacy and the app lock.
    case gembok
    /// The community directory.
    case komunitas

    /// The Kira Score plant of a band (design system: plantFor).
    static func plant(for band: ScoreBand) -> Self {
        switch band {
        case .rentan: .tunas
        case .bertahan: .tumbuh
        case .sehat: .mekar
        }
    }
}

/// A spot illustration, hidden from VoiceOver unless it carries meaning the text around it does not.
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
        Image(decorative: "ilustrasi-\(name.rawValue)")
            .resizable()
            .frame(width: size, height: size)
            .artworkLabel(label)
    }
}

#if DEBUG
    #Preview { GalleryIllustrations().galleryPage() }
#endif
