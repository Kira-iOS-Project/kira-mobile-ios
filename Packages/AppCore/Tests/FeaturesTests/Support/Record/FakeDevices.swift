import Domain
import Foundation

@testable import Features

/** A clock whose time each test sets and whose sleeps wait until the test wakes them. */
final class ManualClock: RecordClock, @unchecked Sendable {
    var now: Date
    private var sleepers: [CheckedContinuation<Void, any Error>] = []
    var sleeperCount: Int { sleepers.count }

    init(now: Date = Fixtures.noon) {
        self.now = now
    }

    func sleep(seconds _: Double) async throws {
        try await withCheckedThrowingContinuation { sleepers.append($0) }
    }

    /** Ends every sleep, or fails them all with `error`. */
    func wake(throwing error: (any Error)? = nil) {
        let waking = sleepers
        sleepers = []
        for sleeper in waking {
            if let error { sleeper.resume(throwing: error) } else { sleeper.resume() }
        }
    }
}

/** A refiner that answers what the test set. */
struct FakeRefiner: DraftRefining {
    let refinements: [DraftRefinement]?
    var knowsIndonesian = true

    func supportsIndonesian() -> Bool { knowsIndonesian }

    func refine(_: String, drafts _: [DraftCandidate]) -> [DraftRefinement]? { refinements }
}

/** The on-device model's look at a photo, as the test set it; counts how often it was asked. */
final class FakeReceiptAssistant: ReceiptAssisting, @unchecked Sendable {
    var glance: ReceiptGlance?
    private(set) var asked = 0

    init(_ glance: ReceiptGlance?) {
        self.glance = glance
    }

    func glance(at _: Data) -> ReceiptGlance? {
        asked += 1
        return glance
    }
}

/** Vision's stand-in: the lines the test set, or a failure. */
struct FakeReceiptReader: ReceiptTextReading {
    var result: Result<[String], any Error> = .success([])

    func lines(in _: Data) throws -> [String] { try result.get() }
}

/** The camera's stand-in. */
final class FakeCamera: ReceiptCapturing, @unchecked Sendable {
    var startError: (any Error)?
    var photo: Result<Data, any Error> = .success(Data([1, 2, 3]))
    private(set) var isRunning = false
    private(set) var torch: [Bool] = []

    func start() throws {
        if let startError { throw startError }
        isRunning = true
    }

    func stop() { isRunning = false }

    func capture() throws -> Data { try photo.get() }

    func setTorch(_ isOn: Bool) { torch.append(isOn) }
}

/** The speech recogniser's stand-in: the test feeds the stream and ends it. */
final class FakeTranscriber: VoiceTranscribing, @unchecked Sendable {
    var allowsAccess = true
    var startError: (any Error)?
    private(set) var continuation: AsyncThrowingStream<VoiceUpdate, any Error>.Continuation?
    private(set) var stopCount = 0

    func requestAccess() -> Bool { allowsAccess }

    func start() throws -> AsyncThrowingStream<VoiceUpdate, any Error> {
        if let startError { throw startError }
        let (stream, continuation) = AsyncThrowingStream<VoiceUpdate, any Error>.makeStream()
        self.continuation = continuation
        return stream
    }

    func stop() {
        stopCount += 1
        continuation?.finish()
    }
}

/** Lets the main actor run the tasks the code under test started. */
@MainActor
func settle() async {
    for _ in 0..<20 { await Task.yield() }
}
