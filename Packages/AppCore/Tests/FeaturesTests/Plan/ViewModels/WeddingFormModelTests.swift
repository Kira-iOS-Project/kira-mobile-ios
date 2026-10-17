import Domain
import Testing

@testable import Features

@MainActor
@Suite("WeddingFormModel")
struct WeddingFormModelTests {
    @Test("the board's persona: Standar Rp175.000.000,00 in 2 years is Rp192.937.500,00, Hampir Cocok")
    func persona() throws {
        let form = WeddingFormModel.sample()
        #expect(form.total == 175_000_000 && form.preset == .standard && form.canCalculate)
        let goal = try #require(form.result)
        #expect(goal.target == 192_937_500 && goal.projection.result == 180_964_722)
        #expect(goal.projection.fit == .nearlyFits)
        #expect(goal.recommendations.contains(.raiseDeposit(to: 7_000_000)))
        let draft = goal.draft(today: CalendarDay(year: 2026, month: 10, day: 17), preset: form.preset)
        #expect(draft.kind == .wedding && draft.targetAmount == 192_937_500)
        #expect(draft.inputs["preset"] == .text("standard"))
        #expect(draft.targetDate == CalendarDay(year: 2028, month: 10, day: 17))
        #expect(goal.draft(today: draft.targetDate, preset: nil).inputs["preset"] == .empty)
    }

    @Test("the examples total as the board says, and a changed row leaves the example")
    func presets() {
        let form = WeddingFormModel()
        form.use(.economical)
        #expect(form.total == 42_500_000)
        form.use(.lavish)
        #expect(form.total == 775_000_000)
        form.edit(.catering)
        #expect(form.editing == .catering && form.editGuests == "500")
        form.editGuests = "100"
        form.saveEdit()
        #expect(form.preset == nil && form.total == 775_000_000 - 80_000_000 && form.editing == nil)
        form.edit(.venue)
        form.editPrice = "1.000.000"
        form.saveEdit()
        #expect(form.items.first?.total == 1_000_000)
        form.edit(.music)
        form.cancelEdit()
        #expect(form.editing == nil)
        form.saveEdit()
        #expect(form.items[7].total == 25_000_000)
    }

    @Test("Sederhana counts its one total, and Hitung waits for every field")
    func simple() {
        let form = WeddingFormModel()
        #expect(form.result == nil && !form.canCalculate)
        form.budgeting = .simple
        #expect(form.total == 0)
        form.simpleTotal = "100.000.000"
        #expect(form.total == 100_000_000)
        #expect(WeddingItem(.venue, price: 5, guests: 9).guests == 1)
        #expect(WeddingItemKind.allCases.filter(\.isPerGuest) == [.catering, .souvenir, .invitation])
    }
}
