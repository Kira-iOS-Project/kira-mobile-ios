/**
 Lupa PIN's second step, laid out as ONB-14 Kunci Kira (board KunciAplikasi.dc.html): the padlock,
 the title and its line, the six PIN boxes with the eye that shows them and the hint, and Simpan PIN.
 The balance toggle and Nanti Saja stay on ONB-14: here the PIN is required to open Kira again.
 */
import Domain
import Features
import SwiftUI

struct RecoveryNewPinView: View {
    @Bindable var model: PinRecoveryModel

    var body: some View {
        ScrollView {
            VStack(spacing: KiraSpacing.space6) {
                KiraNavBar("lock.recovery.pin.title")
                VStack(spacing: KiraSpacing.space3) {
                    KiraIllustration(.padlock, size: 128)
                    Text("lock.recovery.pin.heading")
                        .kiraFont(.title)
                        .foregroundStyle(.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("lock.recovery.pin.body")
                        .font(.body)
                        .kiraLineHeight(22, size: 17)
                        .foregroundStyle(.inkMuted)
                }
                .multilineTextAlignment(.center)
                KiraCodeField("lock.recovery.pin.field", code: $model.newPin, kind: .pin)
                    .hint("lock.recovery.pin.hint")
                    .error(pinError)
                KiraButton("lock.recovery.pin.save", action: model.savePin)
                    .block()
                    .disabled(model.newPin.count < PinPolicy.length)
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.bottom, KiraSpacing.space2)
        }
        .background { RecoveryBackground() }
        .kiraScrollEdges()
    }

    private var pinError: LocalizedStringResource? {
        switch model.pinProblem {
        case .notSixDigits: "lock.recovery.pin.error.length"
        case .tooSimple: "lock.recovery.pin.error.simple"
        case nil: nil
        }
    }
}
