import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("RecordModel openings")
struct RecordModelOpeningsTests {
    private func loaded(
        _ service: FakeRecordService, profile: RecordProfile = Fixtures.profile(),
        transcriber: FakeTranscriber = FakeTranscriber(), reader: FakeReceiptReader = FakeReceiptReader()
    ) async -> RecordModel {
        service.profileResult = .success(profile)
        let model = RecordModel(
            dependencies: Fixtures.dependencies(service: service, receiptReader: reader, transcriber: transcriber))
        await model.load()
        return model
    }

    @Test("nothing opens before the profile has loaded")
    func beforeLoad() {
        let model = RecordModel(dependencies: Fixtures.dependencies(service: FakeRecordService()))
        model.openManual()
        model.openScanner()
        model.openVoice()
        #expect(model.manualEntry == nil && model.scanner == nil && model.voice == nil)
    }

    @Test("Catat Manual opens, closes the quota sheet, and adds its saved message to the chat")
    func manual() async throws {
        let service = FakeRecordService()
        let model = await loaded(service)
        model.quotaSheet = model.sheet(for: .aiMessages)
        model.openManual()
        #expect(model.quotaSheet == nil)
        let form = try #require(model.manualEntry)
        service.manualResult = .success(
            ManualSaveResult(message: Fixtures.kira("k9", kind: .manualSaved)))
        form.amountText = "45000"
        await form.save()
        #expect(model.messages.map(\.id) == ["k9"])
    }

    @Test("Scan Struk opens with its quota; a read receipt joins the chat; Ketik Manual swaps to the form")
    func scanner() async throws {
        let service = FakeRecordService()
        let model = await loaded(service, reader: FakeReceiptReader(result: .success(["Roti 15.000", "TOTAL 15.000"])))
        model.openScanner()
        let scan = try #require(model.scanner)
        #expect(scan.quota == UsageMeter(used: 4, limit: 10))
        scan.typeManually()
        #expect(model.scanner == nil)
        #expect(model.manualEntry != nil)
        model.openScanner()
        let reading = try #require(model.scanner)
        let exhausted = SendResult(
            person: Fixtures.person("m1", "Toko", kind: .personReceipt), reply: nil, quotaExhausted: true,
            usage: Fixtures.usage(receipts: 10))
        service.receiptResult = .success(exhausted)
        reading.picked(Data([1]), fileName: nil)
        await reading.read()
        #expect(model.scanner == nil)
        #expect(model.quotaSheet?.kind == .receipts)
    }

    @Test("no scanner with the receipts used up or Kira AI off")
    func scannerBlocked() async {
        let full = await loaded(FakeRecordService(), profile: Fixtures.profile(usage: Fixtures.usage(receipts: 10)))
        full.openScanner()
        #expect(full.scanner == nil)
        #expect(full.quotaSheet?.kind == .receipts)
        let off = await loaded(FakeRecordService(), profile: Fixtures.profile(aiEnabled: false))
        off.openScanner()
        off.openVoice()
        #expect(off.showsAIOff)
        var routes: [AppRoute] = []
        off.onOpen = { routes.append($0) }
        off.openPrivacy()
        #expect(!off.showsAIOff)
        #expect(routes == [.privacy])
    }

    @Test("the microphone: plans without voice, the quota sheet when used up, else the panel")
    func voice() async throws {
        var routes: [AppRoute] = []
        let free = await loaded(FakeRecordService())
        free.onOpen = { routes.append($0) }
        free.openVoice()
        #expect(routes == [.plans(yearly: false)])
        let used = await loaded(
            FakeRecordService(), profile: Fixtures.profile(usage: Fixtures.usage(voice: (10_800, 10_800))))
        used.openVoice()
        #expect(used.quotaSheet?.kind == .voice)
        let transcriber = FakeTranscriber()
        let service = FakeRecordService()
        service.sendResult = .success(
            SendResult(
                person: Fixtures.person("m1", "parkir 5rb"), reply: nil, quotaExhausted: false,
                usage: Fixtures.usage(voice: (1, 10_800))))
        let plus = await loaded(
            service, profile: Fixtures.profile(usage: Fixtures.usage(voice: (0, 10_800))), transcriber: transcriber)
        plus.openVoice()
        let panel = try #require(plus.voice)
        let listening = Task { await panel.start() }
        await settle()
        transcriber.continuation?.yield(VoiceUpdate(transcript: "parkir lima ribu", level: 0.5))
        await settle()
        await panel.stop()
        await listening.value
        await settle()
        #expect(plus.voice == nil)
        #expect(service.sent.first?.inputMethod == .voice)
        #expect(service.sent.first?.voiceSeconds == 1)
        plus.openVoice()
        let second = try #require(plus.voice)
        await second.cancel()
        #expect(plus.voice == nil)
    }

    @Test("Lihat Paket, Riwayat and the help button leave Catat")
    func routes() async {
        var routes: [AppRoute] = []
        let model = await loaded(FakeRecordService())
        model.onOpen = { routes.append($0) }
        model.quotaSheet = model.sheet(for: .aiMessages)
        model.openPlans()
        model.openHistory()
        model.openHelp()
        #expect(model.quotaSheet == nil)
        #expect(routes == [.plans(yearly: false), .history, .unavailable(.care)])
        let unset = RecordModel(dependencies: Fixtures.dependencies(service: FakeRecordService()))
        unset.openHistory()
    }
}
