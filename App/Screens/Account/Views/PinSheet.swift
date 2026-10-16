/**
 The PIN sheet of Keamanan (AKN-03), in the pattern of canvas KunciAplikasi: six masked boxes
 revealed only while the eye is held, the reminder not to use a bank PIN when a new
 PIN is made, and Batal beside the step's action. It checks the PIN before the lock goes off or
 the PIN changes; the digits stay on the device.
 */
import Domain
import Features
import SwiftUI

/** The content of the PIN sheet. */
struct PinSheet: View {
    @Bindable var model: SecurityModel

    var body: some View {
        let prompt = model.pinPrompt ?? .create
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            KiraCodeField(prompt.label, code: $model.pin, kind: .pin)
                .hint(prompt.isNew ? "account.pin.hint" : "account.pin.verify.hint")
                .error(errorText)
            Spacer(minLength: 0)
            KiraButtonPair(
                secondary: KiraButton("account.cancel", variant: .secondary, action: model.cancelPin),
                primary: KiraButton(prompt.action) { Task { await model.submitPin() } }
            )
        }
        .padding(.bottom, KiraSpacing.space2)
    }

    private var errorText: LocalizedStringResource? {
        switch model.pinError {
        case .wrong: "account.pin.wrong"
        case .notSaved: "account.pin.notSaved"
        case nil: nil
        }
    }
}

extension PinPrompt {
    /** The sheet's title. */
    var title: LocalizedStringResource {
        switch self {
        case .verifyToDisable: "account.pin.disable.title"
        case .create: "account.pin.create.title"
        case .verifyToChange, .createReplacement: "account.pin.change.title"
        }
    }

    /** The boxes' label. */
    var label: LocalizedStringResource {
        switch self {
        case .verifyToDisable, .verifyToChange: "account.pin.current"
        case .create: "account.pin.new"
        case .createReplacement: "account.pin.replacement"
        }
    }

    /** The primary button. */
    var action: LocalizedStringResource {
        switch self {
        case .verifyToDisable: "account.pin.disable.action"
        case .create: "account.pin.create.action"
        case .verifyToChange: "account.pin.next"
        case .createReplacement: "account.pin.save"
        }
    }

    /** A new PIN is being made, so the bank-PIN reminder shows. */
    var isNew: Bool { self == .create || self == .createReplacement }
}

/** Kunci Otomatis: the three delays, the current one checked; a choice closes the sheet. */
struct AutoLockSheet: View {
    let model: SecurityModel

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            KiraListGroup(footer: "account.autoLock.footer") {
                ForEach(AutoLockDelay.allCases, id: \.self) { delay in
                    KiraListRow(Text(delay.title), trailing: .check(model.phase.value?.autoLock == delay)) {
                        Task { await model.setAutoLock(delay) }
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }
}
