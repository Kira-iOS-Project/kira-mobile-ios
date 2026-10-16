/**
 The details card of Detail Transaksi: Kategori, Tanggal, Sumber and Catatan. Wallets do not exist
 yet, so the board's Dompet row is left out. For a transaction read from chat, Sumber quotes the
 message with the part that became this transaction in bold pandan, and opens the conversation.
 */
import Domain
import SwiftUI

struct TransactionDetailCard: View {
    let detail: TransactionDetail
    let openMessage: (String) -> Void
    let editNote: () -> Void

    var body: some View {
        let transaction = detail.transaction
        KiraRowStack {
            row("transaction.category") {
                KiraCategoryIcon(transaction.category.artwork, size: 38)
            } value: {
                Text(transaction.category.title)
            }
            row("transaction.date") {
                iconTile(.calendar)
            } value: {
                Text(KiraDateFormat.dateTime(transaction.occurredAt))
            }
            source
            Button(action: editNote) {
                row("transaction.note") {
                    iconTile(.pencil)
                } value: {
                    if let note = transaction.note, !note.isEmpty {
                        Text(note)
                    } else {
                        Text("transaction.note.add").foregroundStyle(.inkMuted)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, KiraSpacing.space4)
        .kiraCard()
    }

    @ViewBuilder private var source: some View {
        let transaction = detail.transaction
        if transaction.source == .chat, let quote = detail.sourceMessage {
            Button {
                openMessage(quote.id)
            } label: {
                HStack(alignment: .top, spacing: KiraSpacing.space3) {
                    iconTile(.chat)
                    VStack(alignment: .leading, spacing: 1) {
                        label("transaction.source")
                        Text(transaction.source.detailLabel).font(.body).kiraLineHeight(22, size: 17)
                        quoteBubble(quote.parts).padding(.top, KiraSpacing.space2)
                        Text(KiraDateFormat.dayTime(quote.createdAt))
                            .font(.subheadline).kiraLineHeight(20, size: 15)
                            .foregroundStyle(.inkMuted)
                            .padding(.top, KiraSpacing.space1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    KiraIcon(.chevronRight, size: 20).foregroundStyle(.inkMuted).frame(maxHeight: .infinity)
                }
                .padding(.top, 11)
                .padding(.bottom, 13)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("transaction.source.open \(time(quote.createdAt))"))
            .accessibilityAddTraits(.isButton)
            .kiraRowSeparator()
        } else {
            row("transaction.source") {
                iconTile(.chat)
            } value: {
                Text(transaction.source.detailLabel)
            }
        }
    }

    private func row<Leading: View, Value: View>(
        _ title: LocalizedStringResource, @ViewBuilder leading: () -> Leading, @ViewBuilder value: () -> Value
    ) -> some View {
        HStack(spacing: KiraSpacing.space3) {
            leading()
            VStack(alignment: .leading, spacing: 1) {
                label(title)
                value().font(.body).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 11)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .kiraRowSeparator()
    }

    private func label(_ text: LocalizedStringResource) -> some View {
        Text(text).font(.footnote.weight(.medium)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
    }

    /** The design system's row icon (`.k-row__icon`): pandan on pandan-soft. */
    private func iconTile(_ icon: KiraIconName) -> some View {
        KiraIcon(icon, size: 20)
            .foregroundStyle(.pandan)
            .frame(width: 38, height: 38)
            .kiraCard(.pandanSoft, border: .pandanLine, cornerRadius: KiraRadius.small)
            .accessibilityHidden(true)
    }

    /** The person's message as a small bubble, the span that became this transaction in bold pandan. */
    private func quoteBubble(_ parts: QuoteParts) -> some View {
        var highlight = AttributedString(parts.highlight)
        highlight.font = .subheadline.weight(.bold)
        highlight.foregroundColor = .pandan
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: 16, bottomLeadingRadius: 16, bottomTrailingRadius: 6, topTrailingRadius: 16,
            style: .continuous)
        return Text(AttributedString(parts.before) + highlight + AttributedString(parts.after))
            .font(.subheadline).kiraLineHeight(20, size: 15)
            .foregroundStyle(.ink)
            .padding(.vertical, KiraSpacing.space2)
            .padding(.horizontal, KiraSpacing.space3)
            .background(Color.pandanSoft, in: shape)
            .overlay { shape.strokeBorder(Color.pandanLine, lineWidth: 1) }
    }

    private func time(_ date: Date) -> String {
        KiraDateFormat.time.format(date)
    }
}
