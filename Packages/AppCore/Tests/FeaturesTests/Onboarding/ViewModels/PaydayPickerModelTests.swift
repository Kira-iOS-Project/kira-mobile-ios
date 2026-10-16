import Domain
import Testing

@testable import Features

@MainActor
@Suite("PaydayPickerModel")
struct PaydayPickerModelTests {
    @Test("opens on the day given, and a day chosen becomes the payday")
    func day() {
        let model = PaydayPickerModel(payday: Payday(day: 25))
        #expect(model.isChosen(25) && !model.isChosen(10))
        model.choose(10)
        #expect(model.payday == Payday(day: 10))
        model.choose(45)
        #expect(model.day == 31)
    }

    @Test("the end of the month dims the calendar and becomes the payday")
    func endOfMonth() {
        let model = PaydayPickerModel(payday: .endOfMonth)
        #expect(model.isEndOfMonth)
        #expect(model.day == 25)
        #expect(!model.isChosen(25))
        model.choose(3)
        #expect(model.day == 25)
        #expect(model.payday == .endOfMonth)
        model.isEndOfMonth = false
        #expect(model.payday == Payday(day: 25))
    }
}
