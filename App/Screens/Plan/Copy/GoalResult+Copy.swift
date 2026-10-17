/**
 The words the Hasil Simulasi boards give the engine's values: the status, the recommendations, the
 horizon, a yearly rate, and the asset classes (HasilTujuan* boards, ModulKelasAset).
 */
import Domain
import SwiftUI

extension GoalFit {
    /** "Strategimu Cocok", "Hampir Cocok", "Belum Cocok". */
    var tag: LocalizedStringResource {
        switch self {
        case .fits: "plan.result.fit.fits"
        case .nearlyFits: "plan.result.fit.nearly"
        case .short: "plan.result.fit.short"
        }
    }

    var tone: KiraTag.Tone {
        switch self {
        case .fits: .healthy
        case .nearlyFits: .turmeric
        case .short: .vulnerable
        }
    }

    var icon: KiraIconName {
        switch self {
        case .fits: .check
        case .nearlyFits: .clock
        case .short: .alert
        }
    }

    /** The status card's sentence. */
    var sentence: LocalizedStringResource {
        switch self {
        case .fits: "plan.result.fit.fits.body"
        case .nearlyFits: "plan.result.fit.nearly.body"
        case .short: "plan.result.fit.short.body"
        }
    }
}

extension DepositPeriod {
    /** Rinciannya's deposit row: "Investasi per Bulan", or per year (Lainnya's "Setiap Tahun"). */
    var depositTitle: LocalizedStringResource {
        self == .month ? "plan.result.deposit.month" : "plan.result.deposit.year"
    }
}

extension GoalHorizon {
    /** "27 tahun", "12 bulan". */
    var text: Text {
        switch self {
        case .years(let years): Text("plan.result.horizon.years \(years)")
        case .months(let months): Text("plan.result.horizon.months \(months)")
        }
    }
}

/** Copy shared by the goal results. */
enum GoalCopy {
    /** "10% per tahun" for a fraction of 0.10. */
    static func yearlyRate(_ rate: Double) -> Text {
        Text("plan.result.rate.yearly \(Text(rate * 100, format: .kiraMultiple))")
    }
}

extension GoalRecommendation {
    var title: LocalizedStringResource {
        switch self {
        case .raiseDeposit: "plan.result.advice.deposit"
        case .raiseReturn: "plan.result.advice.return"
        case .extendYears, .extendMonths: "plan.result.advice.time"
        }
    }

    var icon: KiraIconName {
        switch self {
        case .raiseDeposit: .calendar
        case .raiseReturn: .chart
        case .extendYears, .extendMonths: .clock
        }
    }

    /** "Jadi Rp2.950.000,00 per bulan", "12% per tahun, …", "Jadi 3 tahun, target menjadi Rp…". */
    func detail(period: DepositPeriod) -> Text {
        switch self {
        case .raiseDeposit(let deposit):
            let amount = Text(deposit.rupiah, format: .rupiah)
            return period == .month
                ? Text("plan.result.advice.deposit.month \(amount)")
                : Text("plan.result.advice.deposit.year \(amount)")
        case .raiseReturn(let rate):
            return Text("plan.result.advice.return.detail \(Text(rate * 100, format: .kiraMultiple))")
        case .extendYears(let years, let target):
            return Text("plan.result.advice.years \(years) \(Text(target.rupiah, format: .rupiah))")
        case .extendMonths(let months):
            return Text("plan.result.advice.months \(months)")
        }
    }
}

extension GoalAssetClass {
    /** The class as the boards and Modul Kelas Aset name it. */
    var title: LocalizedStringResource {
        switch self {
        case .moneyMarket: "plan.asset.moneyMarket"
        case .shortTermDeposit: "plan.asset.deposit"
        case .fixedIncomeFund: "plan.asset.fixedIncome"
        case .governmentBond: "plan.asset.governmentBond"
        case .stocks: "plan.asset.stocks"
        case .indexFund: "plan.asset.indexFund"
        case .balancedFund: "plan.asset.balanced"
        case .etf: "plan.asset.etf"
        case .gold: "plan.asset.gold"
        case .crypto: "plan.asset.crypto"
        case .usDollar: "plan.asset.usDollar"
        }
    }
}
