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

    /** `score` comes from the score engine, never from AI; `delta` is the change since last month. */
    init(_ score: Score, delta: Int? = nil) {
        self.score = score
        self.delta = delta
    }

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                HStack(alignment: .firstTextBaseline, spacing: KiraSpacing.space1) {
                    Text(score.value, format: .number).kiraFont(.score).foregroundStyle(.ink)
                    Text("ds.meter.outOf").font(.headline.weight(.bold)).foregroundStyle(.inkMuted)
                }
                HStack(spacing: KiraSpacing.space2) {
                    KiraBandPill(score.band)
                    if let delta { deltaText(delta).font(.footnote.weight(.medium)).foregroundStyle(.inkMuted) }
                }
            }
            track
            WeightedRow(weights: ScoreBand.allCases.map { CGFloat($0.span) }, spacing: 3) {
                ForEach(ScoreBand.allCases, id: \.self) { band in
                    Text(band.scaleLabel)
                        .font(.caption.weight(band == score.band ? .semibold : .medium))
                        .foregroundStyle(band == score.band ? Color.ink : Color.inkMuted)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("ds.meter.label \(score.value) \(Text(score.band.title))"))
        .accessibilityValue(delta.map { deltaText($0) } ?? Text(score.band.scaleLabel))
    }

    private func deltaText(_ delta: Int) -> Text {
        Text("ds.meter.delta \(Text(delta, format: .number.sign(strategy: .always(includingZero: false))))")
    }

    private var track: some View {
        WeightedRow(weights: ScoreBand.allCases.map { CGFloat($0.span) }, spacing: 3) {
            ForEach(ScoreBand.allCases, id: \.self) { band in
                Capsule().fill(band == score.band ? band.color : Color.track).frame(height: 12)
            }
        }
        .frame(height: 24)
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
