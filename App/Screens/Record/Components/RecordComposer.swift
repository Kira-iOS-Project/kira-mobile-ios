/**
 The composer (canvas Catat; CatatMengetik for CAT-03b): camera to Scan Struk, pencil to Catat
 Manual, the text field, the microphone to Input Suara and the send button, in one raised capsule.
 While the person types it has a 1.5 pt pandan border; nothing is saved until Kirim.
 */
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
            Button(action: submit) {
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

    /**
     Sends, and lets the keyboard down: each send gets a reply the person should read, and a crisis
     reply's counsellor card and Lihat Bantuan must never sit under the keyboard.
     */
    private func submit() {
        isFocused = false
        Task { await model.send() }
    }

    private var field: some View {
        ZStack(alignment: .leading) {
            if model.composerText.isEmpty { prompt }
            /**
             Vertical, so a long entry wraps at large text sizes instead of being cut off (Apple's
             audit reports a cut line as clipped text); Return still sends, as on the board.
             */
            TextField(text: $model.composerText, prompt: Text(verbatimPrompt), axis: .vertical) {
                Text("record.composer.label")
            }
            .lineLimit(1...4)
            .focused($isFocused)
            .submitLabel(.send)
            .onChange(of: model.composerText) { _, text in
                guard text.contains("\n") else { return }
                model.composerText = text.replacingOccurrences(of: "\n", with: "")
                submit()
            }
            .foregroundStyle(.ink)
            .accessibilityLabel(Text("record.composer.label"))
        }
        .font(.body)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, minHeight: KiraSize.tap)
    }

    /**
     "Ketik atau Ucapkan…": the words, then the board's three dots drawn, not typed. Apple's audit
     reads a text that ends in "…" as cut off.
     */
    private var prompt: some View {
        HStack(alignment: .lastTextBaseline, spacing: 1) {
            /** Never squeezed when the keyboard shortens the screen. */
            Text("record.composer.prompt").fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { _ in Circle().frame(width: 3, height: 3) }
            }
        }
        .foregroundStyle(.inkMuted)
        .accessibilityHidden(true)
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
