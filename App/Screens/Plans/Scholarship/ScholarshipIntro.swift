/** Beasiswa Kira explained (AKN-09; board BeasiswaKira), with this month's quota and the waiting list. */
import Domain
import SwiftUI

struct ScholarshipIntro: View {
    let overview: ScholarshipOverview
    let onLater: () -> Void
    let onApply: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        header
        KiraSectionTitle("scholarship.gets.title").padding(.top, KiraSpacing.space2)
        KiraListGroup {
            KiraListRow(Text("scholarship.gets.plus"), leading: .icon(.star)).subtitle(
                Text("scholarship.gets.plus.detail"))
            KiraListRow(Text("scholarship.gets.months"), leading: .icon(.calendar))
                .subtitle(Text("scholarship.gets.months.detail"))
            KiraListRow(Text("scholarship.gets.free"), leading: .icon(.shield)).subtitle(
                Text("scholarship.gets.free.detail"))
        }
        KiraSectionTitle("scholarship.who.title").padding(.top, KiraSpacing.space2)
        KiraListGroup(footer: "scholarship.who.footer") {
            KiraListRow(Text("scholarship.who.mode"), leading: .icon(.check)).subtitle(
                Text("scholarship.who.mode.detail"))
            KiraListRow(Text("scholarship.who.unpaid"), leading: .icon(.check))
                .subtitle(Text("scholarship.who.unpaid.detail"))
        }
        KiraSectionTitle("scholarship.how.title").padding(.top, KiraSpacing.space2)
        ScholarshipSteps(steps: [
            .init(number: 1, title: "scholarship.step.apply", detail: Text("scholarship.how.apply"), state: .upcoming),
            .init(
                number: 2, title: "scholarship.step.review", detail: Text("scholarship.how.review"), state: .upcoming),
            .init(
                number: 3, title: "scholarship.step.active", detail: Text("scholarship.how.active"), state: .upcoming),
        ])
        quota
        KiraNotice(.education, title: "scholarship.privacy.title", message: "scholarship.privacy.body")
        Spacer(minLength: 0)
        PlansButtonRow(
            secondary: KiraButton("plans.later", variant: .secondary, action: onLater),
            primary: KiraButton("scholarship.apply", action: onApply)
        )
        .padding(.top, KiraSpacing.space2)
    }

    /** The words beside the art, under it at the accessibility text sizes. */
    private var headerLayout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: KiraSpacing.space3))
            : AnyLayout(HStackLayout(spacing: KiraSpacing.space3))
    }

    private var header: some View {
        headerLayout {
            if typeSize.isAccessibilitySize { KiraIllustration(.care, size: 96) }
            VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                KiraTag("scholarship.tag", tone: .pandan, icon: .gift).keepsOfferedWidth()
                PlansDisplayTitle("scholarship.headline", size: 28).balancedLines()
                Text("scholarship.lede").font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if !typeSize.isAccessibilitySize { KiraIllustration(.care, size: 96) }
        }
        .padding(EdgeInsets(top: 4, leading: 4, bottom: 0, trailing: 4))
    }

    private var quota: some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraProgressRibbon(
                value: Double(overview.quotaRemaining), target: Double(overview.quotaTotal),
                label: "scholarship.quota",
                valueLabel: "scholarship.quota.value \(overview.quotaRemaining) \(overview.quotaTotal)")
            Text("scholarship.quota.note").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
        }
        .padding(KiraSpacing.space4)
        .kiraCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("scholarship.quota.group"))
    }
}
