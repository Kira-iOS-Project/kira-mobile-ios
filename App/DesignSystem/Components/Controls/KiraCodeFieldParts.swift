/** The parts of KiraCodeField: one box, and the eye that shows the PIN while held. */
import SwiftUI

/** One box of a code: empty, a dot, or a digit. */
struct KiraCodeBox: View {
    /** Where the box is in the code. */
    enum Status {
        /** Not reached yet. */
        case empty
        /** The box the next digit goes into, while the field has focus. */
        case next
        /** Holds a digit. */
        case filled
        /** The code was not accepted. */
        case error
    }

    let digit: Character?
    let kind: KiraCodeField.Kind
    let isMasked: Bool
    let status: Status
    let height: CGFloat

    var body: some View {
        let radius = kind == .pin ? KiraRadius.medium : KiraRadius.small
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        ZStack {
            if let digit {
                if isMasked {
                    Circle().fill(.ink).frame(width: 12, height: 12)
                } else {
                    Text(String(digit))
                        .font(KiraFont.display(24, .heavy, relativeTo: .title2))
                        .foregroundStyle(.ink)
                }
            } else if status == .next && kind == .code {
                Capsule().fill(.pandan).frame(width: 2, height: height * 0.43)
            }
        }
        .frame(height: height)
        .frame(maxWidth: kind == .pin ? .infinity : 48)
        .background(.surfaceRaised, in: shape)
        .overlay { shape.strokeBorder(border, lineWidth: kind == .pin || status == .next ? 1.5 : 1) }
        .overlay {
            /** The focus ring of `.k-input`: a solid 3 pt band outside the box, not a shadow. */
            if status == .next && kind == .code {
                RoundedRectangle(cornerRadius: radius + 3, style: .continuous)
                    .strokeBorder(.pandanLine, lineWidth: 3)
                    .padding(-3)
            }
        }
    }

    private var border: Color {
        switch status {
        case .empty: .hairline
        case .next: .pandan
        case .filled: kind == .pin ? .inkMuted : .hairline
        case .error: .vulnerable
        }
    }
}

/**
 The eye beside the PIN: its digits show only while it is held. The eye stands alone, without the
 words "Tahan untuk Lihat" (the owner's choice, 2026-10-16), which stay its name for VoiceOver and
 Voice Control; those cannot hold, so they turn the digits on and off with the button's action.
 */
struct KiraRevealButton: View {
    @Binding var isRevealed: Bool

    var body: some View {
        KiraIcon(isRevealed ? .eyeOff : .eye, size: 20)
            .foregroundStyle(.pandan)
            .frame(minWidth: KiraSize.tap, minHeight: KiraSize.tap)
            .contentShape(Circle())
            .onLongPressGesture(
                minimumDuration: .infinity, maximumDistance: KiraSize.tap, perform: {},
                onPressingChanged: { pressing in isRevealed = pressing }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(isRevealed ? "ds.code.release" : "ds.code.hold"))
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { isRevealed.toggle() }
    }
}
