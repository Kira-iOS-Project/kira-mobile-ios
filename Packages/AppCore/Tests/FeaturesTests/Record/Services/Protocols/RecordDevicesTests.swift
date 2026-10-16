import Domain
import Foundation
import Testing

@testable import Features

@Suite("RecordDevices")
struct RecordDevicesTests {
    @Test("the system clock tells the time and sleeps")
    func systemClock() async throws {
        let clock = SystemRecordClock()
        let before = Date()
        try await clock.sleep(seconds: 0.001)
        #expect(clock.now >= before)
    }

    @Test("default ids are unique UUIDs")
    func defaultIds() {
        let dependencies = RecordDependencies(
            service: FakeRecordService(), reader: MessageReader(fallbackName: "T", refiner: nil),
            receiptReader: FakeReceiptReader(), camera: FakeCamera(), transcriber: FakeTranscriber(),
            receiptName: "Struk", categoryName: { $0.rawValue })
        let first = dependencies.makeId()
        #expect(first != dependencies.makeId())
        #expect(UUID(uuidString: dependencies.makeId()) != nil)
        #expect(dependencies.categoryName(.food) == "food")
        #expect(dependencies.clock.now <= Date())
    }
}
