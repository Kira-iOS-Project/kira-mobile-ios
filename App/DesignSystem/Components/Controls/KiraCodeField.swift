/**
 Code field (design canvas: "PIN 6 kotak (pola OTP)", ONB-14 Kunci Kira; ONB-07 Verifikasi Email):
 six boxes on the number pad.
   - `.pin`, the app lock's PIN: under a lock and its label, equal boxes (radius-md, 1.5 pt border:
     pandan on the next box, ink-muted once filled). Each digit is a dot, shown as the digit only
     while the person holds "Tahan untuk Lihat".
   - `.code`, the code sent by email: 48 pt boxes with a hairline, the digits shown; the next box
     has a pandan border, a pandan-line ring and a caret. The keyboard offers the code from Mail.
 A transparent field over the boxes takes the input, so typing, pasting a code ("Kode: 381 449"
 fills all six) and the keyboard's suggestion all work; the Domain's DigitCode keeps the digits.
 VoiceOver meets one field, named by `label`, that says the digits shown and how many are in
 ("3 8, 2 dari 6 angka terisi"); a masked PIN gives the count alone ("4 dari 6 angka terisi"). The
 PIN's label stays readable above it: the accessibility audit reports visible text VoiceOver
 cannot reach.
 */
import Domain
import SwiftUI

/** Six boxes for a PIN or a one-time code. */
struct KiraCodeField: View {
    /** What the code is. */
    enum Kind {
        /** The app lock's PIN: masked, revealed only while held. */
        case pin
        /** A one-time code from email: shown, and offered by the keyboard when it arrives. */
        case code
    }

    private let label: LocalizedStringResource
    @Binding private var code: String
    private let kind: Kind
    private var hintText: LocalizedStringResource?
    private var errorText: LocalizedStringResource?
    private let length = 6
    @State private var isRevealed = false
    @FocusState private var isFocused: Bool
    @ScaledMetric(relativeTo: .title2) private var boxHeight: CGFloat = 56
    /** An empty prompt: without one, the field would draw its label as a placeholder. */
    private static let noPrompt = ""

    init(_ label: LocalizedStringResource, code: Binding<String>, kind: Kind) {
        self.label = label
        _code = code
        self.kind = kind
    }

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            if kind == .pin { pinHeader }
            /**
             A tap anywhere on the boxes starts typing: the field over them answers only on its
             text line. VoiceOver reaches the field itself.
             */
            boxes
                .contentShape(Rectangle())
                .onTapGesture { isFocused = true }
                .accessibilityHidden(true)
                .overlay { input }
            if let message = errorText ?? hintText {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(errorText == nil ? Color.inkMuted : Color.rentan)
                    .padding(.horizontal, KiraSpacing.space1)
            }
        }
        .onChange(of: code) { _, typed in
            let digits = DigitCode.digits(in: typed, length: length)
            if digits != typed { code = digits }
        }
    }

    private var pinHeader: some View {
        HStack(spacing: KiraSpacing.space2) {
            HStack(spacing: 6) {
                KiraIcon(.lock, size: 16)
                Text(label)
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.inkMuted)
            Spacer(minLength: 0)
            KiraRevealButton(isRevealed: $isRevealed)
        }
        .padding(.leading, KiraSpacing.space1)
    }

    private var boxes: some View {
        HStack(spacing: kind == .pin ? KiraSpacing.space2 : 10) {
            ForEach(0..<length, id: \.self) { index in
                KiraCodeBox(
                    digit: digit(at: index), kind: kind, isMasked: kind == .pin && !isRevealed,
                    status: status(at: index), height: boxHeight)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var input: some View {
        Group {
            if kind == .pin {
                SecureField(text: $code, prompt: Text(Self.noPrompt)) { Text(label) }
            } else {
                TextField(text: $code, prompt: Text(Self.noPrompt)) { Text(label) }
                    .textContentType(.oneTimeCode)
            }
        }
        .keyboardType(.numberPad)
        .autocorrectionDisabled()
        .focused($isFocused)
        .foregroundStyle(.clear)
        .tint(.clear)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel(Text(label))
        .accessibilityValue(spokenValue)
    }

    /** The digits on screen, one by one, then how many are in; a masked PIN, the count alone. */
    private var spokenValue: Text {
        guard !code.isEmpty, kind == .code || isRevealed else {
            return Text("ds.code.count \(code.count) \(length)")
        }
        let digits = code.map(String.init).joined(separator: " ")
        return Text("ds.code.spoken \(digits) \(code.count) \(length)")
    }

    private func digit(at index: Int) -> Character? {
        index < code.count ? code[code.index(code.startIndex, offsetBy: index)] : nil
    }

    private func status(at index: Int) -> KiraCodeBox.Status {
        if errorText != nil { return .error }
        if isFocused && index == code.count { return .next }
        return index < code.count ? .filled : .empty
    }

    /** The same field with a hint under it, such as "Jangan pakai PIN bank atau tanggal lahir." */
    func hint(_ text: LocalizedStringResource) -> Self { copy { $0.hintText = text } }

    /** The same field in error, every box in `rentan`, with the sentence that says what to do. */
    func error(_ text: LocalizedStringResource?) -> Self { copy { $0.errorText = text } }

    private func copy(_ change: (inout Self) -> Void) -> Self {
        var field = self
        change(&field)
        return field
    }
}

#if DEBUG
    #Preview { GalleryEntry().galleryPage() }
#endif
