import Testing

@testable import Domain

@Suite("AssetCheck")
struct AssetCheckTests {
    private let today = CalendarDay(year: 2026, month: 10, day: 17)

    @Test("a full draft has no issue")
    func valid() {
        #expect(AssetCheck.issues(assetClass: .gold, name: " Emas ", value: 1, valuedOn: today, today: today).isEmpty)
        let largest = AssetCheck.maximumValue
        #expect(AssetCheck.issues(assetClass: .gold, name: "E", value: largest, valuedOn: today, today: today).isEmpty)
    }

    @Test("an empty draft names every missing field, in the form's order")
    func empty() {
        let issues = AssetCheck.issues(
            assetClass: nil, name: "  ", value: nil, valuedOn: today.adding(days: 1), today: today)
        #expect(issues == [.noClass, .noName, .noValue, .futureDay])
    }

    @Test("a name over 80 characters and a value over the API's limit are refused")
    func limits() {
        let long = String(repeating: "a", count: 81)
        let issues = AssetCheck.issues(
            assetClass: .other, name: long, value: AssetCheck.maximumValue + 1, valuedOn: today, today: today)
        #expect(issues == [.nameTooLong, .valueTooLarge])
        #expect(AssetCheck.issues(assetClass: .other, name: "a", value: 0, valuedOn: today, today: today) == [.noValue])
    }
}
