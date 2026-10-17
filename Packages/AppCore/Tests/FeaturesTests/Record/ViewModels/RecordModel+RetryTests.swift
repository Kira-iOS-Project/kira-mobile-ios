import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** Coba Lagi on Catat's failure dialog: the chat action that failed runs again. */
@MainActor
@Suite("RecordModel retry")
struct RecordModelRetryTests {
    private let lunch = Fixtures.draft("d1", name: "Makan Siang", amount: 25_000)

    private func loaded(_ service: FakeRecordService) async -> RecordModel {
        let model = RecordModel(dependencies: Fixtures.dependencies(service: service, clock: ManualClock()))
        await model.load()
        return model
    }

    @Test("a failed send is sent again with the same text and id; nothing failed runs nothing")
    func send() async {
        let service = FakeRecordService()
        let model = await loaded(service)
        await model.retryFailed()
        #expect(service.sent.isEmpty)
        model.composerText = "kopi 15rb"
        await model.send()
        #expect(model.failure == .connection)
        await model.retryFailed()
        #expect(service.sent.map(\.text) == ["kopi 15rb", "kopi 15rb"])
        #expect(service.sent.map(\.clientId) == ["id-1", "id-1"])
    }

    @Test("a failed Simpan commits again, and a failed Urungkan undoes again")
    func saveAndUndo() async {
        let service = FakeRecordService()
        let pending = Fixtures.drafts("k1", replyTo: "m1", items: [lunch])
        let committed = Fixtures.drafts("k1", replyTo: "m1", items: [lunch], status: .committed, batchId: "b1")
        service.commitResult = .failure(AppProblem(code: "HTTP_ERROR"))
        let model = await loaded(service)
        await model.save(pending)
        service.commitResult = .success(
            CommitResult(message: committed, remaining: Fixtures.kira("k2", kind: .remaining)))
        await model.retryFailed()
        #expect(service.commits == ["k1", "k1"])
        await model.undo(committed)
        service.undoResult = .success(pending)
        await model.retryFailed()
        #expect(service.undos == ["b1", "b1"])
        #expect(model.undoable.isEmpty)
    }
}
