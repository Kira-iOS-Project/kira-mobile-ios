/**
 Status Beasiswa · Diterima (AKN-10d; board BeasiswaKiraDiterima): Kira Plus free until the grant's
 end, the three steps done, when to ask for three more months, and the treaters' note.
 */
import Domain
import SwiftUI

struct ScholarshipAcceptedView: View {
    let application: ScholarshipApplication
    let onStart: () -> Void

    var body: some View {
        hero
        ScholarshipSteps(steps: [
            .init(
                number: 1, title: "scholarship.step.sent",
                detail: application.sentAtText,
                state: .done),
            .init(number: 2, title: "scholarship.step.review", detail: decided, state: .done),
            .init(number: 3, title: "scholarship.step.active", detail: grantRange, state: .done),
        ])
        KiraListGroup("scholarship.next.title") {
            KiraListRow(Text("scholarship.next.extend"), leading: .icon(.calendar)).subtitle(extensionText)
            KiraListRow(Text("scholarship.next.after"), leading: .icon(.shield))
                .subtitle(Text("scholarship.next.after.detail"))
        }
        KiraNotice(.education, title: "scholarship.thanks.title", message: "scholarship.thanks.body")
        KiraNotice(.info, title: "plans.prototype", message: "scholarship.prototype")
            .padding(.top, KiraSpacing.space2)
        KiraButton("scholarship.start", action: onStart).block()
    }

    private var hero: some View {
        VStack(spacing: KiraSpacing.space2) {
            KiraMascot(.happy, size: 104)
            Text("scholarship.accepted.overline").kiraFont(.overline).foregroundStyle(.onHeroMuted)
            PlansDisplayTitle("scholarship.accepted.headline", size: 26, color: .onHero)
            endText.font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.onHeroMuted)
        }
        .multilineTextAlignment(.center)
        .padding(EdgeInsets(top: 24, leading: 20, bottom: 26, trailing: 20))
        .frame(maxWidth: .infinity)
        .background(alignment: .bottom) { KiraScenery(tone: .hero, height: 92).accessibilityHidden(true) }
        .background(.hero)
        .clipShape(RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
    }

    private var endText: Text {
        guard let grant = application.grant else { return Text("scholarship.accepted.headline") }
        return Text("scholarship.accepted.until \(grant.upperBound.date, format: .plansFullDay)")
    }

    private var decided: Text {
        guard let day = application.decidedAt else { return Text("scholarship.step.review.pending") }
        return Text("scholarship.step.review.accepted \(day.date, format: .plansFullDay)")
    }

    private var grantRange: Text {
        guard let grant = application.grant else { return Text("scholarship.step.active.pending") }
        let start = grant.lowerBound.date
        let end = grant.upperBound.date
        return Text("scholarship.step.active.range \(start, format: .plansFullDay) \(end, format: .plansFullDay)")
    }

    private var extensionText: Text {
        guard let day = application.extensionFrom else { return Text("scholarship.next.extend.later") }
        return Text("scholarship.next.extend.detail \(day.date, format: .plansFullDay)")
    }
}
