/** The parts of Detail Grup (KOM-02): the group card with its admin, and the about and rules sections. */
import Domain
import SwiftUI

/** The group's card: illustration and tag, name and meta, and the verified admin's row. */
struct GroupHeader: View {
    let group: CommunityGroup

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            HStack(alignment: .top) {
                KiraIllustration(.community, size: 56)
                Spacer(minLength: KiraSpacing.space3)
                KiraTag("community.verified", tone: .pandan, icon: .shield)
            }
            VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                Text(group.summary.name)
                    .font(KiraFont.display(24, .heavy, relativeTo: .title2))
                    .kiraLineHeight(30, size: 24, natural: 1.26, relativeTo: .title2)
                    .tracking(-0.48)
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("community.detail.meta \(group.summary.meta) \(group.summary.members)")
                    .kiraFont(.callout).foregroundStyle(.inkMuted)
            }
            KiraListRow(Text(group.admin.name), leading: .initials(group.admin.initials, .green), trailing: .none)
                .subtitle(Text("community.detail.admin \(group.admin.verifiedSince.monthYear)"))
                .overlay(alignment: .top) { Rectangle().fill(.line).frame(height: 1) }
        }
        .padding(EdgeInsets(top: 18, leading: 20, bottom: 6, trailing: 20))
        .kiraCard(cornerRadius: KiraRadius.large)
    }
}

/** "Tentang Grup" and "Aturan Utama", and when the link was checked. */
struct GroupAbout: View {
    let group: CommunityGroup

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            KiraSectionTitle("community.detail.about")
            Text(group.about).kiraFont(.callout).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
                .padding(.horizontal, KiraSpacing.space1)
        }
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle("community.detail.rules", trailing: .note("community.detail.rulesNote"))
            KiraRowStack {
                ForEach(group.rules, id: \.self) { rule in
                    HStack(spacing: KiraSpacing.space3) {
                        KiraIcon(.check, size: 15, weight: .bold)
                            .foregroundStyle(.pandan)
                            .frame(width: 26, height: 26)
                            .kiraCard(.pandanSoft, border: .pandanLine, cornerRadius: 13)
                            .accessibilityHidden(true)
                        Text(rule).font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16).foregroundStyle(.ink)
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .kiraRowSeparator()
                }
            }
            .padding(.horizontal, KiraSpacing.space4)
            .padding(.vertical, KiraSpacing.space1)
            .kiraCard(cornerRadius: KiraRadius.large)
            HStack(spacing: 6) {
                KiraIcon(.shield, size: 16, weight: .semibold).foregroundStyle(.pandan)
                Text(checked).kiraFont(.footnote).foregroundStyle(.inkMuted)
            }
            .padding(.horizontal, KiraSpacing.space1)
        }
    }

    /** "Link dicek 12 Oktober 2026 · admin masih sama". */
    private var checked: LocalizedStringResource {
        let day = group.linkCheckedOn.date.formatted(.kiraDate)
        return group.adminUnchanged
            ? "community.detail.checkedSameAdmin \(day)" : "community.detail.checked \(day)"
    }
}
