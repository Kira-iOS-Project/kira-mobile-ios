/**
 PED-01, Kira Peduli (board KiraPeduli): the door every "Butuh Bantuan Sekarang" opens. Healing119,
 Layanan Kira, Telepon 119 for danger now, Mode Darurat Utang and the two tools for later, free on
 every plan, with no help button, no handwriting and Kuku only on the Layanan Kira card. The
 contacts show at once from the shipped list, then the verified one.
 */
import Domain
import Features
import SwiftUI

struct CareScreen: View {
    private let onOpen: (AppRoute) -> Void
    @State private var model: CareContactsModel
    @Environment(\.dismiss) private var dismiss

    init(service: any CareService, onOpen: @escaping (AppRoute) -> Void) {
        self.onOpen = onOpen
        _model = State(initialValue: CareContactsModel(service: service))
    }

    var body: some View {
        CareScreenFrame(twigSize: 150, showsPandan: true) {
            KiraNavBar("care.title", leading: .close("care.close") { dismiss() })
            CareHero()
            VStack(alignment: .leading, spacing: 10) {
                KiraSectionTitle("care.talk.title")
                KiraListGroup { CareHealingRows(contact: model.contact(.healing119)) }
                CareKiraCard(contact: model.contact(.kiraCare), detail: "care.kira.detail") { onOpen(.trustedMessage) }
            }
            danger
            section("care.debt.title") {
                KiraListRow(Text("care.debt.emergency"), leading: .icon(.shield)) { onOpen(.debtEmergency) }
                    .subtitle(Text("care.debt.emergency.detail"))
            }
            section("care.later.title") {
                KiraListRow(Text("care.later.safetyPlan"), leading: .icon(.list)) { onOpen(.safetyPlan) }
                    .subtitle(Text("care.later.safetyPlan.detail"))
                KiraListRow(Text("care.later.breathing"), leading: .icon(.wind)) { onOpen(.breathingExercise) }
                    .subtitle(Text("care.later.breathing.detail"))
            }
            KiraNotice(.info, message: "care.notice \(model.contacts.verifiedOn.date.formatted(.kiraDate))")
        }
        .task { await model.load() }
    }

    /** "Ada Bahaya untuk Dirimu Sekarang?": a raised card with Telepon 119 and where PSC 119 is. */
    private var danger: some View {
        VStack(spacing: KiraSpacing.space3) {
            Text("care.emergency.title")
                .font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
            CareEmergencyButton(contact: model.contact(.psc119))
            if let psc = model.contact(.psc119) {
                Text("care.emergency.detail \(psc.name)")
                    .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(EdgeInsets(top: 18, leading: 16, bottom: 16, trailing: 16))
        .kiraCard(.surfaceRaised, cornerRadius: KiraRadius.large)
    }

    private func section<Rows: View>(
        _ title: LocalizedStringResource, @ViewBuilder rows: () -> Rows
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle(title)
            KiraListGroup(rows: rows)
        }
        .padding(.top, KiraSpacing.space1)
    }
}

/** The illustration, "Kamu Tidak Sendirian" and its line, centred. */
private struct CareHero: View {
    var body: some View {
        VStack(spacing: 10) {
            KiraIllustration(.care, size: 96)
            Text("care.headline")
                .font(KiraFont.display(28, .heavy, relativeTo: .title))
                .kiraLineHeight(34, size: 28, natural: 1.26, relativeTo: .title)
                .tracking(-0.56)
                .foregroundStyle(.ink)
                .padding(.top, KiraSpacing.space1)
                .accessibilityAddTraits(.isHeader)
            Text("care.intro")
                .font(.body).kiraLineHeight(24, size: 17).foregroundStyle(.inkMuted)
                .frame(maxWidth: 320)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 4, leading: 12, bottom: 8, trailing: 12))
    }
}

#Preview {
    NavigationStack { CareScreen(service: PreviewCareService(), onOpen: { _ in }) }
}
