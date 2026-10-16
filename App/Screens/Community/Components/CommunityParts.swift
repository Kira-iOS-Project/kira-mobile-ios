/** The parts of Komunitas (KOM-01): the intro card, the chips, the groups and the rules line. */
import Domain
import Features
import SwiftUI

/** "Teman seperjalanan" and the sentence beside the community illustration. */
struct CommunityIntro: View {
    var body: some View {
        HStack(spacing: KiraSpacing.space3) {
            VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                Text("community.intro.overline").kiraFont(.overline).foregroundStyle(.pandan)
                Text("community.intro.text")
                    .font(KiraFont.display(19, .bold, relativeTo: .title3))
                    .kiraLineHeight(25, size: 19, natural: 1.26, relativeTo: .title3)
                    .tracking(-0.19)
                    .foregroundStyle(.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            KiraIllustration(.community, size: 96)
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 16))
        .kiraCard(cornerRadius: KiraRadius.large)
    }
}

/** "Semua" and one chip per category. */
struct CommunityChips: View {
    let model: CommunityModel

    var body: some View {
        KiraFlowRow {
            KiraChip("community.category.all", isSelected: model.category == nil) { model.select(nil) }
            ForEach(model.categories, id: \.self) { category in
                KiraChip(category.title, isSelected: model.category == category) { model.select(category) }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("community.categories"))
    }
}

/** "Grup Pilihan" and its cards, or a calm line when no group is listed. */
struct CommunityGroups: View {
    let groups: [CommunityGroupSummary]
    let isEmpty: Bool
    let onOpen: (CommunityGroupSummary) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle("community.groups.title", trailing: .note("community.groups.note"))
            if groups.isEmpty {
                Text(isEmpty ? "community.groups.none" : "community.groups.noneInCategory")
                    .kiraFont(.callout).foregroundStyle(.inkMuted)
                    .padding(.horizontal, KiraSpacing.space1)
            }
            ForEach(groups) { group in
                CommunityGroupCard(group: group) { onOpen(group) }
            }
        }
        .padding(.top, KiraSpacing.space1)
    }
}

/** One group: its tile and the Terverifikasi tag, name, category and platform, line and members. */
struct CommunityGroupCard: View {
    let group: CommunityGroupSummary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                HStack(alignment: .top) {
                    KiraCategoryIcon(group.icon.category)
                    Spacer(minLength: KiraSpacing.space3)
                    KiraTag("community.verified", tone: .pandan, icon: .shield)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(group.name).kiraFont(.headline).foregroundStyle(.ink)
                    group.meta.font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                    Text(group.summary).kiraFont(.callout).foregroundStyle(.inkMuted).padding(.top, 3)
                }
                HStack(spacing: 6) {
                    KiraIcon(.users, size: 16, weight: .semibold).foregroundStyle(.pandan)
                    Text("community.group.members \(group.members)")
                        .font(.footnote.weight(.semibold).monospacedDigit()).kiraLineHeight(18, size: 13)
                        .foregroundStyle(.ink)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 18, trailing: 16))
            .kiraCard(cornerRadius: KiraRadius.large)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            Text("community.group.label \(group.name) \(group.meta) \(group.members)")
        )
        .accessibilityAddTraits(.isButton)
    }
}

/** "Aturan komunitas berlaku di semua grup. Baca Aturan". */
struct CommunityRulesLine: View {
    let onRead: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("community.rulesLine").kiraFont(.footnote).foregroundStyle(.inkMuted)
            KiraLink("community.readRules", action: onRead)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}
