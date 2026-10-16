/**
 The score card and "Gimana Ngitungnya?": the band's plant and note, the meter, what the band means,
 and the formula written out from the six indicators' points.
 */
import Domain
import SwiftUI

struct ScoreSummaryCard: View {
    let report: ScoreReport
    let onHistory: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(spacing: 6) {
                KiraIllustration(KiraIllustrationName.plant(for: report.band), size: 128)
                KiraHandNote(note, tone: noteTone, size: .small, tilt: -1)
            }
            .frame(maxWidth: .infinity)
            KiraScoreMeter(Score(report.score), delta: report.delta)
            bandMessage.font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
            Text("score.simulation").kiraFont(.caption).foregroundStyle(.inkMuted)
            KiraLink("score.history", action: onHistory)
        }
        .padding(KiraSpacing.space5)
        .kiraCard()
    }

    private var note: LocalizedStringResource {
        switch report.band {
        case .vulnerable: "score.note.vulnerable"
        case .coping: "score.note.coping"
        case .healthy: "score.note.healthy"
        }
    }

    private var noteTone: KiraHandNote.Tone {
        switch report.band {
        case .vulnerable: .muted
        case .coping: .coping
        case .healthy: .pandan
        }
    }

    /** "Kamu di pita Bertahan. Ini titik awal, bukan nilai rapor. Butuh 14 poin lagi untuk sampai ke Sehat." */
    private var bandMessage: Text {
        let band = Text(report.band.title)
        switch report.bandMessage {
        case .below(let next, let points): return Text("score.band.below \(band) \(points) \(Text(next.title))")
        case .healthy: return Text("score.band.healthy \(band)")
        case .capped: return Text("score.band.capped \(band)")
        }
    }
}

struct ScoreFormulaAccordion: View {
    let report: ScoreReport

    var body: some View {
        KiraAccordion("score.formula.title", subtitle: "score.formula.subtitle", icon: .calculator) {
            Text("score.formula.body").font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.ink)
            VStack(alignment: .leading, spacing: 0) {
                Text(sum)
                result
            }
            .kiraFont(.formula)
            .foregroundStyle(.ink)
            .padding(.vertical, 10)
            .padding(.horizontal, KiraSpacing.space3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .kiraCard(.surface, cornerRadius: KiraRadius.small)
            Text("score.formula.bands").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            Text("score.formula.method").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
        }
    }

    /** "(50 + 45 + 70 + 50 + 80 + 100) ÷ 6": data, the engine's points joined as the formula writes them. */
    private var sum: String {
        let points = ScoreFormula(report).points
        return "(" + points.map(String.init).joined(separator: " + ") + ") ÷ \(points.count)"
    }

    @ViewBuilder private var result: some View {
        let formula = ScoreFormula(report)
        if formula.isWhole {
            Text("score.formula.whole \(formula.rounded)")
        } else {
            Text("score.formula.rounded \(Text(formula.average, format: .kiraDecimal(1))) \(formula.rounded)")
        }
    }
}
