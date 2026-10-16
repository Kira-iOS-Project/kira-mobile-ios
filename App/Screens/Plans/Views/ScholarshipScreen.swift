/**
 Beasiswa Kira (AKN-09, AKN-10c, AKN-10d; boards BeasiswaKira, BeasiswaKiraStatus,
 BeasiswaKiraDiterima): the explanation with Ajukan Beasiswa, or, once an application is open, its
 status. The entry of the scholarship flow: Ajukan Beasiswa opens on the caller's navigation stack;
 Mode Darurat Utang, Kira Peduli and Mulai Pakai Kira Plus go through `onOpen`.
 */
import Domain
import Features
import SwiftUI

struct ScholarshipScreen: View {
    private let service: any PlansService
    private let onOpen: (AppRoute) -> Void
    @State private var model: ScholarshipModel
    @State private var applies = false
    @Environment(\.dismiss) private var dismiss

    init(service: any PlansService, onOpen: @escaping (AppRoute) -> Void) {
        self.service = service
        self.onOpen = onOpen
        _model = State(initialValue: ScholarshipModel(service: service))
    }

    var body: some View {
        PlansScreenFrame(leaf: .high) {
            KiraNavBar(title, subtitle: subtitle, leading: .back("scholarship.back") { dismiss() }) {
                KiraHelpButton(.icon) { onOpen(.care) }
            }
            content
        }
        .task { await model.load() }
        .navigationDestination(isPresented: $applies) {
            ScholarshipApplyView(service: service, onOpen: onOpen) {
                applies = false
                Task { await model.load() }
            }
        }
    }

    private var stage: ScholarshipOverview.Stage? { model.phase.value?.stage }

    private var title: LocalizedStringResource {
        switch stage {
        case .pending, .accepted: "scholarship.status.title"
        case .intro, nil: "scholarship.title"
        }
    }

    private var subtitle: LocalizedStringResource? {
        switch stage {
        case .pending, .accepted: "scholarship.title"
        case .intro, nil: nil
        }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading, .empty:
            PlansLoadingView()
        case .failed(let problem):
            PlansProblemView(problem: problem) { Task { await model.load() } }
        case .loaded(let overview):
            switch overview.stage {
            case .intro:
                ScholarshipIntro(overview: overview, onLater: { dismiss() }, onApply: { applies = true })
            case .pending(let application):
                ScholarshipPendingView(application: application, model: model, onOpen: onOpen)
            case .accepted(let application):
                ScholarshipAcceptedView(application: application) { onOpen(.home) }
            }
        }
    }
}

#Preview {
    NavigationStack { ScholarshipScreen(service: PreviewPlansService(), onOpen: { _ in }) }
}
