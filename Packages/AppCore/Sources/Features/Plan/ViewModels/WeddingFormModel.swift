import Domain
import Observation

/**
 Tujuan Baru · Menikah (REN-02d, board TujuanMenikah): Anggaran Pernikahan either Rinci (the twelve
 rows, starting from an example budget, each row's price changed in a sheet) or Sederhana (one
 total); then Mimpimu (when, inflation, what is saved) and Strategi Investasimu. Hitung opens the
 result (REN-04e), computed on the device.
 */
@MainActor
@Observable
package final class WeddingFormModel {
    /** Tipe Budgeting. */
    package enum Budgeting: Hashable, Sendable {
        /** Rinci: the twelve rows. */
        case detailed
        /** Sederhana: one total. */
        case simple
    }

    /** Rinci or Sederhana. */
    package var budgeting = Budgeting.detailed
    /** The example budget the rows came from; nil once a row is changed. */
    package private(set) var preset: WeddingPreset?
    /** The twelve rows. */
    package private(set) var items: [WeddingItem]
    /** Sederhana's total. */
    package var simpleTotal = ""
    /** Menikah dalam … Tahun Lagi. */
    package var years: String
    /** Asumsi Inflasi, percent per year. */
    package var inflation: String
    /** Uang yang Sudah Ada untuk Menikah. */
    package var present: String
    /** Target Investasi per Bulan. */
    package var deposit: String
    /** Return Investasi, percent per year. */
    package var annualReturn: String
    /** The row open in the price sheet, and its fields. */
    package private(set) var editing: WeddingItemKind?
    /** The sheet's price (or price per guest). */
    package var editPrice = ""
    /** The sheet's guests, for a per-guest row. */
    package var editGuests = ""

    /** A form on the Standar example, inflation 5%, unless told otherwise. */
    package init(
        preset: WeddingPreset = .standard, years: String = "", inflation: String = "5", present: String = "",
        deposit: String = "", annualReturn: String = ""
    ) {
        self.preset = preset
        items = preset.items
        self.years = years
        self.inflation = inflation
        self.present = present
        self.deposit = deposit
        self.annualReturn = annualReturn
    }

    /** The board's persona: Standar, 2 years, Rp15.000.000,00 saved, Rp6.500.000,00 a month at 5%. */
    package static func sample() -> WeddingFormModel {
        WeddingFormModel(years: "2", present: "15.000.000", deposit: "6.500.000", annualReturn: "5")
    }

    /** Pakai Contoh Anggaran. */
    package func use(_ preset: WeddingPreset) {
        self.preset = preset
        items = preset.items
    }

    /** Total Anggaran: the rows' sum, or Sederhana's total. */
    package var total: Int {
        switch budgeting {
        case .detailed: items.reduce(0) { $0 + $1.total }
        case .simple: AmountInput.value(of: simpleTotal) ?? 0
        }
    }

    /** Opens the price sheet on `kind`'s row. */
    package func edit(_ kind: WeddingItemKind) {
        editing = kind
        for item in items where item.kind == kind {
            editPrice = AmountInput.text(for: item.price)
            editGuests = String(item.guests)
        }
    }

    /** Simpan in the price sheet: the row takes the typed price (and guests), and the example is left. */
    package func saveEdit() {
        guard let kind = editing, let index = items.firstIndex(where: { $0.kind == kind }) else { return }
        let guests = RateInput.count(editGuests) ?? items[index].guests
        items[index] = WeddingItem(kind, price: AmountInput.value(of: editPrice) ?? 0, guests: guests)
        preset = nil
        editing = nil
    }

    /** Closes the price sheet without a change. */
    package func cancelEdit() {
        editing = nil
    }

    /** The result, or nil while something Hitung needs is missing. */
    package var result: WeddingGoal? {
        guard total > 0, let years = RateInput.count(years), let inflation = RateInput.rate(inflation),
            let deposit = AmountInput.amount(deposit), let annualReturn = RateInput.rate(annualReturn)
        else { return nil }
        return WeddingGoal(
            cost: total, inflation: inflation, years: years, present: AmountInput.value(of: present) ?? 0,
            deposit: deposit, annualReturn: annualReturn)
    }

    /** Whether Hitung can go. */
    package var canCalculate: Bool { result != nil }
}

extension WeddingGoal {
    /** What Jadikan Pos Budget stores, starting on `today`. */
    package func draft(today: CalendarDay, preset: WeddingPreset?) -> GoalDraft {
        GoalDraft(
            kind: .wedding, name: "Menikah",
            inputs: [
                "cost": .number(Double(cost)), "inflation": .number(inflation), "years": .number(Double(years)),
                "annualReturn": .number(annualReturn), "preset": preset.map { .text($0.rawValue) } ?? .empty,
            ],
            initialAmount: present, monthlyDeposit: deposit, targetAmount: target,
            targetDate: today.adding(years: years), inBudget: true)
    }
}
