import Domain
import Foundation
import Testing

@testable import Features

/** PED-02 in Catat: a crisis message is answered on the device, never sent or read. */
@MainActor
@Suite("Catat crisis signal")
struct CrisisChatTests {
    private let board = "tagihan numpuk semua, capek banget. kayaknya mending gak ada aja"

    private func loaded(
        _ service: FakeRecordService = FakeRecordService(), checkIns: FakeCheckInService = FakeCheckInService(),
        aiEnabled: Bool = true
    ) async -> RecordModel {
        service.profileResult = .success(Fixtures.profile(aiEnabled: aiEnabled))
        let model = RecordModel(dependencies: Fixtures.dependencies(service: service, checkIns: checkIns))
        await model.load()
        return model
    }

    @Test("the board's message gets the fixed reply; it is never sent, and only the level is recorded")
    func intercepts() async {
        let service = FakeRecordService()
        let checkIns = FakeCheckInService()
        let model = await loaded(service, checkIns: checkIns)
        model.composerText = board
        await model.send()
        #expect(service.sent.isEmpty)
        #expect(model.composerText.isEmpty && model.failure == nil)
        #expect(model.care.entries.map(\.kind) == [.personText(board), .crisisReply(isAnswered: false)])
        #expect(checkIns.signals.map(\.level) == [.danger] && checkIns.signals.map(\.source) == [.chat])
        #expect(model.rows.filter { if case .care = $0 { true } else { false } }.count == 2)
    }

    @Test("ordinary spending, the debatable one included, is sent and read as usual")
    func ordinarySpending() async {
        let service = FakeRecordService()
        let checkIns = FakeCheckInService()
        let model = await loaded(service, checkIns: checkIns)
        model.composerText = "capek banget hari ini beli kopi 25rb"
        await model.send()
        #expect(service.sent.map(\.text) == ["capek banget hari ini beli kopi 25rb"])
        #expect(service.sent.first?.drafts.map(\.amount) == [25_000])
        #expect(model.care.entries.isEmpty && checkIns.signals.isEmpty)
    }

    @Test("with Kira AI off, the crisis reply still comes, from the list alone")
    func aiOff() async {
        let model = await loaded(aiEnabled: false)
        model.composerText = board
        await model.send()
        #expect(!model.showsAIOff && model.care.entries.count == 2)
    }

    @Test("a signal that could not be recorded shows nothing and is sent again later, in order")
    func signalFailureIsQuiet() async throws {
        let checkIns = FakeCheckInService()
        checkIns.signalResult = .failure(OfflineError())
        let model = await loaded(checkIns: checkIns)
        model.composerText = "putus asa"
        await model.send()
        #expect(model.failure == nil && model.care.entries.count == 2)
        await model.care.choose(.unsafe, in: try #require(model.care.entries.last))
        #expect(model.care.isHelpPresented && checkIns.signals.map(\.level) == [.concern, .concern])
        checkIns.signalResult = .success(())
        await model.load()
        #expect(checkIns.signals.map(\.level) == [.concern, .concern, .concern, .danger])
        await model.load()
        #expect(checkIns.signals.count == 4)
    }

    @Test("Aku Aman offers the check-in once; Aku Tidak Aman opens the help; Mau Cerita Dulu the composer")
    func quickReplies() async throws {
        let checkIns = FakeCheckInService()
        let model = await loaded(checkIns: checkIns)
        model.composerText = "putus asa"
        await model.send()
        let reply = try #require(model.care.entries.last)
        await model.care.choose(.safe, in: reply)
        #expect(model.care.checkIn != nil)
        #expect(model.care.entries.map(\.kind).suffix(2) == [.crisisReply(isAnswered: true), .personChoice(.safe)])
        await model.care.checkIn?.decline()
        await model.care.choose(.unsafe, in: reply)
        #expect(model.care.isHelpPresented)
        #expect(checkIns.signals.map(\.level) == [.concern, .danger])
        model.care.helpClosed()
        #expect(model.care.checkIn == nil)
        await model.care.choose(.talkFirst, in: reply)
        #expect(model.composerFocusRequests == 1)
    }

    @Test("Lihat Bantuan opens the help, closing it offers the check-in, and Aku Aman still offers it later")
    func help() async throws {
        let model = await loaded()
        model.composerText = "putus asa"
        await model.send()
        model.care.openHelp()
        #expect(model.care.isHelpPresented)
        model.care.helpClosed()
        #expect(model.care.checkIn?.delay == .tomorrow)
        await model.care.checkIn?.decline()
        await model.care.choose(.safe, in: try #require(model.care.entries.last))
        #expect(model.care.checkIn != nil)
    }

    @Test("Aku Tidak Aman after a danger message records nothing more")
    func dangerOnce() async throws {
        let checkIns = FakeCheckInService()
        let model = await loaded(checkIns: checkIns)
        model.composerText = board
        await model.send()
        await model.care.choose(.unsafe, in: try #require(model.care.entries.last))
        #expect(checkIns.signals.count == 1)
    }
}
