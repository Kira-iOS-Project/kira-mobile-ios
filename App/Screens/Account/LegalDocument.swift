/**
 The layout of a static document: the nav bar back to Tentang Kira, a 26 pt title and its line,
 the numbered cards, and the actions pinned under them at the bottom of the screen.
 */
import SwiftUI

/** A document with numbered sections. */
struct LegalDocument<Actions: View>: View {
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
    let sections: [LegalSection]
    @ViewBuilder var actions: Actions

    var body: some View {
        AccountPage(title, back: "account.back.about") {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(KiraFont.display(26, .heavy, relativeTo: .title)).kiraLineHeight(
                        31, size: 26, natural: 1.26, relativeTo: .title
                    )
                    .tracking(-0.65)
                    .accessibilityAddTraits(.isHeader)
                Text(subtitle).font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
            }
            .padding(.horizontal, KiraSpacing.space1)
            VStack(spacing: 10) {
                ForEach(sections.indices, id: \.self) { index in
                    LegalCard(number: index + 1, section: sections[index])
                }
            }
            actions.padding(.top, KiraSpacing.space2)
        }
    }
}

extension LegalDocument where Actions == EmptyView {
    init(title: LocalizedStringResource, subtitle: LocalizedStringResource, sections: [LegalSection]) {
        self.init(title: title, subtitle: subtitle, sections: sections) { EmptyView() }
    }
}

/** A card: the pandan number disc, the heading and its sentence. */
private struct LegalCard: View {
    let number: Int
    let section: LegalSection

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number, format: .number)
                .font(KiraFont.display(14, .heavy, relativeTo: .footnote))
                .foregroundStyle(.pandan)
                .frame(width: 30, height: 30)
                .kiraCard(.pandanSoft, border: .pandanLine, cornerRadius: 15)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                Text(section.title)
                    .font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16)
                    .accessibilityAddTraits(.isHeader)
                Text(section.body).font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
            }
            .padding(.top, KiraSpacing.space1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .kiraCard(cornerRadius: KiraRadius.medium)
    }
}
