/**
 Riwayat's loaded list: the period's totals, the category chips, then the days, with the folded
 days as one quiet button and older pages loading as the end appears.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct HistoryList: View {
    let content: HistoryModel.Content
    let model: HistoryModel
    let open: (Domain.Transaction) -> Void

    var body: some View {
        HistoryTotalsCard(summary: content.summary)
        categoryChips
        if content.sections.isEmpty {
            Text("history.noMatch")
                .font(.body).kiraLineHeight(22, size: 17)
                .foregroundStyle(.inkMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, KiraSpacing.space6)
        }
        ForEach(content.sections) { section in
            switch section {
            case .day(let day):
                HistoryDayGroup(day: day, period: content.period, open: open)
            case .olderDays(let first, let last):
                foldButton(DayRange(first: first, last: last))
            }
        }
        if content.canLoadMore {
            if let failure = model.moreFailure {
                moreFailed(failure)
            } else {
                ProgressView().frame(maxWidth: .infinity).task { await model.loadMore() }
            }
        }
    }

    /** An older page that did not load: what went wrong, and Coba Lagi to ask for it again. */
    private func moreFailed(_ problem: AppProblem) -> some View {
        VStack(spacing: KiraSpacing.space2) {
            Text(problem.message).kiraFont(.callout).foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
            if problem.showsReference {
                /** The reference is data a person quotes to support, shown as is. */
                Text(problem.reference).kiraFont(.caption).foregroundStyle(.inkMuted)
            }
            KiraButton("loadFailed.retry", variant: .quiet, size: .small) { Task { await model.loadMore() } }
                .icon(.refresh)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, KiraSpacing.space4)
    }

    /** The chips scroll sideways past the screen's right margin, as on the board. */
    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: KiraSpacing.space2) {
                KiraChip("history.category.all", isSelected: model.category == nil) { select(nil) }
                ForEach(model.categories, id: \.self) { category in
                    KiraChip(
                        category.title, isSelected: model.category == category, leading: .category(category.tile)
                    ) {
                        select(category)
                    }
                }
            }
            .padding(.vertical, 2)
            .padding(.trailing, KiraSpacing.screen)
        }
        .padding(.trailing, -KiraSpacing.screen)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("history.category.label"))
    }

    private func select(_ category: TransactionCategory?) {
        Task { await model.select(category: category) }
    }

    private func foldButton(_ range: DayRange) -> some View {
        HStack(spacing: KiraSpacing.space2) {
            Rectangle().fill(.line).frame(height: 1).accessibilityHidden(true)
            KiraButton("history.showOlder \(range.formatted(.kiraDayRange))", variant: .quiet, size: .small) {
                model.showOlderDays()
            }
            .icon(.chevronDown)
            .layoutPriority(1)
            Rectangle().fill(.line).frame(height: 1).accessibilityHidden(true)
        }
    }
}

/** "Keluar periode ini" and "Masuk": the engine's totals of the period. */
struct HistoryTotalsCard: View {
    let summary: TransactionSummary

    var body: some View {
        KiraRowStack {
            row("history.totals.expense", amount: summary.expense, isIncome: false)
            row("history.totals.income", amount: summary.income, isIncome: true)
        }
        .padding(.horizontal, KiraSpacing.space4)
        .padding(.vertical, 2)
        .kiraCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("history.totals.label"))
    }

    private func row(_ label: LocalizedStringResource, amount: Int, isIncome: Bool) -> some View {
        HStack(spacing: KiraSpacing.space3) {
            KiraIcon(.arrowUp, size: 20, weight: .semibold)
                .rotationEffect(.degrees(isIncome ? 225 : 45))
                .foregroundStyle(isIncome ? Color.pandan : .ink)
                .frame(width: KiraSize.tile, height: KiraSize.tile)
                .kiraCard(
                    isIncome ? .pandanSoft : .surfaceMuted, border: isIncome ? .pandanLine : .hairline,
                    cornerRadius: KiraRadius.small
                )
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.footnote.weight(.medium)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                KiraAmount(Decimal(amount), size: .medium)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 14)
        .accessibilityElement(children: .combine)
        .kiraRowSeparator()
    }
}
