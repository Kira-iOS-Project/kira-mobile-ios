/**
 Catat for `ScreenLaunch`. The chat opens on the boards' sample; the UI tests tap the composer to
 open what Catat shows over itself (Catat Manual, Scan Struk, the drafts sheet). Two screens need an
 account the sample is not: the voice panel needs Kira Plus, and Kuota AI a receipt quota used up,
 so their launches answer the profile for that account and leave every other call to the preview.
 */
#if DEBUG
    import Domain
    import Features
    import SwiftUI

    struct CatatLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                RecordScreen(dependencies: dependencies) { _ in }
            }
        }

        private var dependencies: RecordDependencies {
            let preview = PreviewRecordData.dependencies
            let account: LaunchRecordService.Account? =
                switch screen {
                case .recordVoice: .plus
                case .recordQuota: .receiptsUsedUp
                default: nil
                }
            guard let account else { return preview }
            return RecordDependencies(
                service: LaunchRecordService(account: account, preview: preview.service),
                reader: preview.reader, receiptReader: preview.receiptReader, camera: preview.camera,
                transcriber: preview.transcriber, receiptName: preview.receiptName,
                categoryName: preview.categoryName)
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
#endif
