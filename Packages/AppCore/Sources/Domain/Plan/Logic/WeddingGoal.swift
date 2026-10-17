/**
 Menikah (REN-02d, REN-04e): the budget today inflated to the wedding's year, what the deposits
 reach by then at a monthly compounded return, and what would close a gap. A thin goal on
 GoalMath and GoalRecommender, as R2c's engine leaves it to the form.
 */
package struct WeddingGoal: Equatable, Sendable {
    /** Total Anggaran today, whole rupiah. */
    package let cost: Int
    /** Asumsi Inflasi per year. */
    package let inflation: Double
    /** Menikah dalam … tahun lagi. */
    package let years: Int
    /** Uang yang Sudah Ada untuk Menikah. */
    package let present: Int
    /** Target Investasi per Bulan. */
    package let deposit: Int
    /** Return Investasi per year. */
    package let annualReturn: Double

    /** Menikah's inputs. */
    package init(cost: Int, inflation: Double, years: Int, present: Int, deposit: Int, annualReturn: Double) {
        self.cost = cost
        self.inflation = inflation
        self.years = years
        self.present = present
        self.deposit = deposit
        self.annualReturn = annualReturn
    }

    /** The budget in the wedding's year. */
    package var target: Int { GoalMath.inflated(cost, rate: inflation, years: years) }

    /** What the deposits reach by then, against the target. */
    package var projection: GoalProjection {
        GoalMath.project(
            target: GoalMath.inflatedAmount(Double(cost), rate: inflation, years: Double(years)), present: present,
            deposit: deposit, annualReturn: annualReturn, months: years * 12)
    }

    /** Naikkan Investasi, Perpanjang Waktu and Pilih Return Lebih Tinggi, while it falls short. */
    package var recommendations: [GoalRecommendation] {
        GoalRecommender.recommendations(
            cost: Double(cost), inflation: inflation, years: years, present: present, deposit: deposit,
            annualReturn: annualReturn)
    }
}
