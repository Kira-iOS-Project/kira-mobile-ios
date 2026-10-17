import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("GoalDetailModel on the system's clock")
struct GoalDetailModelDefaultsTests {
    @Test("on the system's clock and ids, a deposit is sent today with a new key")
    func systemDefaults() async {
        let stub = DetailStub()
        let model = GoalDetailModel(id: "emergency", service: stub)
        await model.load()
        model.openDeposit()
        await model.submitDeposit()
        let sent = await stub.sent
        #expect(sent.count == 1 && sent.first?.id.isEmpty == false)
        #expect(sent.first?.depositedOn == CalendarDay(Date()))
    }

    @Test("a load cut off by leaving the screen stays loading instead of failing")
    func cancelled() async {
        let stub = DetailStub()
        await stub.configure { $0.goalAnswer = .failure(AppProblem(code: "AUTH_UNAUTHENTICATED")) }
        let model = GoalDetailModel(id: "emergency", service: stub)
        let leaving = Task { await model.load() }
        leaving.cancel()
        await leaving.value
        guard case .loading = model.phase else { return #expect(Bool(false)) }
    }
}
