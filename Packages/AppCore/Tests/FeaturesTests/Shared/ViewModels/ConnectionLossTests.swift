import APIClient
import Domain
import Testing

@testable import Features

/**
 Each area's screen with the server unreachable, through its live service and the generated
 client: the screen shows the connection message (`isConnectionLoss`), never the generic problem
 with "UNKNOWN" that the live e2e walk found on Catat with the backend stopped.
 */
@MainActor
@Suite("Connection loss per area")
struct ConnectionLossTests {
    private static func lost<Value>(_ phase: ScreenPhase<Value>) -> Bool {
        guard case .failed(let problem) = phase else { return false }
        return problem.isConnectionLoss
    }

    @Test("Beranda, Kira Score, an indicator, Catat and Riwayat show the connection message")
    func screens() async {
        let home = HomeModel(service: LiveHomeService(api: .down, onHideBalances: HideBalancesRecorder().sync))
        await home.load()
        #expect(Self.lost(home.phase))

        let score = ScoreModel(service: LiveScoreService(api: .down))
        await score.load()
        #expect(Self.lost(score.phase))

        let indicator = IndicatorModel(key: .emergencyFund, service: LiveScoreService(api: .down))
        await indicator.load()
        #expect(Self.lost(indicator.phase))

        let record = RecordModel(dependencies: Self.recordDependencies)
        await record.load()
        #expect(Self.lost(record.phase))

        let history = HistoryModel(service: LiveHistoryService(api: .down), pause: { _ in })
        await history.load()
        #expect(Self.lost(history.phase))
    }

    @Test("Kira Peduli's contacts keep the shipped list and mark the connection as lost")
    func care() async {
        let care = CareContactsModel(service: LiveCareService(api: .down))
        await care.load()
        #expect(care.problem?.isConnectionLoss == true)
    }

    private static var recordDependencies: RecordDependencies {
        let ids = IdSequence()
        return RecordDependencies(
            service: LiveRecordService(api: .down), reader: MessageReader(fallbackName: "Transaksi", refiner: nil),
            receiptReader: FakeReceiptReader(), camera: FakeCamera(), transcriber: FakeTranscriber(),
            clock: ManualClock(), makeId: { ids.next() }, receiptName: "Struk", categoryName: { $0.rawValue },
            receiptAssistant: nil)
    }
}
