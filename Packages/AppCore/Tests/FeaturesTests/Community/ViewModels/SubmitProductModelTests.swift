import Testing

@testable import Features

@MainActor
@Suite("SubmitProductModel")
struct SubmitProductModelTests {
    @Test("no mail app opens the dialog; closing it, or a mail app taking the link, leaves the screen ready")
    func mailApp() {
        let model = SubmitProductModel()
        #expect(model.phase == .ready)
        model.mailOpened(false)
        #expect(model.phase == .mailAppMissing)
        model.dismiss()
        #expect(model.phase == .ready)
        model.mailOpened(true)
        #expect(model.phase == .ready)
    }
}
