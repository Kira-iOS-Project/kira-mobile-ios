/**
 A Kira sheet whose main action goes to the server (`docs/design-system.md`, Sheets). When the
 submit fails, the sheet closes and the failure dialog shows once the sheet has gone: the problem's
 own sentence (`problem.<CODE>`), the connection's for a request that got no answer, or the generic
 one with the reference. Coba Lagi on top opens the sheet again on what was typed and submits again;
 Tutup under it closes the dialog. A check the app makes itself stays inline in the open sheet.
 Both are covers over the window, so one comes up only after the other's layer is down, and Coba
 Lagi's retry starts only then too.
 */
import APIClient
import Features
import SwiftUI

extension View {
    /**
     Presents `content` as a Kira sheet while `submission` is open, and its failure as a dialog
     titled `failureTitle` (`connectionMessage` when the request got no answer). Coba Lagi opens the
     sheet again and, once it has risen, runs `onRetry`, which submits again. `onGone` runs each time
     the last cover is down and none follows, the moment to navigate after a submit went through.
     */
    func kiraSheet<Content: View>(
        _ submission: Binding<SheetSubmission>, title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil, top: CGFloat? = nil, leaf: KiraLeaf? = nil,
        failureTitle: LocalizedStringResource, connectionMessage: LocalizedStringResource = "problem.connection",
        onRetry: @escaping () -> Void, onGone: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            SubmissionSheet(
                submission: submission,
                header: SheetHeader(title: title, subtitle: subtitle, top: top, leaf: leaf),
                failure: SheetFailureText(title: failureTitle, connection: connectionMessage), onRetry: onRetry,
                onGone: onGone, sheet: content))
    }
}

/** What the sheet shows above its content. */
private struct SheetHeader {
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource?
    let top: CGFloat?
    let leaf: KiraLeaf?
}

/**
 The failure dialog's words: also those of a screen's own save that failed (Atur Budget), so every
 failed submit reads the same way.
 */
struct SheetFailureText {
    let title: LocalizedStringResource
    let connection: LocalizedStringResource

    /** The sentence for `problem`. */
    func message(for problem: AppProblem) -> LocalizedStringResource {
        if problem.isConnectionLoss { return connection }
        if problem.showsReference { return "sheet.failure.reference \(problem.reference)" }
        return problem.message
    }
}

/** Which cover is up, or on its way down: the sheet, or the dialog of one problem. */
private enum SheetLayer: Equatable {
    case sheet
    case dialog(AppProblem)
}

/**
 Keeps the sheet and its dialog one at a time: `layer` names the cover that is up, and changes only
 once that cover's layer is down, to whichever the submission wants then.
 */
private struct SubmissionSheet<Sheet: View>: ViewModifier {
    @Binding var submission: SheetSubmission
    let header: SheetHeader
    let failure: SheetFailureText
    let onRetry: () -> Void
    let onGone: (() -> Void)?
    @ViewBuilder let sheet: () -> Sheet
    @State private var layer: SheetLayer?
    /**
     Coba Lagi was tapped: the sheet opens once the dialog's layer is down, and the retry starts once
     the sheet has risen, so the retry's own success or failure never meets a cover on its way up.
     */
    @State private var retryPending = false

    func body(content: Content) -> some View {
        content
            .kiraSheet(
                isPresented: sheetShown, title: header.title, subtitle: header.subtitle, top: header.top,
                leaf: header.leaf, onShown: sheetUp, onDismiss: coverGone, content: sheet
            )
            .kiraDialog(isPresented: dialogShown, onDismiss: coverGone) { dialog }
            .onChange(of: wanted, initial: true) { _, wanted in
                if layer == nil { layer = wanted }
            }
    }

    /** The cover the submission asks for. */
    private var wanted: SheetLayer? {
        if submission.isOpen { return .sheet }
        return submission.failure.map(SheetLayer.dialog)
    }

    private var sheetShown: Binding<Bool> {
        Binding(get: { layer == .sheet && submission.isOpen }, set: { if !$0 { submission.close() } })
    }

    private var dialogShown: Binding<Bool> {
        Binding(
            get: { layer != .sheet && layer != nil && layer == wanted },
            set: { if !$0 { submission.dismissFailure() } })
    }

    /** The dialog of the problem in `layer`, kept while the dialog fades out. */
    private var dialog: KiraDialog {
        var problem = AppProblem.connectionLost
        if case .dialog(let shown) = layer { problem = shown }
        return KiraDialog(
            failure.title, message: failure.message(for: problem), art: .illustration(.umbrella),
            primary: KiraButton("sheet.failure.retry") { retryPending = true },
            secondary: KiraButton("ds.close", variant: .secondary) {})
    }

    private func coverGone() {
        layer = wanted
        if retryPending {
            submission.open()
        } else if layer == nil {
            onGone?()
        }
    }

    private func sheetUp() {
        guard retryPending else { return }
        retryPending = false
        onRetry()
    }
}
