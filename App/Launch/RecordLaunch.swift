/**
 Catat for `ScreenLaunch`. The chat opens on the boards' sample; the UI tests tap the composer to
 open what Catat shows over itself (Catat Manual, Scan Struk, the drafts sheet). Two screens need an
 account the sample is not: the voice panel needs Kira Plus, and Kuota AI a receipt quota used up,
 so their launches answer the profile for that account and leave every other call to the preview.
 */
#if DEBUG
    import Domain
    import Foundation
    import Features
    import SwiftUI

    struct ChatLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                RecordScreen(dependencies: dependencies) { _ in }
            }
        }

        private var dependencies: RecordDependencies {
            let preview = PreviewRecordData.dependencies
            if screen == .checkInChat {
                return RecordDependencies(
                    service: preview.service, checkIns: PreviewCheckInService(isDue: true), crisis: preview.crisis,
                    reader: preview.reader, receiptReader: preview.receiptReader, camera: preview.camera,
                    transcriber: preview.transcriber, receiptName: preview.receiptName,
                    categoryName: preview.categoryName)
            }
            let account: LaunchRecordService.Account? =
                switch screen {
                case .recordVoice: .plus
                case .recordQuota: .receiptsUsedUp
                default: nil
                }
            guard let account else { return preview }
            /**
             The voice panel holds still for the audit: the whole sentence heard at once, and a timer
             that stops at 7 seconds. A panel that redraws while the audit samples it reads as low
             contrast; the app's own panel stays live.
             */
            let isVoice = account == .plus
            return RecordDependencies(
                service: LaunchRecordService(account: account, preview: preview.service),
                checkIns: preview.checkIns, crisis: preview.crisis, reader: preview.reader,
                receiptReader: preview.receiptReader, camera: preview.camera,
                transcriber: isVoice ? SettledTranscriber() : preview.transcriber,
                clock: isVoice ? SettledClock(seconds: 7) : SystemRecordClock(),
                receiptName: preview.receiptName, categoryName: preview.categoryName)
        }
    }

    /** The preview service with another account's plan and usage. */
    private struct LaunchRecordService: RecordService {
        /** Which account the profile describes. */
        enum Account {
            /** Kira Plus, three hours of voice left. */
            case plus
            /** Kira Gratis with all ten receipts used. */
            case receiptsUsedUp
        }

        let account: Account
        let preview: any RecordService

        func profile() async throws -> RecordProfile {
            let base = try await preview.profile()
            let usage = base.usage
            let changed =
                switch account {
                case .plus:
                    Usage(
                        aiMessages: UsageMeter(used: 112, limit: 300), receipts: UsageMeter(used: 23, limit: 150),
                        voiceSeconds: UsageMeter(used: 0, limit: 10_800), resetsOn: usage.resetsOn)
                case .receiptsUsedUp:
                    Usage(
                        aiMessages: usage.aiMessages, receipts: UsageMeter(used: 10, limit: 10),
                        voiceSeconds: usage.voiceSeconds, resetsOn: usage.resetsOn)
                }
            return RecordProfile(
                displayName: base.displayName, plan: account == .plus ? .plus : base.plan, usage: changed,
                periodStart: base.periodStart, periodEnd: base.periodEnd, aiEnabled: base.aiEnabled,
                lastExpenseCategory: base.lastExpenseCategory, lastIncomeCategory: base.lastIncomeCategory)
        }

        func messages(before cursor: String?) async throws -> ChatPage { try await preview.messages(before: cursor) }
        func send(_ message: OutgoingMessage) async throws -> SendResult { try await preview.send(message) }
        func updateDrafts(messageId: String, drafts: [DraftItem]) async throws -> ChatMessage {
            try await preview.updateDrafts(messageId: messageId, drafts: drafts)
        }
        func commit(messageId: String) async throws -> CommitResult { try await preview.commit(messageId: messageId) }
        func undo(batchId: String) async throws -> ChatMessage { try await preview.undo(batchId: batchId) }
        func sendReceipt(_ receipt: ReceiptInput) async throws -> SendResult { try await preview.sendReceipt(receipt) }
        func saveManual(_ transaction: ManualTransactionInput) async throws -> ManualSaveResult {
            try await preview.saveManual(transaction)
        }
    }

    /** Hears the board's sentence (InputSuara) at once, then nothing more until it is stopped. */
    private struct SettledTranscriber: VoiceTranscribing {
        private static let words = "tadi parkir lima ribu, terus makan bakso dua puluh ribu".split(separator: " ")

        func requestAccess() -> Bool { true }

        func start() -> AsyncThrowingStream<VoiceUpdate, any Error> {
            AsyncThrowingStream { continuation in
                for count in 1...Self.words.count {
                    let text = Self.words.prefix(count).joined(separator: " ")
                    continuation.yield(VoiceUpdate(transcript: text, level: Double(count % 5 + 2) / 7))
                }
            }
        }

        func stop() {}
    }

    /** A clock whose first `seconds` waits pass at once and whose next one lasts until cancelled. */
    private final class SettledClock: RecordClock, @unchecked Sendable {
        /** Touched only under `lock`. */
        private var remaining: Int
        private let lock = NSLock()

        init(seconds: Int) {
            remaining = seconds
        }

        var now: Date { Date() }

        func sleep(seconds _: Double) async throws {
            let passes = lock.withLock {
                remaining -= 1
                return remaining >= 0
            }
            if passes { return }
            try await Task.sleep(for: .seconds(86_400))
        }
    }
#endif
