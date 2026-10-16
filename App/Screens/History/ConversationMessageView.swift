/**
 One message of Riwayat Percakapan as a chat bubble: the person's text as they wrote it, and
 Kira's replies in Kira's words by kind (drafts waiting or saved, the engine's remaining money, no
 amount found), with the saved transactions inside the bubble. Read only: no Urungkan here.
 */
import Domain
import SwiftUI

struct ConversationMessageView: View {
    let message: ConversationMessage
    /** When the person's message of the block was sent, which Kira's notes refer to. */
    let sentAt: Date
    let initial: String?

    var body: some View {
        if message.sender == .person {
            KiraChatBubble(.user, initial: initial) { Text(message.body ?? "") }
        } else {
            KiraChatBubble(.kira, meta: meta) { Text(words) }.saved(saved)
        }
    }

    private var time: String { KiraDateFormat.time.format(sentAt) }

    private var words: LocalizedStringResource {
        switch message.kind {
        case .drafts where message.draftStatus == .committed: savedWords(message.drafts.count)
        case .drafts where message.draftStatus == .discarded: "conversation.kira.discarded"
        case .drafts: pendingWords
        case .manualSaved: "conversation.kira.savedOne"
        case .remaining: remainingWords
        case .noDrafts, .personText, .personReceipt: "conversation.kira.noDrafts"
        }
    }

    private var meta: LocalizedStringResource? {
        switch message.kind {
        case .drafts where message.draftStatus == .committed, .manualSaved: "conversation.kira.savedMeta \(time)"
        case .drafts, .noDrafts: "conversation.kira.aiMeta \(time)"
        case .remaining: "conversation.kira.engineMeta"
        case .personText, .personReceipt: nil
        }
    }

    private var saved: [KiraSavedTransaction] {
        guard message.draftStatus == .committed else { return [] }
        return message.drafts.map { draft in
            KiraSavedTransaction(
                label: Text(draft.name), amount: Decimal(draft.amount), category: draft.category.artwork,
                categoryName: Text(draft.category.title))
        }
    }

    /** "Sudah aku catat, ya." for one, "Tiga transaksi tersimpan." for several, as the board words it. */
    private func savedWords(_ count: Int) -> LocalizedStringResource {
        switch count {
        case 0, 1: "conversation.kira.savedOne"
        case 2: "conversation.kira.savedTwo"
        case 3: "conversation.kira.savedThree"
        case 4: "conversation.kira.savedFour"
        case 5: "conversation.kira.savedFive"
        default: "conversation.kira.savedMany \(count)"
        }
    }

    private var pendingWords: LocalizedStringResource {
        let count = message.drafts.count
        let types = Set(message.drafts.map(\.type))
        if types == [.income] { return "conversation.kira.pendingIncome \(count)" }
        if types == [.expense] { return "conversation.kira.pendingExpense \(count)" }
        return "conversation.kira.pendingMixed \(count)"
    }

    private var remainingWords: LocalizedStringResource {
        let remaining = RupiahFormatStyle().format(Decimal(message.remaining ?? 0))
        let perDay = RupiahFormatStyle().format(Decimal(message.perDay ?? 0))
        return "conversation.kira.remaining \(remaining) \(perDay)"
    }
}
