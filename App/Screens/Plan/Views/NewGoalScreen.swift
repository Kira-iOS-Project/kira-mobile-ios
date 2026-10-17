/**
 Tujuan Baru (REN-02, board TujuanBaru): "Apa Mimpimu?" with its hand note, the goal kinds as a
 two-column choice (Jenis tujuan), the note that the deposit becomes a budget line, and Lanjut to the
 chosen kind's form. Only the kinds whose form is built are offered (`GoalFormRoute.built`).
 */
import Domain
import Features
import SwiftUI

struct NewGoalScreen: View {
    let onOpen: (AppRoute) -> Void
    @State private var chosen: GoalKind = GoalFormRoute.built.first ?? .other
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { screen in
            ScrollView {
                VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                    KiraNavBar("plan.goal.form.title", leading: .close("plan.newGoal.close") { dismiss() }) {
                        EmptyView()
                    }
                    HStack(alignment: .center, spacing: KiraSpacing.space3) {
                        Text("plan.newGoal.title")
                            .font(KiraFont.display(28, .heavy, relativeTo: .title))
                            .kiraLineHeight(34, size: 28, natural: 1.26, relativeTo: .title)
                            .tracking(-0.7)
                            .foregroundStyle(.ink)
                            .accessibilityAddTraits(.isHeader)
                        Spacer(minLength: 0)
                        KiraHandNote("plan.newGoal.note", size: .small, tilt: -2)
                    }
                    .padding(.horizontal, KiraSpacing.space1)
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 8
                    ) {
                        ForEach(GoalFormRoute.built, id: \.self) { kind in
                            GoalKindCard(kind: kind, isSelected: chosen == kind) { chosen = kind }
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(Text("plan.newGoal.kinds"))
                    Spacer(minLength: 0)
                    VStack(spacing: KiraSpacing.space3) {
                        KiraNotice(.info, message: "plan.newGoal.budgetNote")
                        KiraButton("plan.newGoal.next") { onOpen(.goalForm(chosen)) }.block()
                    }
                }
                .padding(.horizontal, KiraSpacing.screen)
                .padding(.vertical, KiraSpacing.space2)
                .frame(maxWidth: .infinity, minHeight: screen.size.height, alignment: .top)
            }
        }
        .background(alignment: .topTrailing) {
            KiraLeaf(.twig, tone: .soft, size: 124, isFlipped: true).offset(x: 36, y: 14).accessibilityHidden(true)
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }
}

/** One kind: its category icon, name and line; pandan with a check when chosen. */
private struct GoalKindCard: View {
    let kind: GoalKind
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                KiraCategoryIcon(kind.category).accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 1) {
                    Text(kind.title).font(.callout.weight(isSelected ? .bold : .semibold)).kiraLineHeight(21, size: 16)
                        .foregroundStyle(isSelected ? .pandan : .ink)
                    Text(kind.subtitle).font(.footnote).kiraLineHeight(17, size: 13).foregroundStyle(.inkMuted)
                }
            }
            .padding(EdgeInsets(top: 12, leading: 14, bottom: 13, trailing: 14))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.pandanSoft : Color.surfaceRaised)
            .clipShape(RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous)
                    .strokeBorder(isSelected ? Color.pandan : Color.hairline, lineWidth: 1.5)
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    KiraIcon(.check, size: 15, weight: .bold).foregroundStyle(.onPandan)
                        .frame(width: 24, height: 24).background(Circle().fill(.pandan)).padding(12)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
