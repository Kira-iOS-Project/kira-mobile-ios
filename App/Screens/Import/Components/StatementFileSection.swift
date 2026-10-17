/**
 The file part of Impor Mutasi: the dashed picker before a file is chosen (CAT-11), the "File
 Berhasil Dibaca" card with the file's name, size, rows and days (11b), or the reason a file was
 refused with the way to fix it.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct StatementFileSection: View {
    let model: StatementImportModel
    let pick: () -> Void
    /** Lihat Paket, under a refusal by the plan. */
    let openPlans: () -> Void

    var body: some View {
        switch model.phase {
        case .choosing:
            picker
        case .read(let file):
            readCard(file)
        case .invalid(let error):
            invalidCard(error)
        }
    }

    private var picker: some View {
        Button(action: pick) {
            VStack(spacing: KiraSpacing.space1) {
                KiraIcon(.upload, size: 22, weight: .semibold)
                    .foregroundStyle(.pandan)
                    .frame(width: KiraSize.tap, height: KiraSize.tap)
                    .background(Color.pandanSoft, in: Circle())
                    .overlay { Circle().strokeBorder(Color.pandanLine, lineWidth: 1) }
                    .padding(.bottom, 6)
                Text("import.picker.title").font(.body.weight(.semibold)).kiraLineHeight(22, size: 17).foregroundStyle(
                    .ink)
                Text("import.picker.limit").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 14)
            .padding(.bottom, KiraSpacing.space4)
            .padding(.horizontal, KiraSpacing.space4)
            .background(Color.surfaceRaised, in: RoundedRectangle(cornerRadius: KiraRadius.large, style: .continuous))
            .overlay {
                /** CSS's 1.5 px dashed border: dashes twice the width, gaps the width. */
                RoundedRectangle(cornerRadius: KiraRadius.large, style: .continuous)
                    .strokeBorder(Color.lineStrong, style: StrokeStyle(lineWidth: 1.5, dash: [3, 1.5]))
            }
        }
        .buttonStyle(.plain)
    }

    private func readCard(_ file: StatementImportModel.StatementFile) -> some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            mascotHeader(.happy, title: "import.read.title", message: "import.read.body")
            HStack(spacing: KiraSpacing.space3) {
                KiraIcon(.file, size: 22).foregroundStyle(.pandan).accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 0) {
                    Text(file.name)
                        .font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15)
                        .lineLimit(1).truncationMode(.middle)
                    Text(fileFacts(file)).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                KiraButton("import.replace", variant: .quiet, size: .small, action: pick)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, KiraSpacing.space3)
            .kiraCard(cornerRadius: KiraRadius.small)
            if let problem = model.uploadProblem {
                KiraNotice(
                    .warning, title: "import.upload.failed",
                    message: problem.message)
                if model.needsPlan {
                    KiraButton("import.plans", variant: .secondary, action: openPlans).block()
                }
            }
        }
        .padding(KiraSpacing.space4)
        .kiraCard(.pandanSoft, border: .pandanLine)
    }

    private func invalidCard(_ error: BankStatementError) -> some View {
        mascotHeader(.calm, title: "import.invalid.title", message: error.message)
            .padding(KiraSpacing.space4)
            .kiraCard(.vulnerableSoft, border: .vulnerableLine)
    }

    private func mascotHeader(
        _ expression: KiraMascot.Expression, title: LocalizedStringResource, message: LocalizedStringResource
    ) -> some View {
        HStack(spacing: KiraSpacing.space3) {
            KiraMascot(expression, size: 56)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.body.weight(.semibold)).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                Text(message).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
        }
    }

    /** "12 KB · 42 baris · 1–30 September 2026". */
    private func fileFacts(_ file: StatementImportModel.StatementFile) -> LocalizedStringResource {
        let size = Int64(file.byteCount).formatted(.byteCount(style: .file).locale(Locale(identifier: "id_ID")))
        let days = DayRange(first: file.statement.dateFrom, last: file.statement.dateTo).formatted(.kiraDayRange)
        return "import.read.facts \(size) \(file.statement.rows.count) \(days)"
    }
}
