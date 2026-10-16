/**
 The "Format File CSV" card of Impor Mutasi: the three columns with the sample's lines, the rules
 for dates and amounts, and "Unduh Contoh CSV", which hands the same sample to the share sheet so
 it can be saved to Files or opened in a spreadsheet.
 */
import CoreTransferable
import Domain
import SwiftUI
import UniformTypeIdentifiers

struct StatementFormatCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: KiraSpacing.space3) {
                Text("import.format.title")
                    .font(.body.weight(.semibold)).kiraLineHeight(22, size: 17)
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 0)
                KiraTag("import.format.tag", tone: .pandan)
            }
            Text("import.format.lead").font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
            sample
            Text("import.format.rules").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            ShareLink(item: StatementSampleFile(), preview: SharePreview(Text("import.sample.preview"))) {
                HStack(spacing: KiraSpacing.space2) {
                    KiraIcon(.download, size: 18, weight: .semibold)
                    Text("import.sample")
                }
            }
            .buttonStyle(KiraButtonStyle(variant: .secondary, size: .medium, fillsWidth: true))
        }
        .padding(KiraSpacing.space4)
        .kiraCard()
    }

    /** The sample file's own lines, so what the card shows is what the download holds. */
    private var sample: some View {
        let lines = StatementTemplate.text.split(separator: "\n").map(String.init)
        return ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                    Text(line).fontWeight(index == 0 ? .bold : .medium)
                }
            }
            .kiraFont(.formula)
            .foregroundStyle(.ink)
            .padding(.vertical, 10)
            .padding(.horizontal, KiraSpacing.space3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard(.surface, cornerRadius: KiraRadius.small)
        .accessibilityElement(children: .combine)
    }
}

/** The sample CSV as a file for the share sheet. */
struct StatementSampleFile: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .commaSeparatedText) { _ in
            Data(StatementTemplate.text.utf8)
        }
        .suggestedFileName(StatementTemplate.fileName)
    }
}
