/**
 BRD-02, Beranda before the first transaction: Kuku invites the first entry by chat, and "Langkah
 Awal" ticks what the account has done. Wallets do not exist yet, so "Tambah Dompet" is not listed.
 */
import Domain
import Features
import SwiftUI

struct HomeFirstSteps: View {
    let home: HomeOverview
    let onOpen: (AppRoute) -> Void

    var body: some View {
        invitation
        if let checklist = home.checklist {
            VStack(alignment: .leading, spacing: 10) {
                KiraSectionTitle("home.firstSteps.title")
                KiraListGroup(footer: "home.firstSteps.footer \(checklist.doneCount) \(checklist.total)") {
                    rows(checklist)
                }
                .accessibilityLabel(Text("home.firstSteps.listLabel"))
            }
            .padding(.top, 6)
        }
    }

    private var invitation: some View {
        VStack(spacing: 6) {
            KiraMascot(.calm, size: 132)
            KiraHandNote("home.firstSteps.note", tilt: -2)
            Text("home.firstSteps.heading")
                .font(KiraFont.display(24, .heavy, relativeTo: .title))
                .kiraLineHeight(30, size: 24, natural: 1.26, relativeTo: .title)
                .tracking(-0.48)
                .foregroundStyle(.ink)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 10)
            Text("home.firstSteps.body")
                .font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
                .frame(maxWidth: 290)
            KiraButton("home.firstSteps.record") { onOpen(.record) }.icon(.chat).block()
                .padding(.top, KiraSpacing.space3)
            Text("home.firstSteps.example").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
        }
        .multilineTextAlignment(.center)
        .padding(EdgeInsets(top: KiraSpacing.space6, leading: 20, bottom: 20, trailing: 20))
        .frame(maxWidth: .infinity)
        .background(alignment: .topLeading) {
            KiraLeaf(.pandan, tone: .soft, size: 120).offset(x: -30, y: -18).accessibilityHidden(true)
        }
        .clipShape(RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
        .kiraCard(cornerRadius: KiraRadius.extraLarge)
    }

    @ViewBuilder private func rows(_ checklist: FirstStepsChecklist) -> some View {
        let scoreLine: Text =
            home.score.map { Text("home.firstSteps.checkDone \($0.score) \(Text($0.band.title))") }
            ?? Text("home.firstSteps.checkTodo")
        KiraListRow(
            Text("home.firstSteps.check"), leading: .icon(.chart), trailing: .check(checklist.healthCheck),
            action: { onOpen(checklist.healthCheck ? .score : .healthCheck) }
        )
        .subtitle(scoreLine)
        KiraListRow(
            Text("home.firstSteps.record"), leading: .icon(.chat), trailing: .check(checklist.firstTransaction),
            action: { onOpen(.record) }
        )
        .subtitle(Text("home.firstSteps.recordHint"))
        KiraListRow(
            Text("home.firstSteps.payday"), leading: .icon(.calendar), trailing: .check(checklist.paydaySet),
            action: { onOpen(.unavailable(.editBudget)) }
        )
        .subtitle(Text("home.firstSteps.paydayHint"))
    }
}
