/**
 One part of Rencana Keselamatanku (board RencanaKeselamatan): its number in a 30 pt pandan circle,
 the title, what the person wrote, and the pencil. Parts 3 and 4 list each contact as "name · number";
 one with a number is a link that calls it (`tel:`), opened only when the person taps it.
 */
import Domain
import Features
import SwiftUI

struct SafetyPlanRow: View {
    let part: SafetyPlanPart
    let plan: SafetyPlan
    let onEdit: () -> Void
    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(part.rawValue, format: .number)
                .font(KiraFont.display(14, .heavy, relativeTo: .footnote))
                .foregroundStyle(.pandan)
                .frame(width: 30, height: 30)
                .background(.pandanSoft, in: Circle())
                .overlay { Circle().strokeBorder(.pandanLine, lineWidth: 1) }
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                Text(part.title)
                    .font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16).foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                content
            }
            .padding(.top, KiraSpacing.space1)
            .frame(maxWidth: .infinity, alignment: .leading)
            KiraIconButton(.pencil, label: part.editLabel, action: onEdit)
        }
        .padding(EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 6))
        .kiraCard(cornerRadius: KiraRadius.medium)
    }

    @ViewBuilder private var content: some View {
        switch part {
        case .warningSigns: written(plan.warningSigns)
        case .calmingThings: written(plan.calmingThings)
        case .safePlace: written(plan.safePlace)
        case .people: contacts(plan.people)
        case .professionals: contacts(plan.professionals)
        }
    }

    @ViewBuilder private func written(_ text: String) -> some View {
        if text.isEmpty {
            Text("care.plan.empty").font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
        } else {
            Text(text).font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.ink)
        }
    }

    @ViewBuilder private func contacts(_ contacts: [SafetyContact]) -> some View {
        if contacts.isEmpty { written("") }
        ForEach(Array(contacts.enumerated()), id: \.offset) { _, contact in
            if let url = contact.callURL {
                Button { openURL(url) } label: {
                    Text(contact.line).underline().foregroundStyle(.pandan).multilineTextAlignment(.leading)
                }
                .font(.subheadline).kiraLineHeight(21, size: 15)
                .accessibilityHint(Text("care.plan.call.hint"))
            } else {
                written(contact.line)
            }
        }
    }
}
