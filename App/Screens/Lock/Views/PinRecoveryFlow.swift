/**
 Lupa PIN (AKN-02): first the email check, laid out as ONB-07b Kode Verifikasi (board
 VerifikasiMasuk.dc.html: the letter, "Cek Emailmu", six code boxes, the resend countdown, the
 safety notice, Verifikasi), then a new PIN as ONB-14 Kunci Kira. The data stays; once the new PIN
 is set, Kira opens and the root closes this cover.
 */
import APIClient
import Features
import SwiftUI

struct PinRecoveryFlow: View {
    @Bindable var model: PinRecoveryModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        /** One container, so the task runs once and not again when the step changes. */
        ZStack {
            switch model.phase {
            case .sending, .enteringCode, .verifying: codeStep
            case .choosingPin, .finished: RecoveryNewPinView(model: model)
            }
        }
        .task { await model.start() }
        .problemDialog(model.problem)
    }

    private var codeStep: some View {
        ScrollView {
            VStack(spacing: KiraSpacing.space4) {
                KiraNavBar("lock.recovery.code.title", leading: .back("lock.recovery.back") { dismiss() })
                codeHeader
                codeEntry
                KiraNotice(.safe, message: "lock.recovery.code.notice")
                KiraButton("lock.recovery.code.verify") { Task { await model.verifyCode() } }
                    .block()
                    .disabled(model.code.count < 6 || model.phase != .enteringCode)
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.bottom, KiraSpacing.space2)
        }
        .background { RecoveryBackground() }
        .kiraScrollEdges()
    }

    private var codeHeader: some View {
        VStack(spacing: 18) {
            KiraIllustration(.letter, size: 136)
            VStack(spacing: KiraSpacing.space2) {
                Text("lock.recovery.code.heading")
                    .font(KiraFont.display(30, .heavy, relativeTo: .largeTitle))
                    .tracking(-0.025 * 30)
                    .kiraLineHeight(36, size: 30, natural: 1.26, relativeTo: .largeTitle)
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("lock.recovery.code.sent \(Text(model.email).fontWeight(.semibold).foregroundStyle(.ink))")
                    .font(.body)
                    .kiraLineHeight(24, size: 17)
                    .foregroundStyle(.inkMuted)
                    .frame(maxWidth: 300)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.top, KiraSpacing.space6)
    }

    private var codeEntry: some View {
        VStack(spacing: 14) {
            KiraCodeField("lock.recovery.code.field", code: $model.code, kind: .code)
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let left = model.secondsUntilResend(at: context.date)
                if left > 0 {
                    let wait = Text(Duration.seconds(left), format: .time(pattern: .minuteSecond))
                    Text("lock.recovery.code.resend.wait \(wait)")
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(.inkMuted)
                } else if model.phase != .sending {
                    KiraLink("lock.recovery.code.resend") { Task { await model.sendCode() } }
                }
            }
        }
    }
}

/** The leaf in the top corner and the hills at the bottom, on the surface. */
struct RecoveryBackground: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.surface
            KiraLeaf(.twig, tone: .soft, size: 140, isFlipped: true).offset(x: 40, y: 44)
            KiraScenery(height: 150).frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
    }
}
