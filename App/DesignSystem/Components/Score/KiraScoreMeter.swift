/**
 ScoreMeter (design system): the Kira Score as a position on a 0–100 ribbon split into its three
 zones, with the big number and its band. The zone edges (40 and 80) always show. Under it go the
 caption "Hanya simulasi · dihitung mesin, bukan AI" and an Accordion "Gimana Ngitungnya?" with
 the formula; on the detail screen, the band's plant (KiraIllustration.plant(for:)) sits above it.
 No half-circle gauge, no counting up from 0, no comparison with other people.
 */
import Domain
import SwiftUI

/** The Kira Score, its band and its place on the scale. */
struct KiraScoreMeter: View {
    private let score: Score
    private let delta: Int?
    private let deltaLabel: LocalizedStringResource?

    /**
     `score` comes from the score engine, never from AI; `delta` is the change since last month, or
     since what `deltaLabel` names ("dari September").
     */
    init(_ score: Score, delta: Int? = nil, deltaLabel: LocalizedStringResource? = nil) {
        self.score = score
        self.delta = delta
        self.deltaLabel = deltaLabel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                HStack(alignment: .firstTextBaseline, spacing: KiraSpacing.space1) {
                    Text(score.value, format: .number).kiraFont(.score).foregroundStyle(.ink)
                    Text("ds.meter.outOf").font(KiraFont.display(17, .bold, relativeTo: .headline)).foregroundStyle(
                        .inkMuted)
                }
                HStack(spacing: KiraSpacing.space2) {
                    KiraBandPill(score.band)
                    if let delta {
                        deltaText(delta).font(.footnote.weight(.medium)).kiraLineHeight(18, size: 13)
                            .foregroundStyle(.inkMuted)
                    }
                }
            }
            track
            WeightedRow(weights: ScoreBand.allCases.map { CGFloat($0.span) }, spacing: 3) {
                ForEach(ScoreBand.allCases, id: \.self) { band in
                    Text(band.scaleLabel)
                        .font(.caption.weight(band == score.band ? .semibold : .medium)).kiraLineHeight(16, size: 12)
                        .foregroundStyle(band == score.band ? Color.ink : Color.inkMuted)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("ds.meter.label \(score.value) \(Text(score.band.title))"))
        .accessibilityValue(delta.map { deltaText($0) } ?? Text(score.band.scaleLabel))
    }

    private func deltaText(_ delta: Int) -> Text {
        let number = Text(delta, format: .number.sign(strategy: .always(includingZero: false)))
        guard let deltaLabel else { return Text("ds.meter.delta \(number)") }
        return Text("ds.meter.deltaSince \(number) \(Text(deltaLabel))")
    }

    private var track: some View {
        WeightedRow(weights: ScoreBand.allCases.map { CGFloat($0.span) }, spacing: 3) {
            ForEach(ScoreBand.allCases, id: \.self) { band in
                Capsule().fill(band == score.band ? band.color : Color.track).frame(height: 12)
            }
        }
        .frame(height: 12)
        /** The 24 pt mark overhangs the 12 pt track, as in the design system, without taking room. */
        .overlay(alignment: .leading) {
            GeometryReader { proxy in
                Circle()
                    .strokeBorder(score.band.color, lineWidth: 5)
                    .background(Circle().fill(.surfaceRaised))
                    .frame(width: 24, height: 24)
                    .offset(x: proxy.size.width * score.fraction - 12)
            }
        }
    }
}

#if DEBUG
    #Preview { GalleryScore().galleryPage() }
#endif
