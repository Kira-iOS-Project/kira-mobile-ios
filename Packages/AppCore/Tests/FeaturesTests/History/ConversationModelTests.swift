import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("ConversationModel")
struct ConversationModelTests {
    private let service = FakeHistoryService()

    @Test("groups each message with Kira's replies and frames the source, leaving the remaining note outside")
    func blocks() async throws {
        let model = ConversationModel(sourceMessageId: "m-1241", service: service)
        #expect(model.sourceBlockId == nil)
        await model.load()
        let blocks = try #require(model.phase.value)
        #expect(blocks.map(\.id) == ["m-0812", "m-1241"])
        #expect(blocks.map(\.isSource) == [false, true])
        #expect(blocks[1].framed.map(\.id) == ["m-1241", "r-1241"])
        #expect(blocks[1].trailing.map(\.id) == ["left-1241"])
        #expect(blocks[0].framed.count == 2 && blocks[0].trailing.isEmpty)
        #expect(blocks[1].startedAt == HistorySample.at(HistorySample.today, 12, 41))
        #expect(model.sourceBlockId == "m-1241")
        #expect(model.personInitial == "D")
    }

    @Test("shows the log without an initial when the account cannot be read or has no name")
    func noInitial() async {
        await service.configure { $0.failing = [.period] }
        let model = ConversationModel(sourceMessageId: "m-1241", service: service)
        await model.load()
        #expect(model.phase.value != nil && model.personInitial == nil)
        #expect(HistoryAccount(period: HistorySample.period, displayName: "").initial == nil)
    }

    @Test("a reply before any message of the person starts its own block")
    func leadingReply() {
        let blocks = ConversationModel.blocks(Array(HistorySample.messages.dropFirst()), source: "none")
        #expect(blocks.map(\.id) == ["r-0812", "m-1241"])
    }

    @Test("an empty log is empty, a refused one shows the problem")
    func emptyAndFailed() async {
        await service.configure { $0.messages = [] }
        let model = ConversationModel(sourceMessageId: "m-1241", service: service)
        await model.load()
        guard case .empty = model.phase else {
            Issue.record("expected empty")
            return
        }
        await service.configure { $0.failing = [.messages] }
        await model.load()
        guard case .failed = model.phase else {
            Issue.record("expected failed")
            return
        }
    }
}
