import Foundation

/**
 DP Rumah's and Simulasi KPR's engines as R2c (kira-project-d5) announced them, until their
 Domain/Plan/Logic lands: then this file goes and theirs stays, with the same names.
 */
package struct HouseDownPayment: Equatable, Sendable {
    /** The price today. */
    package let price: Int
    /** The DP share of the price. */
    package let downPaymentRate: Double
    /** Property inflation per year. */
    package let inflation: Double
    /** Years until the DP is due. */
    package let years: Int
    /** What is saved already. */
    package let present: Int
    /** The monthly deposit. */
    package let deposit: Int
    /** The deposits' return per year. */
    package let annualReturn: Double

    /** The down payment at today's price. */
    package var downPaymentNow: Int { Int((Double(price) * downPaymentRate).rounded()) }
    /** What the bank lends at today's price. */
    package var loanNow: Int { price - downPaymentNow }
    /** The down payment when it is due, inflation included. */
    package var target: Int { GoalMath.inflated(downPaymentNow, rate: inflation, years: years) }

    /** What the deposits reach by then, against the target. */
    package var projection: GoalProjection {
        GoalMath.project(
            target: Double(target), present: present, deposit: deposit, annualReturn: annualReturn, months: years * 12)
    }

    /** What would make it fit, when it falls short. */
    package var recommendations: [GoalRecommendation] {
        GoalRecommender.recommendations(
            cost: downPaymentNow, inflation: inflation, years: years, present: present, deposit: deposit,
            annualReturn: annualReturn)
    }

    /** DP Rumah's inputs. */
    package init(
        price: Int, downPaymentRate: Double, inflation: Double, years: Int, present: Int, deposit: Int,
        annualReturn: Double
    ) {
        self.price = price
        self.downPaymentRate = downPaymentRate
        self.inflation = inflation
        self.years = years
        self.present = present
        self.deposit = deposit
        self.annualReturn = annualReturn
    }
}

/** Simulasi KPR: a fixed rate first, then a floating annuity on what is left. */
package struct Mortgage: Equatable, Sendable {
    /** The price today. */
    package let price: Int
    /** What the bank lends. */
    package let loan: Int
    /** The loan's years. */
    package let tenorYears: Int
    /** The fixed rate per year. */
    package let fixRate: Double
    /** The floating rate per year. */
    package let floatRate: Double
    /** The fixed rate's years. */
    package let fixYears: Int
    /** The monthly income. */
    package let income: Int
    /** NJOP-TKP. */
    package let njopTkp: Int

    /** Simulasi KPR's inputs. */
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

    private static func annuity(_ balance: Double, rate: Double, months: Int) -> Double {
        guard months > 0 else { return 0 }
        let monthly = rate / 12
        if monthly == 0 { return balance / Double(months) }
        return balance * monthly / (1 - pow(1 + monthly, -Double(months)))
    }

    private var fixPayment: Double { Self.annuity(Double(loan), rate: fixRate, months: months) }

    private var balanceAfterFix: Double {
        let monthly = fixRate / 12
        let growth = pow(1 + monthly, Double(fixMonths))
        if monthly == 0 { return Double(loan) - fixPayment * Double(fixMonths) }
        return Double(loan) * growth - fixPayment * (growth - 1) / monthly
    }

    private var floatPayment: Double {
        Self.annuity(balanceAfterFix, rate: floatRate, months: months - fixMonths)
    }

    /** Cicilan Masa Bunga Fix. */
    package var fixInstalment: Int { Int(fixPayment.rounded()) }
    /** Cicilan Masa Floating. */
    package var floatInstalment: Int { Int(floatPayment.rounded()) }
    /** Sisa Pokok setelah Masa Fix. */
    package var remainingAfterFix: Int { Int(balanceAfterFix.rounded()) }

    /** Total Bunga KPR. */
    package var totalInterest: Int {
        let paid = fixPayment * Double(fixMonths) + floatPayment * Double(months - fixMonths)
        return Int((paid - Double(loan)).rounded())
    }

    /** The interest over the loan (1,304 for "130,4% dari pokok pinjaman"). */
    package var interestShare: Double { loan > 0 ? Double(totalInterest) / Double(loan) : 0 }

    /** The higher instalment over the income. */
    package var highestShare: Double {
        income > 0 ? max(fixPayment, floatPayment) / Double(income) : 0
    }

    /** Under 15% very healthy, to 30% healthy, to 50% unhealthy, above that dangerous. */
    package var health: MortgageHealth {
        if highestShare < 0.15 { return .veryHealthy }
        if highestShare <= 0.30 { return .healthy }
        if highestShare <= 0.50 { return .unhealthy }
        return .dangerous
    }

    /** Biaya Lain Saat Beli. */
    package var costs: BuyingCosts {
        let price = Double(price)
        let notaryRate = price < 100_000_000 ? 0.025 : price > 1_000_000_000 ? 0.01 : 0.015
        return BuyingCosts(
            bphtb: Int((0.05 * max(price - Double(njopTkp), 0)).rounded()), deed: Int((price * 0.01).rounded()),
            transfer: Int((price * 0.01).rounded()), notary: Int((price * notaryRate).rounded()),
            provision: Int((Double(loan) * 0.01).rounded()), appraisal: 1_000_000, admin: 1_000_000)
    }
}

/** How heavy the instalment is on the income. */
package enum MortgageHealth: Equatable, Sendable {
    /** Under 15%. */
    case veryHealthy
    /** Up to 30%. */
    case healthy
    /** Up to 50%. */
    case unhealthy
    /** Above 50%. */
    case dangerous
}

/** What buying costs beyond the price and the down payment. */
package struct BuyingCosts: Equatable, Sendable {
    /** BPHTB, AJB, Balik Nama, Notaris, Provisi, Appraisal and Administrasi, whole rupiah. */
    package let bphtb, deed, transfer, notary, provision, appraisal, admin: Int

    /** The costs as computed. */
    package init(bphtb: Int, deed: Int, transfer: Int, notary: Int, provision: Int, appraisal: Int, admin: Int) {
        self.bphtb = bphtb
        self.deed = deed
        self.transfer = transfer
        self.notary = notary
        self.provision = provision
        self.appraisal = appraisal
        self.admin = admin
    }

    /** Total Biaya Lain. */
    package var total: Int { bphtb + deed + transfer + notary + provision + appraisal + admin }
}
