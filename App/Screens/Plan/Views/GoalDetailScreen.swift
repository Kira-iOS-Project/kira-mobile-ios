/**
 Detail Tujuan (REN-05): the goal's icon, name, target and date; Terkumpul with the milestones; the
 card for the milestone last reached, with Kuku; Setoran Berikutnya; Riwayat Setoran, newest first;
 and "Ubah Tujuan" (the calculator on the goal's values) beside "Tambah Setoran", whose sheet saves a
 deposit and closes into "Setoran Tersimpan", or into the failure dialog when the save fails.
 */
import Domain
import Features
import SwiftUI

struct GoalDetailScreen: View {
    @State private var model: GoalDetailModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(id: String, service: any GoalService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: GoalDetailModel(id: id, service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("plan.detail.title", leading: .back("plan.detail.back") { dismiss() }) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, 62 - 59)
            .padding(.bottom, KiraSpacing.space8)
            /**
             The twig in the scrolled content's background, as PlanScreenFrame draws it: on the scroll
             view's own background VoiceOver still found it ("Element has no description").
             */
            .background(alignment: .top) {
                KiraLeaf(.twig, tone: .soft, size: 136, isFlipped: true)
                    .frame(maxWidth: .infinity, alignment: .trailing).offset(x: 40, y: 24 - 59)
                    .accessibilityHidden(true)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
        .kiraSheet(
            $model.deposit, title: "plan.deposit.title", subtitle: depositSubtitle, failureTitle: "plan.deposit.failed",
            onRetry: { Task { await model.submitDeposit() } }, content: { GoalDepositSheet(model: model) }
        )
        .kiraDialog(isPresented: $model.showsDepositSaved) {
            KiraDialog(
                "plan.deposit.saved.title", message: "plan.deposit.saved.body \(model.phase.value?.summary.name ?? "")",
                art: .illustration(.bloom), primary: KiraButton("plan.deposit.saved.done") {})
        }
    }

    /** "Ke tujuan Dana Darurat". */
    private var depositSubtitle: LocalizedStringResource? {
        model.phase.value.map { "plan.deposit.subtitle \($0.summary.name)" }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            ProgressView().frame(maxWidth: .infinity, minHeight: 200)
                .accessibilityLabel(Text("plan.loading"))
        case .empty:
            GoalGone { dismiss() }
        case .failed(let problem):
            LoadFailedView(title: "plan.detail.failed", problem: problem) { Task { await model.load() } }
        case .loaded(let goal):
            GoalDetailContent(goal: goal, model: model, onOpen: onOpen)
        }
    }
}

/** The loaded goal, top to bottom as the board lays it. */
private struct GoalDetailContent: View {
    let goal: GoalDetail
    let model: GoalDetailModel
    let onOpen: (AppRoute) -> Void

    var body: some View {
        HStack(spacing: 14) {
            KiraCategoryIcon(goal.summary.kind.category, size: 56)
            VStack(alignment: .leading, spacing: 2) {
                Text(goal.summary.name).font(KiraFont.display(26, .heavy, relativeTo: .title))
                    .kiraLineHeight(32, size: 26, relativeTo: .title).tracking(-0.65).foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                Text(target)
                    .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted).monospacedDigit()
            }
        }
        .padding([.horizontal, .top], KiraSpacing.space1)
        GoalProgressCard(
            goal: goal, progress: model.progress, next: model.nextMilestone, targetMultiple: model.targetMultiple)
        if let reached = model.latestReached {
            GoalMilestoneCard(milestone: reached, progress: model.progress)
        }
        if let next = model.nextDeposit {
            KiraListGroup("plan.detail.nextDeposit.label") {
                KiraListRow(Text("plan.detail.nextDeposit"), leading: .icon(.calendar), trailing: .none) {
                    KiraTag("plan.detail.nextDeposit.every \(next.dayOfMonth)", tone: .pandan, icon: .calendar)
                }
                .subtitle(Text(next.day.date, format: .kiraDate))
                .amount(KiraAmount(Decimal(goal.summary.monthlyDeposit), size: .small))
            }
        }
        GoalDepositHistory(deposits: goal.deposits)
        WeightedRow(weights: [1, 1.3], spacing: 10) {
            KiraButton("plan.detail.edit", variant: .secondary) { onOpen(.editGoal(id: goal.id)) }.block()
            KiraButton("plan.detail.addDeposit") { model.openDeposit() }.block()
        }
        .padding(.top, KiraSpacing.space1)
    }
}

extension GoalDetailContent {
    /** "Target Rp25.200.000,00 · April 2029". */
    fileprivate var target: LocalizedStringResource {
        let amount = goal.summary.targetAmount.rupiah
        return "plan.detail.target \(amount, format: .rupiah) \(goal.summary.targetDate.date, format: .kiraMonthYear)"
    }
}

/** Riwayat Setoran: each deposit by its month, newest first. */
private struct GoalDepositHistory: View {
    let deposits: [GoalDeposit]

    var body: some View {
        if !deposits.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                KiraSectionTitle("plan.detail.history")
                KiraListGroup("plan.detail.history.label") {
                    ForEach(deposits, id: \.id) { deposit in
                        KiraListRow(
                            Text("plan.detail.history.row \(deposit.depositedOn.date, format: .kiraMonth)"),
                            leading: .category(.savings), trailing: .none
                        )
                        .subtitle(Text(deposit.depositedOn.date, format: .kiraDate))
                        .amount(KiraAmount(Decimal(deposit.amount), size: .small))
                    }
                }
            }
            .padding(.top, 6)
        }
    }
}

/** GOAL_NOT_FOUND: the goal is gone; no Coba Lagi, the way back instead. */
private struct GoalGone: View {
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraIllustration(.care, size: 112)
            Text("problem.GOAL_NOT_FOUND").kiraFont(.callout).foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            KiraButton("plan.detail.back") { onBack() }.block()
        }
        .padding(KiraSpacing.screen)
        .frame(maxWidth: .infinity)
    }
}

/** Tambah Setoran's sheet: one rupiah field, prefilled with the monthly deposit, and Simpan. */
private struct GoalDepositSheet: View {
    @Bindable var model: GoalDetailModel

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraField("plan.deposit.amount", text: $model.depositAmount)
                .prefix("plan.deposit.currency").suffix("plan.deposit.cents").amount()
                .error(model.isDepositAmountMissing ? "plan.deposit.amount.missing" : nil)
            KiraButton("plan.deposit.save") { Task { await model.submitDeposit() } }.block()
        }
        .padding(.bottom, KiraSpacing.space2)
    }
}
