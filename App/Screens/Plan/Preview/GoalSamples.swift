/** The goal forms' figures as their boards draw them (TujuanKendaraan, TujuanBarang, TujuanLainnya). */
import Features

enum GoalSamples {
    /** Kendaraan: Rp30.000.000,00 in 2 years, DP 25%, Rp2.000.000,00 set aside, Rp300.000,00 a month at 5%. */
    static var vehicle: PriceGoalValues {
        var values = PriceGoalValues()
        values.duration = "2"
        values.price = "30.000.000"
        values.downPayment = "25"
        values.present = "2.000.000"
        values.deposit = "300.000"
        values.annualReturn = "5"
        return values
    }

    /** Barang Impian: Laptop Baru, Rp15.000.000,00 in 12 months in cash, Rp1.150.000,00 a month at 5%. */
    static var goods: PriceGoalValues {
        var values = PriceGoalValues()
        values.name = "Laptop Baru"
        values.duration = "12"
        values.price = "15.000.000"
        values.downPayment = "100"
        values.present = "2.000.000"
        values.deposit = "1.150.000"
        values.annualReturn = "5"
        return values
    }

    /** Lainnya: Liburan Keluarga, Rp25.000.000,00 in 2 years, Rp1.000.000,00 a month at 5%. */
    /** Kalkulator Dana Darurat's persona: Rp4.200.000 a month, single, Rp4.800.000 there, 30 months. */
    @MainActor static var emergency: EmergencyFundGoalModel {
        let form = EmergencyFundGoalModel(
            prefill: PlanPrefill(essentialExpense: 4_200_000, emergencyFund: 4_800_000, maritalStatus: .single))
        form.months = "30"
        form.deposit = "650000"
        form.annualReturn = "4"
        return form
    }

    static var other: OtherGoalValues {
        var values = OtherGoalValues()
        values.name = "Liburan Keluarga"
        values.amount = "25.000.000"
        values.duration = "2"
        values.present = "0"
        values.deposit = "1.000.000"
        values.annualReturn = "5"
        return values
    }
}
