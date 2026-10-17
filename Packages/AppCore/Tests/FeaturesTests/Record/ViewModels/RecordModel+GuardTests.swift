import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** Simpan and Urungkan taken once while on their way, and the server turning Kira AI off. */
@MainActor
@Suite("RecordModel guards")
struct RecordModelGuardTests {
    private let lunch = Fixtures.draft("d1", name: "Makan Siang", amount: 25_000)

    private func loaded(_ service: FakeRecordService) async -> RecordModel {
        let model = RecordModel(dependencies: Fixtures.dependencies(service: service, clock: ManualClock()))
        await model.load()
        return model
    }

    @Test("a second Simpan or Urungkan while the first is on its way sends nothing and shows no failure")
    func doubleTap() async {
        let service = FakeRecordService()
        let pending = Fixtures.drafts("k1", replyTo: "m1", items: [lunch])
        let committed = Fixtures.drafts("k1", replyTo: "m1", items: [lunch], status: .committed, batchId: "b1")
        service.commitResult = .success(
            CommitResult(message: committed, remaining: Fixtures.kira("k2", kind: .remaining)))
        let model = await loaded(service)
        service.holdsNext = true
        let first = Task { await model.save(pending) }
        await eventually { service.isHolding }
        await model.save(pending)
        service.release()
        await first.value
        #expect(service.commits == ["k1"])
        #expect(model.failure == nil && model.undoable == ["k1"])
        service.undoResult = .success(pending)
        service.holdsNext = true
        let undo = Task { await model.undo(committed) }
        await eventually { service.isHolding }
        await model.undo(committed)
        service.release()
        await undo.value
        #expect(service.undos == ["b1"])
        #expect(model.failure == nil && model.undoable.isEmpty)
        await model.save(pending)
        #expect(service.commits == ["k1", "k1"])
    }

    @Test("CHAT_AI_DISABLED on a send turns Kira AI off and shows the AI-off notice, not the failure dialog")
    func aiTurnedOff() async {
        let service = FakeRecordService()
        service.sendResult = .failure(AppProblem(code: "CHAT_AI_DISABLED"))
        let model = await loaded(service)
        model.composerText = "kopi 15rb"
        await model.send()
        #expect(model.showsAIOff)
        #expect(model.failure == nil)
        #expect(model.profile?.aiEnabled == false)
        #expect(model.composerText == "kopi 15rb")
        await model.retryFailed()
        #expect(service.sent.count == 1)
        model.showsAIOff = false
        model.openVoice()
        #expect(model.showsAIOff && model.voice == nil)
    }

    @Test("a scanner the server turned off closes and Catat shows the AI-off notice")
    func scannerTurnedOff() async {
        let service = FakeRecordService()
        service.receiptResult = .failure(AppProblem(code: "CHAT_AI_DISABLED"))
        let model = RecordModel(
            dependencies: Fixtures.dependencies(
                service: service, clock: ManualClock(), receiptReader: FakeReceiptReader(result: .success(Self.receipt))
            ))
        await model.load()
        model.openScanner()
        let scanner = model.scanner
        scanner?.picked(Data([1]), fileName: nil)
        await scanner?.read()
        #expect(model.scanner == nil)
        #expect(model.showsAIOff && model.profile?.aiEnabled == false)
    }

    private static let receipt = ["TOKO", "Sabun Cuci 15.500,00", "TOTAL 15.500,00"]
}
