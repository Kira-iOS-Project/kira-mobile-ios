import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("RecordModel")
struct RecordModelTests {
    @Test("load shows the newest page with the profile and its quotas")
    func load() async {
        let service = FakeRecordService()
        let message = Fixtures.person("m1", "bensin 30rb")
        service.pages[nil] = .success(ChatPage(items: [message], nextCursor: "c1"))
        let model = RecordModel(dependencies: Fixtures.dependencies(service: service))
        #expect(model.profile == nil)
        await model.load()
        #expect(model.profile?.initial == "D")
        #expect(model.messages == [message])
        #expect(model.usage == Fixtures.usage())
        #expect(model.hasOlder)
        #expect(model.rows.count == 2)
    }

    @Test("a failed load shows the API's problem, or the generic one for a lost connection")
    func failedLoad() async {
        let service = FakeRecordService()
        let problem = AppProblem(code: "INTERNAL_ERROR")
        service.profileResult = .failure(problem)
        let model = RecordModel(dependencies: Fixtures.dependencies(service: service))
        await model.load()
        guard case .failed(let shown) = model.phase else {
            Issue.record("expected a failure")
            return
        }
        #expect(shown == problem)
        service.profileResult = .failure(offlineError())
        await model.load()
        guard case .failed(let generic) = model.phase else {
            Issue.record("expected a failure")
            return
        }
        #expect(generic.code == nil)
    }

    @Test("older pages go before the oldest message, without repeats; a failure keeps the cursor")
    func older() async {
        let service = FakeRecordService()
        let newest = Fixtures.person("m2", "kopi 15rb")
        service.pages[nil] = .success(ChatPage(items: [newest], nextCursor: "c1"))
        let model = RecordModel(dependencies: Fixtures.dependencies(service: service))
        await model.load()
        await model.loadOlder()
        #expect(model.hasOlder)
        let older = Fixtures.person("m1", "bensin 30rb", at: Fixtures.noon.addingTimeInterval(-3_600))
        service.pages["c1"] = .success(ChatPage(items: [older, newest], nextCursor: nil))
        await model.loadOlder()
        #expect(model.messages.map(\.id) == ["m1", "m2"])
        #expect(!model.hasOlder)
        #expect(!model.isLoadingOlder)
        await model.loadOlder()
        #expect(model.messages.count == 2)
    }

    @Test("a reply's source time is its person message's, else its own")
    func sourceTime() async {
        let service = FakeRecordService()
        let earlier = Fixtures.noon.addingTimeInterval(-60)
        let person = Fixtures.person("m1", "kopi 15rb", at: earlier)
        let reply = Fixtures.drafts("k1", replyTo: "m1", items: [])
        service.pages[nil] = .success(ChatPage(items: [person, reply], nextCursor: nil))
        let model = RecordModel(dependencies: Fixtures.dependencies(service: service))
        await model.load()
        #expect(model.sourceTime(of: reply) == earlier)
        #expect(model.sourceTime(of: person) == earlier)
    }

    @Test("the pencil opens the edit sheet, whose save updates the chat; Lanjut Chat focuses the composer")
    func editAndContinue() async throws {
        let service = FakeRecordService()
        let lunch = Fixtures.draft("d1", name: "Makan Siang", amount: 25_000)
        let pending = Fixtures.drafts("k1", replyTo: nil, items: [lunch])
        service.pages[nil] = .success(ChatPage(items: [pending], nextCursor: nil))
        let model = RecordModel(dependencies: Fixtures.dependencies(service: service))
        await model.load()
        model.edit(lunch, in: pending)
        let editor = try #require(model.editor)
        #expect(editor.id == "d1")
        let discarded = Fixtures.drafts("k1", replyTo: nil, items: [], status: .discarded)
        service.updateResult = .success(discarded)
        await editor.delete()
        #expect(model.messages.first?.draftStatus == .discarded)
        model.continueChat()
        #expect(model.composerFocusRequests == 1)
        #expect(model.sheet(for: .receipts)?.counter.used == 4)
        #expect(model.sheet(for: .voice)?.counter.limit == 0)
    }

    @Test("no quota sheet before the profile has loaded")
    func noSheet() {
        let model = RecordModel(dependencies: Fixtures.dependencies(service: FakeRecordService()))
        #expect(model.sheet(for: .aiMessages) == nil)
    }
}
