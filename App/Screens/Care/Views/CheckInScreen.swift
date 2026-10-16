/**
 PED-05, Check-in Lanjutan (board CheckIn): after a heavy moment Kira asks to greet again in the
 Catat chat, Besok chosen first, or the delay of the check-in already scheduled. The close button
 and Tidak Perlu go back to the chat with nothing scheduled, cancelling that check-in; Ya, Sapa
 Aku schedules the greeting. A failed request closes this screen and the chat shows the failure
 dialog, whose Coba Lagi brings it back with the same choice.
 */
import Domain
import Features
import SwiftUI

struct CheckInScreen: View {
    @Bindable var model: CheckInModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                KiraIconButton(.close, label: "care.checkIn.close", variant: .outline) {
                    Task { await model.decline() }
                }
                Spacer()
            }
            .frame(minHeight: KiraSize.tap)
            .padding(.horizontal, KiraSpacing.screen)
            ScrollView {
                VStack(spacing: KiraSpacing.space5) {
                    CheckInHeading()
                    delays
                    CheckInSample()
                    KiraNotice(.privacy, message: "care.checkIn.notice")
                }
                .padding(.horizontal, KiraSpacing.screen)
                .padding(.bottom, KiraSpacing.space5)
            }
            .kiraScrollEdges()
            KiraButtonPair(
                secondary: KiraButton("care.checkIn.decline", variant: .secondary) { Task { await model.decline() } },
                primary: KiraButton("care.checkIn.accept") { Task { await model.schedule() } }
            )
            .disabled(model.isSaving)
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.bottom, KiraSpacing.space2)
        }
        .background(alignment: .topTrailing) {
            KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true)
                .offset(x: 38, y: -28)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .background(.surface)
    }

    private var delays: some View {
        KiraListGroup {
            ForEach(CheckInDelay.allCases, id: \.self) { delay in
                KiraListRow(Text(delay.title), trailing: .check(model.delay == delay), action: { model.delay = delay })
                    .subtitle(Text(delay.subtitle))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("care.checkIn.when"))
    }
}

/** The illustration, "Boleh Aku Menyapamu Lagi?" and where the greeting appears. */
private struct CheckInHeading: View {
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(spacing: KiraSpacing.space2) {
            KiraIllustration(.care, size: 80).accessibilityHidden(true)
            Text("care.checkIn.title")
                .font(KiraFont.display(26, axisWeight: 800, relativeTo: .title, typeSize: typeSize))
                .kiraLineHeight(32, size: 26, relativeTo: .title)
                .tracking(-0.52)
                .padding(.top, KiraSpacing.space1)
                .accessibilityAddTraits(.isHeader)
            Text("care.checkIn.body")
                .font(.body).kiraLineHeight(23, size: 17)
                .foregroundStyle(.inkMuted)
                .frame(maxWidth: 310)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

/** "Begini sapaannya di chat" and the greeting as it will appear. */
private struct CheckInSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            Text("care.checkIn.sampleLabel")
                .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted)
                .padding(.horizontal, KiraSpacing.space1)
            KiraChatBubble(.kira, meta: "care.meta.checkIn") { Text("care.checkIn.sample") }
                .hidesAvatar()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(KiraSpacing.space3)
                .kiraCard(.surfaceMuted, cornerRadius: 22)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("care.checkIn.sampleGroup"))
    }
}
