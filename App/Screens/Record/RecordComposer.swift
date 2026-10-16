/**
 The composer (canvas Catat; CatatMengetik for CAT-03b): camera to Scan Struk, pencil to Catat
 Manual, the text field, the microphone to Input Suara and the send button, in one raised capsule.
 While the person types it has a 1.5 pt pandan border; nothing is saved until Kirim.
 */
import Domain
import Features
import SwiftUI

struct RecordComposer: View {
    @Bindable var model: RecordModel
    @FocusState private var isFocused: Bool

    private var isActive: Bool { isFocused || !model.composerText.isEmpty }

    var body: some View {
        HStack(spacing: 2) {
            KiraIconButton(.camera, label: "record.composer.scan", action: model.openScanner)
            KiraIconButton(.pencil, label: "record.composer.manual", action: model.openManual)
            field
            KiraIconButton(.mic, label: "record.composer.voice", action: model.openVoice)
            Button {
                Task { await model.send() }
            } label: {
                KiraIcon(.arrowUp, size: 20, weight: .semibold)
                    .foregroundStyle(.onPandan)
                    .frame(width: KiraSize.tap, height: KiraSize.tap)
                    .background(.pandan, in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(model.isSending)
            .accessibilityLabel(Text("record.composer.send"))
        }
        .padding(5)
        .background(.surfaceRaised, in: Capsule())
        .overlay {
            Capsule().strokeBorder(isActive ? Color.pandan : .hairline, lineWidth: isActive ? 1.5 : 1)
        }
        .onChange(of: model.composerFocusRequests) { isFocused = true }
    }

    private var field: some View {
        ZStack(alignment: .leading) {
            if model.composerText.isEmpty {
                Text("record.composer.prompt").foregroundStyle(.inkMuted).lineLimit(1).accessibilityHidden(true)
            }
            TextField(text: $model.composerText, prompt: Text(verbatimPrompt)) { Text("record.composer.label") }
                .focused($isFocused)
                .submitLabel(.send)
                .onSubmit { Task { await model.send() } }
                .foregroundStyle(.ink)
        }
        .font(.body)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, minHeight: KiraSize.tap)
    }

    /** No system prompt: the field draws its own, which keeps the design's colour. */
    private var verbatimPrompt: String { "" }
}

/** "Kira AI" is off: chat, receipts and voice wait; Catat Manual works; a link to Data & Privasi. */
struct RecordAIOffNotice: View {
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            KiraNotice(.aiText, title: "record.aiOff.title", message: "record.aiOff.body")
            KiraLink("record.aiOff.link", action: onOpen)
        }
    }
}
