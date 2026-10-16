import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("RecordModel chat")
struct RecordModelChatTests {
    private let lunch = Fixtures.draft("d1", name: "Makan Siang", amount: 25_000)

    private func loaded(_ service: FakeRecordService, clock: ManualClock = ManualClock()) async -> RecordModel {
        let model = RecordModel(dependencies: Fixtures.dependencies(service: service, clock: clock))
        await model.load()
        return model
    }

    private func result(exhausted: Bool = false) -> SendResult {
        SendResult(
            person: Fixtures.person("m1", "makan siang 25rb"),
            reply: exhausted ? nil : Fixtures.drafts("k1", replyTo: "m1", items: [lunch]), quotaExhausted: exhausted,
            usage: Fixtures.usage(messages: exhausted ? 30 : 13))
    }

    @Test("send reads the drafts on the device and shows the message with its reply")
    func send() async throws {
        let service = FakeRecordService()
        service.sendResult = .success(result())
        let model = await loaded(service)
        model.composerText = "  makan siang 25rb "
        await model.send()
        let sent = try #require(service.sent.first)
        #expect(sent.text == "makan siang 25rb")
        #expect(sent.inputMethod == .keyboard)
        #expect(sent.parser == .slangRules)
        #expect(sent.drafts.map(\.amount) == [25_000])
        #expect(model.messages.map(\.id) == ["m1", "k1"])
        #expect(model.composerText.isEmpty)
        #expect(model.usage?.aiMessages.used == 13)
        #expect(model.quotaSheet == nil)
        #expect(!model.isSending)
    }

    @Test("the 31st message is kept and the quota sheet shows instead of a reply")
    func quota() async throws {
        let service = FakeRecordService()
        service.sendResult = .success(result(exhausted: true))
        let model = await loaded(service)
        model.composerText = "makan siang 25rb"
        await model.send()
        #expect(model.messages.map(\.id) == ["m1"])
        let sheet = try #require(model.quotaSheet)
        #expect(sheet.kind == .aiMessages)
        #expect(sheet.counter == UsageMeter(used: 30, limit: 30))
        #expect(sheet.plan == .free)
    }

    @Test("a failed send gives the text back and keeps its id for the retry; empty text or AI off sends nothing")
    func failures() async {
        let service = FakeRecordService()
        let model = await loaded(service)
        model.composerText = "kopi 15rb"
        await model.send()
        #expect(model.failure == .connection)
        #expect(model.composerText == "kopi 15rb")
        await model.send()
        model.composerText = "parkir 3rb"
        await model.send()
        #expect(service.sent.map(\.clientId) == ["id-1", "id-1", "id-2"])
        model.composerText = "   "
        await model.send()
        #expect(service.sent.count == 3)
        service.profileResult = .success(Fixtures.profile(aiEnabled: false))
        await model.load()
        model.composerText = "kopi 15rb"
        await model.send()
        #expect(model.showsAIOff)
        #expect(service.sent.count == 3)
    }

    @Test("Simpan commits, adds the remaining money, and Urungkan shows for ten seconds")
    func saveAndExpire() async throws {
        let service = FakeRecordService()
        let clock = ManualClock()
        let pending = Fixtures.drafts("k1", replyTo: "m1", items: [lunch])
        service.pages[nil] = .success(
            ChatPage(items: [Fixtures.person("m1", "makan siang 25rb"), pending], nextCursor: nil))
        let committed = Fixtures.drafts("k1", replyTo: "m1", items: [lunch], status: .committed, batchId: "b1")
        service.commitResult = .success(
            CommitResult(message: committed, remaining: Fixtures.kira("k2", kind: .remaining)))
        let model = await loaded(service, clock: clock)
        await model.save(pending)
        #expect(service.commits == ["k1"])
        #expect(model.messages.map(\.id) == ["m1", "k1", "k2"])
        #expect(model.undoable == ["k1"])
        await settle()
        clock.wake()
        await settle()
        #expect(model.undoable.isEmpty)
        await model.undo(committed)
        #expect(service.undos.isEmpty)
    }

    @Test("Urungkan puts the drafts back and removes the remaining money; failures say why")
    func undo() async throws {
        let service = FakeRecordService()
        let pending = Fixtures.drafts("k1", replyTo: "m1", items: [lunch])
        let committed = Fixtures.drafts("k1", replyTo: "m1", items: [lunch], status: .committed, batchId: "b1")
        service.commitResult = .success(
            CommitResult(message: committed, remaining: Fixtures.kira("k2", kind: .remaining)))
        let model = await loaded(service)
        await model.save(pending)
        await model.undo(committed)
        #expect(model.failure == .connection)
        service.undoResult = .success(pending)
        await model.undo(committed)
        #expect(service.undos == ["b1", "b1"])
        #expect(model.messages.map(\.id) == ["k1"])
        #expect(model.messages.first?.draftStatus == .pending)
        #expect(model.undoable.isEmpty)
        model.failure = nil
        service.commitResult = .failure(AppProblem(code: "HTTP_ERROR"))
        await model.save(pending)
        #expect(model.failure == .problem(AppProblem(code: "HTTP_ERROR")))
    }
}
