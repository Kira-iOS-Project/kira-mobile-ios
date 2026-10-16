/**
 What Catat opens over the chat, the chat staying visible under the scrim: Ubah Transaksi
 (EditDraf), Catat Manual, Kuota AI as Kira sheets, Scan Struk as a full-screen camera, and the
 failure dialog of a chat action.
 */
import Domain
import Features
import SwiftUI

struct RecordOverlays: ViewModifier {
    @Bindable var model: RecordModel

    func body(content: Content) -> some View {
        content
            .kiraSheet(
                isPresented: Self.presence($model.editor), title: "record.edit.title", subtitle: editorSubtitle
            ) {
                if let editor = model.editor { DraftEditSheet(model: editor) { model.editor = nil } }
            }
            .kiraSheet(
                isPresented: Self.presence($model.manualEntry), title: "record.manual.title",
                subtitle: "record.manual.subtitle"
            ) {
                if let form = model.manualEntry { ManualEntrySheet(model: form) { model.manualEntry = nil } }
            }
            .kiraSheet(
                isPresented: Self.presence($model.quotaSheet), title: "record.quota.title", subtitle: quotaSubtitle
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

    /** True while `value` holds something; false clears it. */
    static func presence<Value>(_ value: Binding<Value?>) -> Binding<Bool> {
        Binding(get: { value.wrappedValue != nil }, set: { if !$0 { value.wrappedValue = nil } })
    }
}
