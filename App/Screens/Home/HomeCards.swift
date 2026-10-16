/**
 Beranda's tappable cards: the Kira Score (its plant, number, band and change) and the weekly
 summary when it is ready.
 */
import Domain
import SwiftUI

struct HomeScoreCard: View {
    let score: ScoreSummary
    let onOpen: () -> Void

    var body: some View {
        KiraTapCard(KiraIllustrationName.plant(for: score.band), label: label, action: onOpen) {
            Text("home.score.title").font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
            HStack(spacing: KiraSpacing.space2) {
                Text(score.score, format: .number)
                    .font(KiraFont.display(28, .heavy, relativeTo: .title).monospacedDigit())
                    .kiraLineHeight(34, size: 28, natural: 1.26, relativeTo: .title)
                    .tracking(-0.56)
                    .foregroundStyle(.ink)
                KiraBandPill(score.band, size: .small)
                if let trend = trendText {
                    trend.font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                }
            }
        }
    }

    private var trendText: Text? {
        switch score.trend {
        case .rise(let points): Text("home.score.up \(points)")
        case .fall(let points): Text("home.score.down \(points)")
        case .unchanged: Text("home.score.unchanged")
        case .startingPoint: Text("home.score.startingPoint")
        case .firstCheck: Text("home.score.firstCheck")
        case .none: nil
        }
    }

    /** "Kira Score 66, pita Bertahan, naik 4 poin. Buka detail". */
    private var label: Text {
        let band = Text(score.band.title)
        switch score.trend {
        case .rise(let points): return Text("home.score.label.up \(score.score) \(band) \(points)")
        case .fall(let points): return Text("home.score.label.down \(score.score) \(band) \(points)")
        case .unchanged: return noted(Text("home.score.unchanged"), band: band)
        case .startingPoint: return noted(Text("home.score.startingPoint"), band: band)
        case .firstCheck: return noted(Text("home.score.firstCheck"), band: band)
        case .none: return Text("home.score.label \(score.score) \(band)")
        }
    }

    private func noted(_ note: Text, band: Text) -> Text {
        Text("home.score.label.note \(score.score) \(band) \(note)")
    }
}

struct HomeWeeklyCard: View {
    let range: DayRange
    let onOpen: () -> Void

    var body: some View {
        KiraTapCard(.letter, label: Text("home.weekly.label \(firstEnd) \(lastEnd)"), action: onOpen) {
            Text("home.weekly.title").font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
            Text("home.weekly.subtitle \(firstEnd) \(lastEnd)")
                .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
        }
    }

    /** The first day, as much of it as the last day does not already say. */
    private var firstEnd: Text {
        switch range.shape {
        case .sameMonth: Text(range.firstDay, format: .number)
        case .sameYear: Text(range.first, format: .kiraDayMonth)
        case .acrossYears: Text(range.first, format: .kiraDate)
        }
    }

    private var lastEnd: Text { Text(range.last, format: .kiraDate) }
}
