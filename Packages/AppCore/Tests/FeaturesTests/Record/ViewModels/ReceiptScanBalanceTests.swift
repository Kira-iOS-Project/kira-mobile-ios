import Domain
import Foundation
import Testing
@testable import Features

@MainActor
@Suite("ReceiptScanModel with an unbalanced receipt")
struct ReceiptScanBalanceTests {
    @Test("a total the items do not add up to is sent anyway, the gap as one Belanja line")
    func unbalanced() async throws {
        let service = FakeRecordService()
        service.receiptResult = .success(
            SendResult(
                person: Fixtures.person("m1", "Toko", kind: .personReceipt), reply: nil, quotaExhausted: false,
                usage: Fixtures.usage(receipts: 5)))
        let lines = ["TOKO ANEKA", "Roti 8.000", "PPN 800", "TOTAL 9.500"]
        let scan = ReceiptScanModel(
            quota: UsageMeter(used: 4, limit: 10),
            dependencies: Fixtures.dependencies(
                service: service, receiptReader: FakeReceiptReader(result: .success(lines)), camera: FakeCamera()),
            onRead: { _ in }, onManual: {}, onAIOff: {})
        scan.picked(Data([1]), fileName: nil)
        await scan.read()
        let receipt = try #require(service.receipts.first)
        #expect(scan.problem == nil && receipt.total == 9_500)
        #expect(receipt.items.map(\.amount) == [8_000, 1_500])
    }
}
