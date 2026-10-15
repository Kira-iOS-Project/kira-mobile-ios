/**
 How a Kira Score band looks and reads: its colour family (sehat, bertahan, rentan with -soft and
 -line), its word, and its place on the meter's scale. A band always carries colour, word and
 glyph together, so it reads without colour.
 */
import Domain
import SwiftUI

extension ScoreBand {
    /** The band's colour: text, glyph, bar fill. */
    var color: Color {
        switch self {
        case .sehat: .sehat
        case .bertahan: .bertahan
        case .rentan: .rentan
        }
    }

    /** The band's soft background. */
    var softColor: Color {
        switch self {
        case .sehat: .sehatSoft
        case .bertahan: .bertahanSoft
        case .rentan: .rentanSoft
        }
    }

    /** The band's 1 pt border. */
    var lineColor: Color {
        switch self {
        case .sehat: .sehatLine
        case .bertahan: .bertahanLine
        case .rentan: .rentanLine
        }
    }

    /** The band's name: Sehat, Bertahan, Rentan. */
    var title: LocalizedStringResource {
        switch self {
        case .sehat: "ds.band.sehat"
        case .bertahan: "ds.band.bertahan"
        case .rentan: "ds.band.rentan"
        }
    }

    /** The band's label under the meter: "Rentan 0–39", "Bertahan 40–79", "Sehat 80+". */
    var scaleLabel: LocalizedStringResource {
        switch self {
        case .sehat: "ds.band.sehat.scale"
        case .bertahan: "ds.band.bertahan.scale"
        case .rentan: "ds.band.rentan.scale"
        }
    }
}

/**
 The band's glyph, so the band reads without colour: a full circle (Sehat), a half (Bertahan),
 an empty ring (Rentan).
 */
struct BandGlyph: View {
    let band: ScoreBand

    var body: some View {
        ZStack {
            Circle().stroke(lineWidth: 1.6)
            switch band {
            case .sehat:
                Circle()
            case .bertahan:
                Circle().mask(alignment: .trailing) { Rectangle().frame(width: 4.5) }
            case .rentan:
                EmptyView()
            }
        }
        .frame(width: 9, height: 9)
        .frame(width: 12, height: 12)
        .accessibilityHidden(true)
    }
}
