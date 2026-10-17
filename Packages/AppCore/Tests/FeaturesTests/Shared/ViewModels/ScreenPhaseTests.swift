import APIClient
import Testing

@testable import Features

@Suite("ScreenPhase")
struct ScreenPhaseTests {
    @Test("exposes the value only when loaded")
    func value() {
        #expect(ScreenPhase<Int>.loaded(3).value == 3)
        #expect(ScreenPhase<Int>.loading.value == nil)
        #expect(ScreenPhase<Int>.empty.value == nil)
        #expect(ScreenPhase<Int>.failed(AppProblem()).value == nil)
    }
}
