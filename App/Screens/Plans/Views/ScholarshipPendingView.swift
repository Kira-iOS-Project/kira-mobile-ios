/**
 Status Beasiswa · Ditinjau (AKN-10c; board BeasiswaKiraStatus): the application in review (or on
 the waiting list), its three steps and summary, Mode Darurat Utang in the meantime, and Tarik
 Pengajuan.
 */
import Domain
import Features
import SwiftUI

struct ScholarshipPendingView: View {
    let application: ScholarshipApplication
    let model: ScholarshipModel
    let onOpen: (AppRoute) -> Void

    var body: some View {
        status
        ScholarshipSteps(steps: [
            .init(
                number: 1, title: "scholarship.step.sent",
                detail: application.sentAtText,
                state: .done),
            .init(
                number: 2, title: "scholarship.step.review", detail: Text("scholarship.step.review.pending"),
                state: .current),
            .init(
                number: 3, title: "scholarship.step.active", detail: Text("scholarship.step.active.pending"),
                state: .upcoming),
        ])
        KiraListGroup("scholarship.summary.title") {
            KiraListRow(Text("scholarship.summary.facing"), leading: .icon(.list)).subtitle(situations)
            KiraListRow(Text("scholarship.summary.length"), leading: .icon(.calendar))
                .subtitle(Text("scholarship.summary.length.detail"))
        }
        .accessibilityLabel(Text("scholarship.summary.group"))
        meanwhile
        Spacer(minLength: 0)
        VStack(spacing: KiraSpacing.space3) {
            KiraNotice(.info, title: "plans.prototype", message: "scholarship.prototype")
            if let problem = model.withdrawProblem { PlansProblemNotice(problem: problem) }
            VStack(spacing: 10) {
                KiraButton("scholarship.openEmergency") { onOpen(.debtEmergency) }.block()
                KiraButton("scholarship.withdraw", variant: .secondary) { Task { await model.withdraw() } }.block()
                    .disabled(model.isWithdrawing)
            }
        }
        .padding(.top, KiraSpacing.space2)
    }

    private var status: some View {
        VStack(alignment: .leading, spacing: 10) {
            if application.status == .waitlisted {
                KiraTag("scholarship.status.waitlisted", tone: .turmeric, icon: .clock)
            } else {
                KiraTag("scholarship.status.inReview", tone: .turmeric, icon: .clock)
            }
            PlansDisplayTitle("scholarship.status.headline", size: 22)
            Text("scholarship.status.decideBy \(application.decideBy.date, format: .plansFullDay)")
                .font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
    }

    /** "Cicilan Menumpuk · Ditagih Pinjol". */
    private var situations: Text {
        var text: Text?
        for situation in application.situations {
            let name = Text(situation.title)
            text = text.map { Text("scholarship.summary.join \($0) \(name)") } ?? name
        }
        return text ?? Text("scholarship.summary.none")
    }

    private var meanwhile: some View {
        HStack(spacing: 14) {
            KiraMascot(.calm, size: 72)
            VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                Text("scholarship.meanwhile").font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.ink)
                KiraHandNote("scholarship.meanwhile.note", size: .small, tilt: -2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 16))
        .kiraCard(.pandanSoft, border: .pandanLine)
    }
}

extension ScholarshipSituation {
    /** The chip's words: "Cicilan Menumpuk", "Ditagih Pinjol", … */
    var title: LocalizedStringResource {
        switch self {
        case .instalmentsPilingUp: "scholarship.situation.instalments"
        case .chasedByLender: "scholarship.situation.lender"
        case .incomeStopped: "scholarship.situation.income"
        case .medicalCosts: "scholarship.situation.medical"
        case .otherHardship: "scholarship.situation.other"
        }
    }
}
