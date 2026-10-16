import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("ReceiptScanModel")
struct ReceiptScanModelTests {
    private let board = [
        "TOKO SEJAHTERA", "15-10-2026 12:58", "Beras 5 Kg 72.000,00", "Minyak Goreng 2 L 38.000,00",
        "Sabun Cuci 15.500,00", "TOTAL 125.500,00", "TUNAI 150.000,00",
    ]

    private func model(
        _ service: FakeRecordService, reader: FakeReceiptReader = FakeReceiptReader(),
        camera: FakeCamera = FakeCamera(),
        onRead: @escaping (SendResult) -> Void = { _ in }, onManual: @escaping () -> Void = {}
    ) -> ReceiptScanModel {
        ReceiptScanModel(
            quota: UsageMeter(used: 4, limit: 10),
            dependencies: Fixtures.dependencies(service: service, receiptReader: reader, camera: camera),
            onRead: onRead, onManual: onManual)
    }

    @Test("the camera starts and stops, the torch toggles, the shutter freezes a photo, Foto Ulang returns")
    func camera() async {
        let camera = FakeCamera()
        let scan = model(FakeRecordService(), camera: camera)
        #expect(scan.quota.used == 4)
        await scan.appeared()
        #expect(camera.isRunning)
        await scan.toggleTorch()
        await scan.toggleTorch()
        #expect(camera.torch == [true, false])
        #expect(scan.image == nil)
        await scan.capture()
        #expect(scan.stage == .photo(Data([1, 2, 3])))
        #expect(scan.image == Data([1, 2, 3]))
        scan.retake()
        #expect(scan.stage == .camera)
        await scan.disappeared()
        #expect(!camera.isRunning)
    }

    @Test("a camera that cannot start or shoot shows its problem")
    func cameraProblems() async {
        let camera = FakeCamera()
        camera.startError = OfflineError()
        camera.photo = .failure(OfflineError())
        let scan = model(FakeRecordService(), camera: camera)
        await scan.appeared()
        #expect(scan.problem == .camera)
        await scan.capture()
        #expect(scan.stage == .camera)
    }

    @Test("Baca Struk on a picked image sends only the text, with categories and the printed time")
    func read() async throws {
        let service = FakeRecordService()
        let result = SendResult(
            person: Fixtures.person("m1", "Toko Sejahtera", kind: .personReceipt), reply: nil, quotaExhausted: false,
            usage: Fixtures.usage(receipts: 5))
        service.receiptResult = .success(result)
        var received: SendResult?
        let scan = model(service, reader: FakeReceiptReader(result: .success(board))) { received = $0 }
        await scan.read()
        #expect(service.receipts.isEmpty)
        scan.picked(Data([9]), fileName: "IMG_2041.jpg")
        #expect(scan.stage == .picked(Data([9]), fileName: "IMG_2041.jpg"))
        await scan.read()
        let receipt = try #require(service.receipts.first)
        #expect(receipt.storeName == "Toko Sejahtera")
        #expect(receipt.total == 125_500)
        #expect(receipt.items.map(\.category) == [.shopping, .shopping, .shopping])
        let parts = ChatTimeline.calendar.dateComponents([.day, .hour, .minute], from: receipt.occurredAt)
        #expect([parts.day, parts.hour, parts.minute] == [15, 12, 58], "\(receipt.occurredAt)")
        #expect(received?.person.id == "m1")
        #expect(scan.stage == .reading)
        #expect(scan.image == nil)
    }

    @Test("an unreadable or unbalanced receipt asks to retake or type; a failure says why")
    func unreadable() async {
        let scan = model(FakeRecordService(), reader: FakeReceiptReader(result: .success(["Terima kasih"])))
        scan.picked(Data([1]), fileName: nil)
        await scan.read()
        #expect(scan.problem == .unreadable)
        #expect(scan.stage == .camera)
        var manual = false
        let failing = model(
            FakeRecordService(), reader: FakeReceiptReader(result: .failure(OfflineError())),
            onManual: { manual = true })
        failing.picked(Data([1]), fileName: nil)
        await failing.read()
        #expect(failing.problem == .failed(.connection))
        failing.typeManually()
        #expect(manual)
        #expect(failing.problem == nil)
    }

    @Test("items take their keyword's expense category; a receipt without head or date gets the defaults")
    func input() {
        let clock = ManualClock()
        let scan = ReceiptScanModel(
            quota: UsageMeter(used: 0, limit: 10),
            dependencies: Fixtures.dependencies(service: FakeRecordService(), clock: clock),
            onRead: { _ in }, onManual: {})
        let reading = ReceiptReading(
            storeName: nil, printedAt: ReceiptDate(day: 14, month: 10, year: 2026),
            items: [ReceiptLine(name: "Kopi Susu", amount: 18_000), ReceiptLine(name: "Gaji", amount: 1_000)],
            total: 19_000)
        let input = scan.input(for: reading)
        #expect(input.storeName == "Struk")
        #expect(input.items.map(\.category) == [.coffee, .shopping])
        #expect(ChatTimeline.calendar.component(.hour, from: input.occurredAt) == 12)
        let undated = ReceiptReading(storeName: "A", printedAt: nil, items: reading.items, total: 19_000)
        #expect(scan.input(for: undated).occurredAt == clock.now)
    }
}
