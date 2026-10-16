import Domain
import Foundation

/**
 What Catat asks of the device, all on the device and never on a server: Apple's Foundation Models
 to tidy the drafts the rules read, Vision to read a receipt, Speech to transcribe a voice note,
 and the camera. The app target implements each with the system frameworks.
 */

/** Renames and recategorises the drafts the slang rules read; never changes an amount. */
package protocol DraftRefining: Sendable {
    /**
     Whether the on-device model supports Indonesian. While it does not (Apple's model lacks id_ID
     today), the slang rules' drafts go as they are and the model is never asked.
     */
    func supportsIndonesian() async -> Bool

    /**
     A refinement per draft the rules read from `text`, or nil when no on-device model is
     available (before iOS 26, Apple Intelligence off, the model not downloaded) or it failed.
     */
    func refine(_ text: String, drafts: [DraftCandidate]) async -> [DraftRefinement]?
}

/** A better name and category for the draft at `index` of the rules' list. */
package struct DraftRefinement: Equatable, Sendable {
    /** The draft's place in the rules' list. */
    package let index: Int
    /** The new name, in Title Case. */
    package let name: String
    /** The new category, on the draft's own side. */
    package let category: TransactionCategory

    /** A refinement of the draft at `index`. */
    package init(index: Int, name: String, category: TransactionCategory) {
        self.index = index
        self.name = name
        self.category = category
    }
}

/**
 Looks at a receipt photo with the on-device model (iOS 27 and later, with image input) for what the
 text alone may miss: the store's name and whether it is a receipt or a transfer proof. Never asked
 for a number; nil whenever the model is missing or fails.
 */
package protocol ReceiptAssisting: Sendable {
    /** The model's look at `image`, or nil without a model with image input or on any error. */
    func glance(at image: Data) async -> ReceiptGlance?
}

/** What the model saw on a receipt photo or a transfer proof. */
package struct ReceiptGlance: Equatable, Sendable {
    /** The store or recipient name the model read, as it wrote it. */
    package let storeName: String?

    /** A glance at a photo. */
    package init(storeName: String?) {
        self.storeName = storeName
    }
}

/** Reads the printed lines of a receipt photo, top to bottom. */
package protocol ReceiptTextReading: Sendable {
    /** The lines of `image` (JPEG or HEIC data), top to bottom. */
    func lines(in image: Data) async throws -> [String]
}

/** The camera of Scan Struk (CAT-05), always dark, its preview drawn by the app. */
package protocol ReceiptCapturing: Sendable {
    /** Starts the camera session for the preview. */
    func start() async throws
    /** Stops the session and turns the torch off. */
    func stop() async
    /** A still photo as JPEG data, held in memory only and dropped once read. */
    func capture() async throws -> Data
    /** Turns the torch on or off. */
    func setTorch(_ isOn: Bool) async
}

/** Transcribes speech on the device (CAT-10); the audio is never kept. */
package protocol VoiceTranscribing: Sendable {
    /** Asks for the microphone and speech recognition, once; true when both are allowed. */
    func requestAccess() async -> Bool
    /** Starts listening: the transcript so far and the input level, until `stop()`. */
    func start() async throws -> AsyncThrowingStream<VoiceUpdate, any Error>
    /** Stops listening and ends the stream. */
    func stop() async
}

/** The transcript so far and the microphone level from 0 to 1. */
package struct VoiceUpdate: Equatable, Sendable {
    /** Everything heard so far. */
    package let transcript: String
    /** The input level, from 0 to 1. */
    package let level: Double

    /** An update with the transcript and the level. */
    package init(transcript: String, level: Double) {
        self.transcript = transcript
        self.level = level
    }
}

/** The time and the waiting Catat needs, so tests fix both. */
package protocol RecordClock: Sendable {
    /** The current time. */
    var now: Date { get }
    /** Waits `seconds`, or throws when the task is cancelled. */
    func sleep(seconds: Double) async throws
}

/** The system's clock. */
package struct SystemRecordClock: RecordClock {
    /** The system clock. */
    package init() {}

    /** The current time. */
    package var now: Date { Date() }

    /** Waits `seconds` with `Task.sleep`. */
    package func sleep(seconds: Double) async throws {
        try await Task.sleep(for: .seconds(seconds))
    }
}
