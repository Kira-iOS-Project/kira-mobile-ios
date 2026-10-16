/**
 How a Kira Score band looks and reads: its colour family (healthy, coping, vulnerable with -soft and
 -line), its word, and its place on the meter's scale. A band always carries colour, word and
 glyph together, so it reads without colour.
 */
import Domain
import SwiftUI

extension ScoreBand {
    /** The band's colour: text, glyph, bar fill. */
    var color: Color {
        switch self {
        case .healthy: .healthy
        case .coping: .coping
        case .vulnerable: .vulnerable
        }
    }

    /** The band's soft background. */
    var softColor: Color {
        switch self {
        case .healthy: .healthySoft
        case .coping: .copingSoft
        case .vulnerable: .vulnerableSoft
        }
    }

    /** The band's 1 pt border. */
    var lineColor: Color {
        switch self {
        case .healthy: .healthyLine
        case .coping: .copingLine
        case .vulnerable: .vulnerableLine
        }
    }

    /** The band's name: Sehat, Bertahan, Rentan. */
    var title: LocalizedStringResource {
        switch self {
        case .healthy: "ds.band.healthy"
        case .coping: "ds.band.coping"
        case .vulnerable: "ds.band.vulnerable"
        }
    }

    /** The band's label under the meter: "Rentan 0–39", "Bertahan 40–79", "Sehat 80+". */
    var scaleLabel: LocalizedStringResource {
        switch self {
        case .healthy: "ds.band.healthy.scale"
        case .coping: "ds.band.coping.scale"
        case .vulnerable: "ds.band.vulnerable.scale"
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
            case .healthy:
                Circle()
            case .coping:
                Circle().mask(alignment: .trailing) { Rectangle().frame(width: 4.5) }
            case .vulnerable:
                EmptyView()
            }
        }
        .frame(width: 9, height: 9)
        .frame(width: 12, height: 12)
        .accessibilityHidden(true)
    }
}
