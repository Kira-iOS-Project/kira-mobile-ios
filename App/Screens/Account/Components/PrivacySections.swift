/**
 The parts of Data & Privasi under its intro: Persetujuan (the core consent locked on with its
 Wajib tag), Hakmu and the accordion Bagaimana Datamu Diproses?, and the CSV handed to the file
 exporter.
 */
import Domain
import Features
import SwiftUI
import UniformTypeIdentifiers

/** Persetujuan: three purposes, the first locked on. */
struct ConsentGroup: View {
    let model: PrivacyModel
    let consents: ConsentSettings

    var body: some View {
        KiraListGroup("account.privacy.consents", footer: "account.privacy.consents.footer") {
            KiraListRow(Text("account.privacy.core"), leading: .icon(.calculator), trailing: .toggle(.constant(true))) {
                KiraTag("account.privacy.core.required", tone: .neutral, icon: .lock)
            }
            .subtitle(Text("account.privacy.core.subtitle"))
            .disabled(true)
            KiraListRow(
                Text("account.privacy.ai"), leading: .icon(.sparkle),
                trailing: .toggle(
                    Binding(
                        get: { consents.isGranted(.aiProcessing) },
                        set: { isOn in Task { await model.setAIProcessing(isOn) } }))
            )
            .subtitle(Text("account.privacy.ai.subtitle"))
            KiraListRow(
                Text("account.privacy.weekly"), leading: .icon(.chart),
                trailing: .toggle(
                    Binding(
                        get: { consents.isGranted(.weeklySummary) },
                        set: { isOn in Task { await model.setWeeklySummary(isOn) } }))
            )
            .subtitle(Text("account.privacy.weekly.subtitle"))
        }
    }
}

/** Hakmu: Unduh Datamu and Keberatan atas Keputusan Otomatis, each opening its dialog. */
struct PrivacyRights: View {
    let onExport: () -> Void
    let onObject: () -> Void

    var body: some View {
        KiraListGroup("account.privacy.rights") {
            KiraListRow(Text("account.privacy.export"), leading: .icon(.download), action: onExport)
                .subtitle(Text("account.privacy.export.subtitle"))
            KiraListRow(Text("account.privacy.objection"), leading: .icon(.flag), action: onObject)
                .subtitle(Text("account.privacy.objection.subtitle"))
        }
    }
}

/** Bagaimana Datamu Diproses?: closed at first (AKN-04b is the open state). */
struct PrivacyProcessing: View {
    private let points: [LocalizedStringResource] = [
        "account.privacy.processing.sensitive", "account.privacy.processing.encrypted",
        "account.privacy.processing.separate",
    ]

    var body: some View {
        KiraAccordion("account.privacy.processing", subtitle: "account.privacy.processing.subtitle", icon: .shield) {
            VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                    ForEach(points.indices, id: \.self) { index in
                        HStack(alignment: .firstTextBaseline, spacing: KiraSpacing.space2) {
                            Text(bullet).accessibilityHidden(true)
                            Text(points[index])
                        }
                    }
                }
                .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.ink)
                Text("account.privacy.processing.law")
                    .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
        }
    }

    private var bullet: LocalizedStringResource { "account.bullet" }
}

/** The exported CSV as a document the file exporter saves where the person chooses. */
struct CSVDocument: FileDocument {
    static let readableContentTypes: [UTType] = [.commaSeparatedText]
    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw CocoaError(.fileReadCorruptFile) }
        self.data = data
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
