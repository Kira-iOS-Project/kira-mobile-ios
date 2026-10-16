/**
 Riwayat Percakapan (CAT-08f): the Catat log around a transaction's source message, read only. It
 scrolls to the source message and frames it in pandan ("Pesan Sumber Transaksi"); the back button
 returns to Detail Transaksi. The dock the board draws belongs to the app's root, which shows it.
 */
import Domain
import Features
import SwiftUI

struct ConversationScreen: View {
    @State private var model: ConversationModel
    @Environment(\.dismiss) private var dismiss

    init(sourceMessageId: String, service: any HistoryService) {
        _model = State(initialValue: ConversationModel(sourceMessageId: sourceMessageId, service: service))
    }

    var body: some View {
        ScrollViewReader { reader in
            ScrollView {
                VStack(spacing: KiraSpacing.space2) {
                    KiraNavBar(
                        "conversation.title", subtitle: "conversation.subtitle",
                        leading: .back("conversation.back") { dismiss() })
                    content
                }
                .padding(.horizontal, KiraSpacing.screen)
                .padding(.top, KiraSpacing.space2)
                .padding(.bottom, KiraSpacing.space10)
                .background(alignment: .topTrailing) {
                    KiraLeaf(.twig, tone: .soft, size: 140, isFlipped: true).offset(x: 56, y: -38)
                }
            }
            .onChange(of: model.sourceBlockId) { _, id in
                if let id { reader.scrollTo(id, anchor: .center) }
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            ProgressView().frame(maxWidth: .infinity).padding(.vertical, KiraSpacing.space8)
        case .empty:
            Text("conversation.empty")
                .font(.body).foregroundStyle(.inkMuted)
                .padding(.vertical, KiraSpacing.space8)
        case .loaded(let blocks):
            VStack(spacing: KiraSpacing.space3) {
                ForEach(blocks) { block in
                    ConversationBlockView(block: block, initial: model.personInitial).id(block.id)
                }
            }
            .padding(.top, KiraSpacing.space2)
        case .failed(let problem):
            LoadFailedView(problem: problem) { Task { await model.load() } }
        }
    }
}

/** One block: the time it started, the person's message and Kira's replies, framed when it is the source. */
private struct ConversationBlockView: View {
    let block: ConversationBlock
    let initial: String?

    var body: some View {
        if block.isSource {
            VStack(alignment: .leading, spacing: 14) {
                Label {
                    Text("conversation.sourceLabel")
                } icon: {
                    KiraIcon(.chat, size: 14, weight: .bold)
                }
                .font(.caption.weight(.bold)).kiraLineHeight(16, size: 12)
                .foregroundStyle(.pandan)
                messages(block.framed)
            }
            .padding(.vertical, KiraSpacing.space4)
            .padding(.horizontal, 14)
            .background(Color.pandanSoft, in: RoundedRectangle(cornerRadius: KiraRadius.large, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: KiraRadius.large, style: .continuous)
                    .strokeBorder(Color.pandan, lineWidth: 1.5)
            }
            .padding(.horizontal, -4)
            .padding(.vertical, 6)
            .accessibilityElement(children: .contain)
            ForEach(block.trailing) { ConversationMessageView(message: $0, sentAt: block.startedAt, initial: initial) }
        } else {
            messages(block.framed)
        }
    }

    private func messages(_ messages: [ConversationMessage]) -> some View {
        VStack(spacing: KiraSpacing.space3) {
            Text(KiraDateFormat.dayTime(block.startedAt))
                .font(.caption.weight(.semibold)).kiraLineHeight(16, size: 12)
                .foregroundStyle(.inkMuted)
                .frame(maxWidth: .infinity)
            ForEach(messages) { ConversationMessageView(message: $0, sentAt: block.startedAt, initial: initial) }
        }
    }
}
