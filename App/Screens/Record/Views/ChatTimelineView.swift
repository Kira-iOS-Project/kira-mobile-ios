/**
 The chat history (canvas "Riwayat catatan"): rows 12 pt apart, a time separator above each new
 stretch, the newest at the bottom. Reaching the top loads the page before it.
 */
import Domain
import Features
import SwiftUI

struct ChatTimelineView: View {
    let model: RecordModel
    let initial: String

    var body: some View {
        ScrollViewReader { reader in
            ScrollView {
                /**
                 A plain stack, not a lazy one: Apple's audit cannot scale the text of rows a lazy
                 stack has not built, and reports partial Dynamic Type support on every message.
                 */
                VStack(spacing: KiraSpacing.space3) {
                    if model.hasOlder {
                        OlderMessagesLoader { Task { await model.loadOlder() } }
                    }
                    ForEach(model.rows) { row in
                        ChatRowView(row: row, model: model, initial: initial).id(row.id)
                    }
                }
                .padding(.horizontal, KiraSpacing.screen)
                .padding(.top, KiraSpacing.space2)
                .padding(.bottom, KiraSpacing.space4)
            }
            .coordinateSpace(name: OlderMessagesLoader.space)
            .scrollDismissesKeyboard(.interactively)
            .kiraScrollEdges()
            .defaultScrollAnchor(.bottom)
            .onChange(of: model.rows.last?.id) { _, last in
                guard let last else { return }
                withAnimation(.easeOut(duration: 0.25)) { reader.scrollTo(last, anchor: .bottom) }
            }
        }
    }
}

/** One row of the chat; without a model (Riwayat Percakapan) it is read only. */
struct ChatRowView: View {
    let row: ChatRow
    let model: RecordModel?
    let initial: String?

    var body: some View {
        switch row {
        case .separator(_, let date):
            Text(KiraDateFormat.dayTime(date))
                .font(.caption.weight(.semibold)).kiraLineHeight(16, size: 12)
                .foregroundStyle(.inkMuted)
                .frame(maxWidth: .infinity)
                .padding(.top, KiraSpacing.space2)
        case .person(let message):
            PersonBubble(message: message, initial: initial)
        case .drafts(let message, let source):
            if let model {
                DraftsReply(message: message, source: source, model: model)
            } else {
                DraftsNote(message: message, source: source)
            }
        case .saved(let message, let source, let canUndo):
            SavedReply(message: message, source: source, canUndo: canUndo) { Task { await model?.undo(message) } }
        case .discarded:
            KiraChatBubble(.kira) { Text("record.discarded") }
        case .remaining(let message):
            RemainingReply(message: message)
        case .manualSaved(let message):
            KiraChatBubble(.kira, meta: "record.meta.manual \(message.createdAt.formatted(.kiraTime))") {
                Text("record.saved.one")
            }
            .saved(SavedItems.of(message))
        case .noDrafts:
            KiraChatBubble(.kira) { Text("record.noDrafts") }
        case .care(let entry):
            CareChatRow(entry: entry, model: model?.care, initial: initial)
        }
    }
}

/**
 The spinner above the oldest message, which asks for the page before it once it scrolls into view.
 A plain stack builds every row at once, so its own appearance cannot be the signal.
 */
private struct OlderMessagesLoader: View {
    /** The scroll view's coordinate space. */
    static let space = "chat-timeline"
    let onVisible: () -> Void

    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: OlderMessagesVisible.self, value: proxy.frame(in: .named(Self.space)).maxY > 0)
                }
            }
            .onPreferenceChange(OlderMessagesVisible.self) { isVisible in
                if isVisible { onVisible() }
            }
    }
}

/** Whether the loader is inside the scroll view's visible area. */
private struct OlderMessagesVisible: PreferenceKey {
    static let defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}
