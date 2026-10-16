/**
 Riwayat's controls above the list: the search box (the design system's field box with the
 search icon in front, as the board draws it) and the Semua/Keluar/Masuk segments.
 */
import Features
import SwiftUI

struct HistoryFilters: View {
    @Bindable var model: HistoryModel
    @FocusState private var isSearching: Bool

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            searchBox
            KiraSegmented("history.kind.label", options: options, selection: kind)
        }
    }

    private var searchBox: some View {
        HStack(spacing: 10) {
            KiraIcon(.search, size: 20).foregroundStyle(.inkMuted).accessibilityHidden(true)
            TextField(text: $model.searchText, prompt: Text("history.search").foregroundStyle(.inkMuted)) {
                Text("history.search")
            }
            .font(.body)
            .foregroundStyle(.ink)
            .submitLabel(.search)
            .autocorrectionDisabled()
            .focused($isSearching)
            .padding(.vertical, 12)
        }
        .padding(.horizontal, KiraSpacing.space4)
        .frame(minHeight: 48)
        .kiraCard(border: isSearching ? .pandan : .hairline, cornerRadius: KiraRadius.medium)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isSearchField)
    }

    private var options: [KiraSegmented<HistoryModel.Kind>.Option] {
        [
            .init(id: .all, title: "history.kind.all"),
            .init(id: .expense, title: "history.kind.expense"),
            .init(id: .income, title: "history.kind.income"),
        ]
    }

    private var kind: Binding<HistoryModel.Kind> {
        Binding(get: { model.kind }, set: { kind in Task { await model.select(kind: kind) } })
    }
}
