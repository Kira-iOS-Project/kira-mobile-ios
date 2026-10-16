import APIClient
import Domain
import Foundation
import Observation

/**
 A person's message and Kira's replies to it, which Riwayat Percakapan draws under one time
 separator. The block holding the transaction's source message is framed ("Pesan Sumber
 Transaksi"), except its engine-computed remaining-money note, which follows the frame.
 */
package struct ConversationBlock: Identifiable, Hashable, Sendable {
    /** The messages of the block, the person's first; never empty. */
    package let messages: [ConversationMessage]
    /** Whether the block holds the transaction's source message. */
    package let isSource: Bool

    /** The id of the block's first message. */
    package var id: String { messages[0].id }
    /** When the block's first message was written, shown above it. */
    package var startedAt: Date { messages[0].createdAt }
    /** The messages inside the frame (all of them when the block is not the source). */
    package var framed: [ConversationMessage] { isSource ? messages.filter { $0.kind != .remaining } : messages }
    /** The messages after the frame. */
    package var trailing: [ConversationMessage] { isSource ? messages.filter { $0.kind == .remaining } : [] }
}

/** Riwayat Percakapan (CAT-08f): the read-only chat log around a transaction's source message. */
@MainActor
@Observable
package final class ConversationModel {
    /** The person's message the transaction was read from. */
    package let sourceMessageId: String
    /** The log's blocks once loaded. */
    package private(set) var phase: ScreenPhase<[ConversationBlock]> = .loading
    /** The initial beside the person's bubbles; nil until known, and the log shows without it. */
    package private(set) var personInitial: String?

    private let service: any HistoryService

    /** A log around `sourceMessageId`, loaded by `load()`. */
    package init(sourceMessageId: String, service: any HistoryService) {
        self.sourceMessageId = sourceMessageId
        self.service = service
    }

    /** Loads the messages around the source message, and the person's initial beside them. */
    package func load() async {
        async let account = try? service.currentAccount()
        do {
            let messages = try await service.messages(around: sourceMessageId)
            personInitial = await account?.initial
            let blocks = Self.blocks(messages, source: sourceMessageId)
            phase = blocks.isEmpty ? .empty : .loaded(blocks)
        } catch {
            phase = .failed(historyProblem(error))
        }
    }

    /** The block the screen scrolls to: the one holding the source message. */
    package var sourceBlockId: String? {
        phase.value?.first(where: \.isSource)?.id
    }

    /** Starts a block at each of the person's messages; Kira's replies join the block before them. */
    static func blocks(_ messages: [ConversationMessage], source: String) -> [ConversationBlock] {
        var groups: [[ConversationMessage]] = []
        for message in messages {
            if message.sender == .person || groups.isEmpty {
                groups.append([message])
            } else {
                groups[groups.count - 1].append(message)
            }
        }
        return groups.map { group in
            ConversationBlock(messages: group, isSource: group.contains { $0.id == source })
        }
    }
}
