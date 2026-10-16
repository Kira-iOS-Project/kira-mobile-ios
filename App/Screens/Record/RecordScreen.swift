/**
 Catat (canvas Catat, CatatTersimpan, CatatMengetik, EditDraf, HasilScan, KuotaAI, InputSuara): the
 chat with its header, the composer or the voice panel at the bottom, and everything Catat opens
 over itself. The dock is the root's: this screen leaves room for it under the composer.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct RecordScreen: View {
    @State private var model: RecordModel
    private let onOpen: (AppRoute) -> Void

    /** Catat on `service`, with the device's own readers, camera and microphone. */
    init(service: any RecordService, onOpen: @escaping (AppRoute) -> Void) {
        self.init(dependencies: .system(service: service), onOpen: onOpen)
    }

    /** Catat on given dependencies: previews pass their own devices. */
    init(dependencies: RecordDependencies, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: RecordModel(dependencies: dependencies))
        self.onOpen = onOpen
    }

    var body: some View {
        VStack(spacing: 0) {
            RecordHeader(profile: model.profile, onHistory: model.openHistory, onHelp: model.openHelp)
            content
        }
        .background(alignment: .top) { RecordLeaves() }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .modifier(RecordOverlays(model: model))
        .task {
            model.onOpen = onOpen
            await model.load()
        }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading, .empty:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let problem):
            RecordLoadFailure(problem: problem) { Task { await model.load() } }
        case .loaded(let profile):
            ChatTimelineView(model: model, initial: profile.initial)
                .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
        }
    }

    @ViewBuilder private var bottomBar: some View {
        VStack(spacing: KiraSpacing.space3) {
            if model.showsAIOff { RecordAIOffNotice(onOpen: model.openPrivacy) }
            if let voice = model.voice {
                VoicePanel(model: voice)
            } else {
                RecordComposer(model: model)
            }
        }
        .padding(.horizontal, KiraSpacing.screen)
        .padding(.top, KiraSpacing.space2)
        .padding(.bottom, KiraSpacing.space3)
    }
}

/** The two soft leaves behind the chat's top (canvas: ranting 140 at the right, pandan 110 at the left). */
private struct RecordLeaves: View {
    var body: some View {
        ZStack(alignment: .top) {
            KiraLeaf(.twig, tone: .soft, size: 140, isFlipped: true)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(x: 40, y: 24)
            KiraLeaf(.pandan, tone: .soft, size: 110, isFlipped: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(x: -46, y: 40)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/** The chat could not load: the problem's message and Coba Lagi. */
private struct RecordLoadFailure: View {
    let problem: AppProblem
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraIllustration(.umbrella, size: 112)
            Text(RecordFailure.problem(problem).recordMessage).font(.subheadline).foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
            KiraButton("record.retry", action: onRetry)
        }
        .padding(KiraSpacing.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    RecordScreen(dependencies: PreviewRecordData.dependencies) { _ in }
}
