/**
 The email field of Masuk and of the Buat Akun sheet, with the hint "Kira mengirim kode 6 digit ke
 email ini. Tanpa password.", a calm sentence when the address looks wrong, the API's problem when
 sending fails, and the button that asks for the code.
 */
import Features
import SwiftUI

struct EmailForm: View {
    @Bindable var model: EmailEntryModel
    let submitLabel: LocalizedStringResource

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraField("onboarding.email.label", text: $model.email)
                .hint("onboarding.email.hint")
                .error(model.showsInvalidEmail ? "onboarding.email.invalid" : nil)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.send)
                .onSubmit { Task { await model.submit() } }
            if let problem = model.phase.problem { ProblemMessage(problem: problem) }
            KiraButton(submitLabel) { Task { await model.submit() } }
                .block()
                .disabled(model.phase.isSubmitting)
        }
    }
}
