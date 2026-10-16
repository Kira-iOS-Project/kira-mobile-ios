import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("DeleteAccountModel")
struct DeleteAccountModelTests {
    @Test("Unduh Datamu Dulu emails the CSV; a failure closes the sheet and Coba Lagi sends again")
    func emailData() async {
        let service = FakeAccountService()
        let model = DeleteAccountModel(service: service, settings: FakeSecuritySettings(), onDeleted: {})
        model.open()
        model.confirmation = "HAP"
        #expect(model.emailExport == .idle && model.sheet.isOpen)
        await service.set(fails: true)
        await model.emailData()
        #expect(model.emailExport == .idle && model.lastAction == .emailData)
        #expect(!model.sheet.isOpen && model.sheet.failure == Sample.problem)
        await service.set(fails: false)
        await model.retry()
        #expect(model.sheet.isOpen && model.sheet.failure == nil)
        #expect(model.emailExport == .sent && model.confirmation == "HAP")
        #expect(await service.calls == ["emailExport", "emailExport"])
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
        #expect(model.showsDeleted)
        #expect(!model.isDeleting)
        #expect(await service.calls == ["deleteAccount Hapus"])
        #expect(await settings.cleared)
        model.finish()
        #expect(counter.count == 1)
    }

    @Test("a failed deletion closes the sheet, keeps the typing, and Coba Lagi deletes again")
    func retry() async {
        let service = FakeAccountService()
        await service.set(fails: true)
        let settings = FakeSecuritySettings()
        let model = DeleteAccountModel(service: service, settings: settings, onDeleted: {})
        model.open()
        model.confirmation = "HAPUS"
        await model.delete()
        #expect(!model.sheet.isOpen && model.sheet.failure == Sample.problem)
        #expect(model.confirmation == "HAPUS" && !model.showsDeleted)
        #expect(!(await settings.cleared))
        await service.set(fails: false)
        await model.retry()
        #expect(model.sheet.isOpen && model.showsDeleted)
    }
}
