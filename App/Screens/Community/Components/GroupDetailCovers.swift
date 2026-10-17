/**
 The covers over Detail Grup, one at a time: Aturan Komunitas, Tautan Keluar, Laporkan Grup (with
 "Laporan Terkirim" over it, as on its board) and the failure dialog. Each is a cover over the
 window, so the next one comes up only once the one before is down (as `SubmissionSheet` does).
 Coba Lagi reopens the sheet once the dialog is down, and its submit starts only once the sheet has
 fully risen (`onShown`). Selesai closes the report sheet and runs `onReported`.
 */
import Domain
import Features
import SwiftUI

struct GroupDetailCovers: ViewModifier {
    @Bindable var model: GroupDetailModel
    let onReported: () -> Void
    /** The cover that is up, or on its way down. */
    @State private var layer: Layer?
    /** Coba Lagi was tapped: the retry starts once the dialog is down. */
    @State private var retriesWhenGone = false

    /** A cover over Detail Grup; the failure keeps what it shows while it fades out. */
    private enum Layer: Equatable {
        case rules, outbound, report
        case failure(CommunityFailure, GroupDetailModel.Attempt)
    }

    func body(content: Content) -> some View {
        content
            .kiraSheet(
                isPresented: shown(.rules, close: { model.showsRules = false }), title: "community.rules.title",
                subtitle: "community.rules.subtitle", top: 90,
                onShown: rulesShown, onDismiss: coverGone
            ) {
                GroupRulesSheet(model: model)
            }
            .kiraSheet(
                isPresented: shown(.outbound, close: { model.invite = nil }), label: outboundLabel, top: 472,
                onDismiss: coverGone
            ) {
                OutboundLinkSheet(group: model.phase.value, invite: model.invite) { model.invite = nil }
            }
            .kiraSheet(
                isPresented: shown(.report, close: { model.showsReport = false }), title: "community.report.title",
                subtitle: model.phase.value.map { "community.report.subtitle \($0.summary.name)" },
                leaf: KiraLeaf(.twig, tone: .soft, size: 120, isFlipped: true),
                onShown: reportShown, onDismiss: coverGone
            ) {
                GroupReportSheet(model: model)
                    .kiraDialog(isPresented: $model.showsReportSent, onDismiss: reportDone) {
                        KiraDialog(
                            "community.report.sent.title", message: "community.report.sent.body",
                            art: .illustration(.bloom),
                            primary: KiraButton("community.report.sent.done") { model.finishReport() })
                    }
            }
            .kiraDialog(isPresented: failureShown, onDismiss: coverGone) { failureDialog }
            .onChange(of: wanted, initial: true) { _, wanted in
                if layer == nil { layer = wanted }
            }
    }

    /** The cover the model asks for. */
    private var wanted: Layer? {
        if model.showsRules { return .rules }
        if model.invite != nil { return .outbound }
        if model.showsReport { return .report }
        if let failure = model.failure, !retriesWhenGone { return .failure(failure.failure, failure.attempt) }
        return nil
    }

    private var outboundLabel: LocalizedStringResource {
        model.invite.map { "community.outbound.label \(String(localized: $0.platform.title))" }
            ?? "community.outbound.label \("")"
    }

    private func shown(_ cover: Layer, close: @escaping () -> Void) -> Binding<Bool> {
        Binding(get: { layer == cover && wanted == cover }, set: { if !$0 { close() } })
    }

    private var failureShown: Binding<Bool> {
        Binding(
            get: { if case .failure = layer { layer == wanted } else { false } },
            set: { if !$0, !retriesWhenGone { model.dismissFailure() } })
    }

    private var failureDialog: KiraDialog {
        guard case .failure(let failure, let attempt) = layer else {
            return GroupFailureDialog.dialog(.connection, of: .join) {}
        }
        return GroupFailureDialog.dialog(failure, of: attempt) { retriesWhenGone = true }
    }

    /** Aturan Komunitas has fully risen: a consent Coba Lagi left waiting is sent now. */
    private func rulesShown() {
        Task { await model.sheetShown(.acceptRules) }
    }

    /** Laporkan Grup has fully risen: a report Coba Lagi left waiting is sent now. */
    private func reportShown() {
        Task { await model.sheetShown(.report) }
    }

    /** "Laporan Terkirim" is down: after Selesai the sheet closes too. */
    private func reportDone() {
        if model.reportFinished { model.showsReport = false }
    }

    private func coverGone() {
        if model.reportFinished, layer == .report {
            onReported()
            return
        }
        if retriesWhenGone {
            retriesWhenGone = false
            layer = nil
            Task { await model.retry() }
            return
        }
        layer = wanted
    }
}
