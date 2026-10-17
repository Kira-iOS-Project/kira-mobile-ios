import Domain
import Observation

/**
 Tujuan Baru · DP Rumah (REN-02b, board TujuanDP): when, the price today, the DP percent and the
 property inflation, which show DP Kamu Setara and Pokok KPR as they are typed; what is saved
 already; the monthly deposit and its return; then Simulasi KPR's income, tenor, rates, fixed period
 and NJOP-TKP. Hitung needs every amount and rate; the result (REN-04c) is computed on the device.
 */
@MainActor
@Observable
package final class HouseDownPaymentFormModel {
    /** "Tercapai dalam … Tahun Lagi". */
    package var years: String
    /** Harga Properti Impian Saat Ini. */
    package var price: String
    /** DP, in percent. */
    package var downPaymentRate: String
    /** Inflasi Properti, percent per year. */
    package var inflation: String
    /** Uang yang Sudah Ada untuk DP. */
    package var present: String
    /** Target Investasi per Bulan. */
    package var deposit: String
    /** Return Investasi, percent per year. */
    package var annualReturn: String
    /** Penghasilan Bulanan. */
    package var income: String
    /** 10, 15 or 20 years. */
    package var tenorYears: Int
    /** Bunga Fix, percent. */
    package var fixRate: String
    /** Bunga Floating, percent. */
    package var floatRate: String
    /** 1, 3 or 5 years. */
    package var fixYears: Int
    /** NJOP-TKP. */
    package var njopTkp: String

    /** A form starting from the board's defaults (DP 20%, inflation 5%, tenor 20, fix 3 years). */
    package init(
        years: String = "", price: String = "", downPaymentRate: String = "20", inflation: String = "5",
        present: String = "", deposit: String = "", annualReturn: String = "", income: String = "",
        tenorYears: Int = 20, fixRate: String = "", floatRate: String = "", fixYears: Int = 3, njopTkp: String = ""
    ) {
        self.years = years
        self.price = price
        self.downPaymentRate = downPaymentRate
        self.inflation = inflation
        self.present = present
        self.deposit = deposit
        self.annualReturn = annualReturn
        self.income = income
        self.tenorYears = tenorYears
        self.fixRate = fixRate
        self.floatRate = floatRate
        self.fixYears = fixYears
        self.njopTkp = njopTkp
    }

    /** The board's persona: Rp450.000.000,00 in 5 years, DP 20%, Rp1.500.000,00 a month at 6%. */
    package static func sample() -> HouseDownPaymentFormModel {
        HouseDownPaymentFormModel(
            years: "5", price: "450.000.000", present: "10.000.000", deposit: "1.500.000", annualReturn: "6",
            income: "12.000.000", fixRate: "6,50", floatRate: "11,00", njopTkp: "60.000.000")
    }

    /** DP Kamu Setara, once the price and the percent are in. */
    package var downPaymentNow: Int? {
        guard let price = AmountInput.amount(price), let rate = RateInput.rate(downPaymentRate) else { return nil }
        return Int((Double(price) * rate).rounded())
    }

    /** Pokok KPR, with its share of the price ("Pokok KPR · 80%"). */
    package var loanNow: (amount: Int, percent: Int)? {
        guard let price = AmountInput.amount(price), let down = downPaymentNow,
            let rate = RateInput.rate(downPaymentRate)
        else { return nil }
        return (price - down, Int(((1 - rate) * 100).rounded()))
    }

    /** The result, or nil while something Hitung needs is missing. */
    package var result: HouseDownPaymentResult? {
        guard let years = RateInput.count(years), let price = AmountInput.amount(price),
            let downRate = RateInput.rate(downPaymentRate), downRate > 0, downRate < 1,
            let inflation = RateInput.rate(inflation), let deposit = AmountInput.amount(deposit),
            let annualReturn = RateInput.rate(annualReturn), let income = AmountInput.amount(income),
            let fixRate = RateInput.rate(fixRate), let floatRate = RateInput.rate(floatRate)
        else { return nil }
        let goal = HouseDownPayment(
            price: price, downPaymentRate: downRate, inflation: inflation, years: years,
            present: AmountInput.value(of: present) ?? 0, deposit: deposit, annualReturn: annualReturn)
        let mortgage = Mortgage(
            price: price, loan: goal.loanNow, tenorYears: tenorYears, fixRate: fixRate, floatRate: floatRate,
            fixYears: fixYears, income: income, njopTkp: AmountInput.value(of: njopTkp) ?? 0)
        return HouseDownPaymentResult(goal: goal, mortgage: mortgage)
    }

    /** Whether Hitung can go. */
    package var canCalculate: Bool { result != nil }
}

/** DP Rumah's result: the goal and its Simulasi KPR. */
package struct HouseDownPaymentResult: Equatable, Sendable {
    /** The down payment and how the deposits reach it. */
    package let goal: HouseDownPayment
    /** Simulasi KPR. */
    package let mortgage: Mortgage

    /** What Jadikan Pos Budget stores, starting on `today`. */
    package func draft(today: CalendarDay) -> GoalDraft {
        GoalDraft(
            kind: .houseDownPayment, name: "DP Rumah",
            inputs: [
                "price": .number(Double(goal.price)), "downPaymentRate": .number(goal.downPaymentRate),
                "inflation": .number(goal.inflation), "years": .number(Double(goal.years)),
                "annualReturn": .number(goal.annualReturn), "income": .number(Double(mortgage.income)),
                "tenorYears": .number(Double(mortgage.tenorYears)), "fixRate": .number(mortgage.fixRate),
                "floatRate": .number(mortgage.floatRate), "fixYears": .number(Double(mortgage.fixYears)),
                "njopTkp": .number(Double(mortgage.njopTkp)),
            ],
            initialAmount: goal.present, monthlyDeposit: goal.deposit, targetAmount: goal.target,
            targetDate: today.adding(years: goal.years), inBudget: true)
    }
}
