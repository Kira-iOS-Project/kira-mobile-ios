/**
 The rows of the Catat chat (canvas Catat, CatatTersimpan, HasilScan): the person's bubble, Kira's
 drafts with their card, the saved transactions with Urungkan, and the engine's remaining money.
 Every Kira reply says where it came from ("dari pesan 12.41 WIB"), so a transaction can be traced.
 */
import Domain
import Features
import SwiftUI

/** The person's text, or the photo of a scanned receipt. */
struct PersonBubble: View {
    let message: ChatMessage
    let initial: String

    var body: some View {
        KiraChatBubble(.user, initial: initial) {
            if message.kind == .personReceipt {
                VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                    ReceiptThumbnail(storeName: message.body ?? "")
                    Text("record.receipt.photo")
                }
                .padding(.top, KiraSpacing.space1)
            } else {
                Text(message.body ?? "")
            }
        }
    }
}

/** Kira's drafts, waiting for Simpan or the pencil (CAT-01, CAT-06). */
struct DraftsReply: View {
    let message: ChatMessage
    let source: ChatMessage?
    let model: RecordModel

    private var isReceipt: Bool { source?.kind == .personReceipt }

    var body: some View {
        let pairs = (message.drafts ?? []).map { (card: DraftCardItem.of($0), item: $0) }
        let card = KiraDraftCard(
            items: pairs.map(\.card), total: Decimal(message.draftTotal),
            onSave: { Task { await model.save(message) } },
            onEdit: { edited in
                if let item = pairs.first(where: { $0.card.id == edited.id })?.item { model.edit(item, in: message) }
            })
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            if isReceipt {
                KiraChatBubble(.kira, meta: "record.meta.receipt") {
                    Text("record.drafts.receipt \(source?.body ?? "")")
                }
                card.eyebrow("record.drafts.receiptEyebrow")
                KiraNotice(.privacy, message: "record.receipt.privacy")
            } else {
                KiraChatBubble(
                    .kira, meta: "record.meta.answered \(model.sourceTime(of: message).formatted(RecordFormat.time))"
                ) {
                    sentence
                }
                card.secondary("record.continueChat", action: model.continueChat)
            }
        }
    }

    private var sentence: Text {
        let count = message.drafts?.count ?? 0
        switch message.draftType {
        case .expense: return Text("record.drafts.expenses \(count)")
        case .income: return Text("record.drafts.income \(count)")
        case nil: return Text("record.drafts.mixed \(count)")
        }
    }
}

/** Saved transactions: Urungkan beside the meta for ten seconds, then the meta alone (CAT-03). */
struct SavedReply: View {
    let message: ChatMessage
    let source: ChatMessage?
    let canUndo: Bool
    let onUndo: () -> Void

    private var count: Int { message.drafts?.count ?? 0 }
    private var time: String { (source?.createdAt ?? message.createdAt).formatted(RecordFormat.time) }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            KiraChatBubble(.kira, meta: canUndo ? nil : "record.meta.saved \(time)") { sentence }
                .saved(SavedItems.of(message))
            if canUndo {
                HStack(spacing: 6) {
                    Text("record.meta.saved \(time)").font(.caption.weight(.medium))
                    Text("record.dot").font(.caption).accessibilityHidden(true)
                    Button(action: onUndo) {
                        HStack(spacing: KiraSpacing.space1) {
                            KiraIcon(.refresh, size: 14, weight: .bold)
                            Text("record.undo")
                        }
                        .font(.footnote.weight(.semibold)).foregroundStyle(.pandan)
                        .padding(.leading, 2).padding(.trailing, KiraSpacing.space2)
                        .frame(minHeight: KiraSize.tap)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, -14)
                    .accessibilityLabel(Text("record.undo.label \(count)"))
                }
                .foregroundStyle(.inkMuted)
                .padding(.leading, 44)
            }
        }
    }

    private var sentence: Text {
        count == 1 ? Text("record.saved.one") : Text("record.saved.many \(countWord(count))")
    }
}

/** The engine's remaining money and per day (CAT-03: "Dihitung mesin"). */
struct RemainingReply: View {
    let message: ChatMessage

    var body: some View {
        let remaining = Decimal(message.remaining ?? 0)
        let perDay = Decimal(message.perDay ?? 0)
        KiraChatBubble(.kira, meta: "record.meta.engine") {
            Text("record.remaining \(remaining, format: .rupiah) \(perDay, format: .rupiah)")
        }
    }
}
