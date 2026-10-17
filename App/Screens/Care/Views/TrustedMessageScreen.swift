/**
 PED-04, Kirim Pesan ke Layanan Kira (board PesanTerpercaya): the opening message, filled in and
 editable, sent only when the person taps WhatsApp or SMS, or a call. Each opens the other app with
 the message typed in; Kira itself never sends or calls.
 */
import Features
import SwiftUI

struct TrustedMessageScreen: View {
    @State private var model: TrustedMessageModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    init(service: any CareService) {
        _model = State(
            initialValue: TrustedMessageModel(
                service: service, message: String(localized: "care.trusted.message.default")))
    }

    var body: some View {
        CareScreenFrame {
            KiraNavBar("care.trusted.title", leading: .close("care.trusted.close") { dismiss() })
            recipient
            KiraField("care.trusted.message", text: $model.message)
                .multiline(3)
                .hint("care.trusted.message.hint")
            KiraNotice(.privacy, message: "care.trusted.notice")
            Spacer(minLength: 0)
            actions
        }
        .task { await model.load() }
    }

    /** "Untuk" over Layanan Kira Peduli, with the care illustration as its avatar. */
    private var recipient: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            Text("care.trusted.to")
                .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                .padding(.horizontal, KiraSpacing.space1)
            HStack(spacing: KiraSpacing.space3) {
                KiraIllustration(.care, size: 50)
                    .frame(width: 64, height: 64)
                    .background(.surfaceRaised)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(.pandanLine, lineWidth: 1))
                VStack(alignment: .leading, spacing: 2) {
                    Text("care.trusted.recipient").font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16)
                        .foregroundStyle(.ink)
                    Text("care.trusted.recipient.detail")
                        .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .kiraCard(cornerRadius: KiraRadius.large)
            .accessibilityElement(children: .combine)
        }
    }

    private var actions: some View {
        VStack(spacing: KiraSpacing.space2) {
            KiraButton("care.trusted.whatsApp") { open(model.whatsAppURL) }.icon(.chat).block()
                .disabled(model.whatsAppURL == nil)
            KiraButton("care.trusted.sms", variant: .secondary) { open(model.smsURL) }.icon(.send).block()
                .disabled(model.smsURL == nil)
            KiraButton("care.trusted.call", variant: .secondary) { open(model.callURL) }.icon(.phone).block()
                .disabled(model.callURL == nil)
                .accessibilityLabel(Text("care.trusted.call.label"))
        }
    }

    private func open(_ url: URL?) {
        if let url { openURL(url) }
    }
}

#Preview {
    NavigationStack { TrustedMessageScreen(service: PreviewCareService()) }
}
