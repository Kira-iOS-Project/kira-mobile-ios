import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("PayoffModel stale answers")
struct PayoffModelStaleTests {
    @Test("an answer that arrives after a newer request is dropped")
    func staleAnswer() async {
        let service = GatedPayoffService(heldFails: false)
        let model = PayoffModel(service: service)
        await model.load()
        let slow = Task { await model.choose(.avalanche) }
        await service.untilHeld()
        await model.setExtra("100000")
        await service.release()
        await slow.value
        #expect(model.phase.value?.extraPayment == 100_000 && model.phase.value?.method == .avalanche)
        #expect(!model.isRecalculating)
    }

    @Test("a failure that arrives after a newer request is dropped too")
    func staleFailure() async {
        let service = GatedPayoffService(heldFails: true)
        let model = PayoffModel(service: service)
        await model.load()
        let slow = Task { await model.choose(.avalanche) }
        await service.untilHeld()
        await model.setExtra("100000")
        await service.release()
        await slow.value
        #expect(model.phase.value?.extraPayment == 100_000 && model.recalculationProblem == nil)
    }
}
