import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("DeleteAccountModel")
struct DeleteAccountModelTests {
    @Test("Unduh Datamu Dulu emails the CSV, or says it could not")
    func emailData() async {
        let service = FakeAccountService()
        let model = DeleteAccountModel(service: service, settings: FakeSecuritySettings(), onDeleted: {})
        #expect(model.emailExport == .idle)
        await model.emailData()
        #expect(model.emailExport == .sent)
        await service.set(fails: true)
        await model.emailData()
        #expect(model.emailExport == .failed(Sample.problem))
    }

    @Test("Hapus Permanen waits for HAPUS in any case")
    func confirmation() async {
        let service = FakeAccountService()
        let model = DeleteAccountModel(service: service, settings: FakeSecuritySettings(), onDeleted: {})
        model.confirmation = "hapu"
        #expect(!model.canDelete)
        await model.delete()
        #expect(await service.calls.isEmpty)
        model.confirmation = " hapus "
        #expect(model.canDelete)
    }

    @Test("deleting clears the device, and Selesai leaves")
    func delete() async {
        let service = FakeAccountService()
        let settings = FakeSecuritySettings()
        let counter = CallCounter()
        let model = DeleteAccountModel(service: service, settings: settings, onDeleted: counter.call)
        model.confirmation = "Hapus"
        await model.delete()
        #expect(model.outcome == .deleted)
        #expect(!model.isDeleting)
        #expect(await service.calls == ["deleteAccount Hapus"])
        #expect(await settings.cleared)
        model.finish()
        #expect(counter.count == 1)
    }

    @Test("a failed deletion keeps the typing and can be tried again")
    func retry() async {
        let service = FakeAccountService()
        await service.set(fails: true)
        let settings = FakeSecuritySettings()
        let model = DeleteAccountModel(service: service, settings: settings, onDeleted: {})
        model.confirmation = "HAPUS"
        await model.delete()
        #expect(model.outcome == .failed(Sample.problem))
        #expect(model.confirmation == "HAPUS")
        #expect(!(await settings.cleared))
        await service.set(fails: false)
        await model.delete()
        #expect(model.outcome == .deleted)
    }
}
