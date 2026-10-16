/**
 What Catat opens over the chat, the chat staying visible under the scrim: Ubah Transaksi
 (EditDraf), Catat Manual, Kuota AI as Kira sheets, Scan Struk as a full-screen camera, and the
 failure dialog of a chat action. A failed save in Ubah Transaksi or Catat Manual closes its sheet
 for the failure dialog; the sheet's model stays until both are closed, so Coba Lagi keeps the input.
 */
import Domain
import Features
import SwiftUI

struct RecordOverlays: ViewModifier {
    @Bindable var model: RecordModel

    func body(content: Content) -> some View {
        content
            .kiraSheet(
                Self.submission($model.editor, \.sheet), title: "record.edit.title", subtitle: editorSubtitle,
                top: 150, failureTitle: "record.failure.title", connectionMessage: "record.failure.connection",
                onRetry: { Task { await model.editor?.retry() } },
                content: {
                    if let editor = model.editor { DraftEditSheet(model: editor) { model.editor = nil } }
                }
            )
            .kiraSheet(
                Self.submission($model.manualEntry, \.sheet), title: "record.manual.title",
                subtitle: "record.manual.subtitle", leaf: KiraLeaf(.twig, tone: .soft, size: 120, isFlipped: true),
                failureTitle: "record.manual.failedTitle", connectionMessage: "record.manual.failedBody",
                onRetry: { Task { await model.manualEntry?.retry() } },
                content: {
                    if let form = model.manualEntry { ManualEntrySheet(model: form) { model.manualEntry = nil } }
                }
            )
            .kiraSheet(
                isPresented: Self.presence($model.quotaSheet), title: "record.quota.title", subtitle: quotaSubtitle,
                top: 330
            ) {
                if let sheet = model.quotaSheet {
                    QuotaSheetContent(sheet: sheet, onPlans: model.openPlans, onManual: model.openManual)
                }
            }
            .fullScreenCover(isPresented: Self.presence($model.scanner)) {
                if let scanner = model.scanner {
                    ReceiptScanScreen(model: scanner, camera: model.dependencies.camera) { model.scanner = nil }
                }
            }
            .recordFailureDialog($model.failure)
    }

    /** "Draf · dari pesan 12.41 WIB". */
    private var editorSubtitle: LocalizedStringResource? {
        model.editor.map { "record.edit.subtitle \($0.sourceTime.formatted(.kiraTime))" }
    }

    /** "Paket Kira Gratis · Oktober". */
    private var quotaSubtitle: LocalizedStringResource? {
        model.quotaSheet.map { sheet in
            let plan = String(localized: sheet.plan.recordName)
            return "record.quota.subtitle \(plan) \(sheet.today.formatted(.kiraMonth))"
        }
    }

    /**
     The sheet of the model in `form`; once the sheet is closed with no failure dialog left (the X,
     Tutup), `form` is cleared. Without a model, a closed sheet.
     */
    static func submission<Form>(
        _ form: Binding<Form?>, _ sheet: ReferenceWritableKeyPath<Form, SheetSubmission>
    ) -> Binding<SheetSubmission> {
        Binding(
            get: { form.wrappedValue?[keyPath: sheet] ?? SheetSubmission() },
            set: { submission in
                form.wrappedValue?[keyPath: sheet] = submission
                if !submission.isOpen && submission.failure == nil { form.wrappedValue = nil }
            })
    }

    /** True while `value` holds something; false clears it. */
    static func presence<Value>(_ value: Binding<Value?>) -> Binding<Bool> {
        Binding(get: { value.wrappedValue != nil }, set: { if !$0 { value.wrappedValue = nil } })
    }
}
