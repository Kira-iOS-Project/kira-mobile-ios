import Foundation

/**
 Simulasi KPR on DP Rumah: an annuity at the fixed rate for the first years, then one at the
 floating rate on what remains, the share of income the higher instalment takes, and the costs
 of buying (Biaya Lain), as the site computes them.
 */
package struct Mortgage: Equatable, Sendable {
    /** The price today. */
    package let price: Int
    /** Pokok Pinjaman. */
    package let loan: Int
    /** Jangka waktu KPR, in years. */
    package let tenorYears: Int
    /** Bunga fix a year, as a fraction. */
    package let fixRate: Double
    /** Bunga floating a year, as a fraction. */
    package let floatRate: Double
    /** Years at the fixed rate. */
    package let fixYears: Int
    /** The monthly income the instalment is weighed against. */
    package let income: Int
    /** NJOP-TKP, the untaxed part of the price for BPHTB. */
    package let njopTkp: Int

    /** A loan of `loan` on a house of `price` over `tenorYears`, fixed for `fixYears`. */
    package init(
        price: Int, loan: Int, tenorYears: Int, fixRate: Double, floatRate: Double, fixYears: Int, income: Int,
        njopTkp: Int
    ) {
        self.price = price
        self.loan = loan
        self.tenorYears = tenorYears
        self.fixRate = fixRate
        self.floatRate = floatRate
        self.fixYears = fixYears
        self.income = income
        self.njopTkp = njopTkp
    }

    private var months: Int { tenorYears * 12 }
    private var fixMonths: Int { min(fixYears, tenorYears) * 12 }

    private var fixAmount: Double {
        fixMonths > 0 ? Self.annuity(Double(loan), rate: fixRate / 12, months: months) : 0
    }

    private var balanceAfterFix: Double {
        var balance = Double(loan)
        for _ in 0..<fixMonths { balance = balance * (1 + fixRate / 12) - fixAmount }
        return balance
    }

    private var floatAmount: Double {
        let remaining = months - fixMonths
        return remaining > 0 ? Self.annuity(balanceAfterFix, rate: floatRate / 12, months: remaining) : 0
    }

    /** Cicilan Masa Bunga Fix. */
    package var fixInstalment: Int { Rupiah.rounded(fixAmount) }

    /** Cicilan Masa Floating. */
    package var floatInstalment: Int { Rupiah.rounded(floatAmount) }

    /** Sisa Pokok setelah Masa Fix. */
    package var remainingAfterFix: Int { Rupiah.rounded(balanceAfterFix) }

    /** Total Bunga KPR: every instalment less the loan. */
    package var totalInterest: Int {
        Rupiah.rounded(fixAmount * Double(fixMonths) + floatAmount * Double(months - fixMonths) - Double(loan))
    }

    /** Total Bunga KPR as a share of the loan (1.304 is 130,4%). */
    package var interestShare: Double { Double(totalInterest) / Double(loan) }

    /** The higher instalment as a share of income. */
    package var highestShare: Double { max(fixAmount, floatAmount) / Double(income) }

    /** How healthy that share is. */
    package var health: MortgageHealth { MortgageHealth(share: highestShare) }

    /** Biaya Lain. */
    package var costs: BuyingCosts { BuyingCosts(price: price, loan: loan, njopTkp: njopTkp) }

    /** The instalment that pays `principal` off at `rate` a month over `months`. */
    static func annuity(_ principal: Double, rate: Double, months: Int) -> Double {
        guard rate != 0 else { return principal / Double(months) }
        return principal * rate / (1 - pow(1 + rate, -Double(months)))
    }
}

/** The site's bands for the instalment's share of income. */
package enum MortgageHealth: Equatable, Sendable {
    /** Sangat Sehat: under 15%. */
    case veryHealthy
    /** Sehat: up to 30%. */
    case healthy
    /** Tidak Sehat: up to 50%. */
    case unhealthy
    /** Berbahaya: above 50%. */
    case dangerous

    /** The band of an instalment taking `share` of income. */
    package init(share: Double) {
        if share < 0.15 {
            self = .veryHealthy
        } else if share <= 0.30 {
            self = .healthy
        } else if share <= 0.50 {
            self = .unhealthy
        } else {
            self = .dangerous
        }
    }
}

/** Biaya Lain of buying a house with a KPR, in whole rupiah. */
package struct BuyingCosts: Equatable, Sendable {
    /** BPHTB: 5% of the price above NJOP-TKP. */
    package let bphtb: Int
    /** AJB: 1% of the price. */
    package let deed: Int
    /** Balik Nama: 1% of the price. */
    package let transfer: Int
    /** Notaris: 2,5% under Rp100 juta, 1% above Rp1 miliar, else 1,5% of the price. */
    package let notary: Int
    /** Provisi: 1% of the loan. */
    package let provision: Int
    /** Appraisal. */
    package let appraisal = 1_000_000
    /** Administrasi. */
    package let admin = 1_000_000

    /** The costs of a house of `price` with a loan of `loan`. */
    package init(price: Int, loan: Int, njopTkp: Int) {
        let value = Double(price)
        bphtb = Rupiah.rounded(max(0, 0.05 * Double(price - njopTkp)))
        deed = Rupiah.rounded(value * 0.01)
        transfer = Rupiah.rounded(value * 0.01)
        let notaryRate = price < 100_000_000 ? 0.025 : price > 1_000_000_000 ? 0.01 : 0.015
        notary = Rupiah.rounded(value * notaryRate)
        provision = Rupiah.rounded(Double(loan) * 0.01)
    }

    /** All of them together. */
    package var total: Int { bphtb + deed + transfer + notary + provision + appraisal + admin }
}
