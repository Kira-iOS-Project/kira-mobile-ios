import Domain
import Testing

@testable import Features

@MainActor
@Suite("HistoryModel import entry")
struct HistoryModelImportTests {
    @Test("the upload icon opens Impor Mutasi on Kira Plus and before the account loads, Paket Kira otherwise")
    func importEntry() async {
        let service = FakeHistoryService()
        let model = HistoryModel(service: service, now: { HistorySample.now }, pause: { _ in })
        #expect(model.importEntry == .importer)
        await model.load()
        #expect(model.importEntry == .importer)
        await service.configure { $0.canImport = false }
        await model.load()
        #expect(model.importEntry == .plans)
    }
}
