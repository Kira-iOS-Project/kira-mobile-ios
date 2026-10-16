/**
 One debt guide (PED-08 Ditagih Kasar, PED-13 Diteror Pinjol Ilegal, PED-14 Aduan Belum Selesai,
 PED-15 Ditawari Jasa "Pelunasan"; boards PenagihanKasar, PinjolIlegal, AduanTidakSelesai,
 JasaPelunasan): the pandan card, the four steps, the actions and the closing notice. Numbers and
 sites come from the contact list (DebtGuideModel); a site opens in the browser.
 */
import Domain
import Features
import SwiftUI

struct DebtGuideScreen: View {
    @State private var model: DebtGuideModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    init(guide: DebtGuide, care: any CareService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: DebtGuideModel(guide: guide, care: care))
        self.onOpen = onOpen
    }

    private var content: DebtGuideContent { .of(model.guide) }

    var body: some View {
        DebtCareFrame {
            KiraNavBar(content.title, subtitle: content.subtitle, leading: .back("debtGuide.back") { dismiss() })
            DebtGuideCard(content: content)
            DebtGuideSteps(steps: content.steps)
            actions
            notice
        }
        .task { await model.load() }
    }

    private var actions: some View {
        VStack(spacing: KiraSpacing.space2) {
            ForEach(Array(model.guide.actions.enumerated()), id: \.offset) { index, action in
                KiraButton(action.label.title, variant: variant(at: index)) { perform(action) }
                    .icon(action.label.icon)
                    .block()
            }
        }
        .accessibilityElement(children: .contain)
    }

    /** Ditagih Kasar's two OJK buttons are both secondary; elsewhere the first is the primary. */
    private func variant(at index: Int) -> KiraButton.Variant {
        index == 0 && model.guide != .harshCollection ? .primary : .secondary
    }

    @ViewBuilder private var notice: some View {
        if let link = model.guide.noticeLink {
            KiraNotice(.info, message: content.notice)
                .link(link.label.title) { perform(link) }
        } else {
            KiraNotice(.info, message: content.notice)
        }
    }

    private func perform(_ action: DebtGuideAction) {
        switch model.destination(action) {
        case .link(let url): openURL(url)
        case .route(let route): onOpen(route)
        case nil: break
        }
    }
}

#Preview {
    NavigationStack { DebtGuideScreen(guide: .harshCollection, care: PreviewCareService()) { _ in } }
}
