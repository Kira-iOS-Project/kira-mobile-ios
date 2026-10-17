/**
 The sentences of Riwayat Kira Score, written on the device from the numbers the API sends (board
 RiwayatSkor, RiwayatSkorTahun): "+4 dari September", "Naik 15 poin sejak Mei. Pelan, tapi terus
 tumbuh.", the chart's description for VoiceOver, and the changed indicators' rows and footer.
 */
import Domain
import SwiftUI

extension ScoreHistoryRange {
    /** 6 Bulan, 1 Tahun. */
    var title: LocalizedStringResource {
        switch self {
        case .sixMonths: "score.history.range.sixMonths"
        case .oneYear: "score.history.range.oneYear"
        }
    }
}

extension ScoreHistory {
    /** "+4 dari September", or nil without a month before. */
    var deltaText: LocalizedStringResource? {
        guard let delta = deltaFromPrevious, let month = previousMonth?.date.formatted(.kiraMonth) else {
            return nil
        }
        if delta > 0 { return "score.history.delta.up \(delta) \(month)" }
        if delta < 0 { return "score.history.delta.down \(-delta) \(month)" }
        return "score.history.delta.flat \(month)"
    }

    /** "Naik 15 poin sejak Mei. Pelan, tapi terus tumbuh.", or nil with fewer than two months. */
    var trendText: LocalizedStringResource? {
        guard let trend = ScoreHistoryTrend(points) else { return nil }
        let since = trend.since.date.formatted(trend.crossesYear ? .kiraMonthYear : .kiraMonth)
        switch trend.direction {
        case .rising: return "score.history.trend.up \(trend.points) \(since)"
        case .falling: return "score.history.trend.down \(trend.points) \(since)"
        case .steady: return "score.history.trend.flat \(trend.end) \(since)"
        }
    }

    /**
     The bars for VoiceOver: each month with its score over six months ("Mei 51, Juni 55, …"), the
     span and the move over a year ("November 2025 sampai Oktober 2026: naik dari 40 ke 66").
     */
    func chartLabel(_ range: ScoreHistoryRange) -> LocalizedStringResource {
        guard range == .oneYear, let trend = ScoreHistoryTrend(points) else {
            let months = points.map { "\($0.month.date.formatted(.kiraMonth)) \($0.score)" }
            return "score.history.chart \(months.joined(separator: ", "))"
        }
        let since = trend.since.date.formatted(.kiraMonthYear)
        let until = trend.until.date.formatted(.kiraMonthYear)
        switch trend.direction {
        case .rising: return "score.history.chart.up \(since) \(until) \(trend.start) \(trend.end)"
        case .falling: return "score.history.chart.down \(since) \(until) \(trend.start) \(trend.end)"
        case .steady: return "score.history.chart.flat \(since) \(until) \(trend.end)"
        }
    }

    /** One bar per month, the last (now) highlighted, captioned with its score. */
    var columns: [KiraBars.Column] {
        points.enumerated().map { index, point in
            KiraBars.Column(
                label: "score.history.month \(point.month.date.formatted(.kiraMonthShort))", value: Double(point.score),
                isHighlighted: index == points.count - 1, caption: "score.history.points \(point.score)")
        }
    }

    /**
     "Lima indikator lain tetap sama. Skor naik dari 62 ke 66 karena Dana Darurat kini 1,1×
     pengeluaran pokok.": the reason is named when one indicator changed.
     */
    var footer: Text {
        let unchanged = Text("score.history.footer.unchanged \(countWord(unchangedCount))")
        guard let delta = deltaFromPrevious, delta != 0 else { return unchanged }
        let from = score - delta
        guard changes.count == 1, let change = changes.first else {
            let moved = delta > 0 ? Text("score.history.footer.up \(from) \(score)")
                : Text("score.history.footer.down \(from) \(score)")
            return Text("score.history.footer \(unchanged) \(moved)")
        }
        let name = Text(change.indicator.name)
        let moved = delta > 0 ? Text("score.history.footer.upBecause \(from) \(score) \(name) \(change.now)")
            : Text("score.history.footer.downBecause \(from) \(score) \(name) \(change.now)")
        return Text("score.history.footer \(unchanged) \(moved)")
    }
}

extension IndicatorChange {
    /** "0,8× → 1,1× pengeluaran pokok", or the figure now alone when last month's was not kept. */
    var labels: Text {
        guard let fromLabel else { return now }
        guard let unit = indicator.historyUnit else {
            return Text("score.history.change.labels \(fromLabel) \(toLabel)")
        }
        return Text("score.history.change.labelsUnit \(fromLabel) \(toLabel) \(Text(unit))")
    }

    /** "1,1× pengeluaran pokok". */
    var now: Text {
        guard let unit = indicator.historyUnit else { return Text("score.history.change.now \(toLabel)") }
        return Text("score.history.change.nowUnit \(toLabel) \(Text(unit))")
    }

    /** "25 → 50 poin". */
    var pointsText: LocalizedStringResource { "score.history.change.points \(fromPoints) \(toPoints)" }

    /** "+25 Poin" or "−10 Poin". */
    var gainText: LocalizedStringResource {
        gain >= 0 ? "score.history.change.gain \(gain)" : "score.history.change.loss \(-gain)"
    }
}

extension IndicatorKey {
    /**
     The words after the API's bare figure, as Detail Indikator writes the value ("1,1× pengeluaran
     pokok", "20% dari gaji"); nil where the figure says it all ("2 platform", "1 dari 2").
     */
    fileprivate var historyUnit: LocalizedStringResource? {
        switch self {
        case .emergencyFund: "score.history.unit.expenses"
        case .savingsRatio, .instalmentRatio: "score.history.unit.income"
        case .debtToAsset: "score.history.unit.assets"
        case .consumerDebt, .protection: nil
        }
    }
}
