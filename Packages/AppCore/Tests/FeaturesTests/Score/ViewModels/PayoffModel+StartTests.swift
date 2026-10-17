import Domain
import Testing

@testable import Features

@MainActor
@Suite("PayoffModel's starting state")
struct PayoffModelStartTests {
    @Test("Snowball with the formula closed by default; a start on Avalanche asks for it, open")
    func start() async {
        #expect(PayoffModel(service: FakePayoffService()).method == .snowball)
        #expect(!PayoffModel(service: FakePayoffService()).isHowOpen)
        let service = FakePayoffService()
        let model = PayoffModel(service: service, method: .avalanche, showsHow: true)
        await model.load()
        #expect(model.isHowOpen && model.phase.value?.method == .avalanche)
    }
}
