/**
 "Kelas Aset" (board TambahAset): the seven classes as tiles, four to a row like Catat Manual, the
 chosen one pandan on pandan-soft with a pandan border. Fewer to a row as the text grows, so every
 name keeps one line. The name is the button VoiceOver reads; the tile above it chooses too but
 stays out of its way, as in Catat Manual, so the contrast audit reads the name on its own ground.
 */
import Domain
import Features
import SwiftUI

struct AssetClassGrid: View {
    let model: AssetFormModel
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("asset.class").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted)
                .padding(.horizontal, 4)
                .accessibilityAddTraits(.isHeader)
            Grid(horizontalSpacing: 6, verticalSpacing: 6) {
                ForEach(rows, id: \.self) { row in
                    GridRow {
                        ForEach(row, id: \.self) { tile($0) }
                        ForEach(row.count..<columns, id: \.self) { _ in Color.clear.gridCellUnsizedAxes(.vertical) }
                    }
                }
            }
            if let issue = model.issue(in: .assetClass) {
                Text(issue.message).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.vulnerable)
                    .padding(.horizontal, 4)
            }
        }
    }

    private var rows: [[AssetClass]] {
        let all = AssetClass.allCases
        return stride(from: 0, to: all.count, by: columns).map { Array(all[$0..<min($0 + columns, all.count)]) }
    }

    private var columns: Int {
        if typeSize >= .accessibility3 { return 1 }
        if typeSize.isAccessibilitySize { return 2 }
        return typeSize >= .xxLarge ? 3 : 4
    }

    private func tile(_ assetClass: AssetClass) -> some View {
        let isOn = assetClass == model.assetClass
        return VStack(spacing: 0) {
            Button {
                model.select(assetClass)
            } label: {
                KiraCategoryIcon(assetClass.tile)
            }
            .buttonStyle(.plain)
            .accessibilityHidden(true)
            Button {
                model.select(assetClass)
            } label: {
                Text(assetClass.title)
                    .font(.caption.weight(isOn ? .bold : .medium)).kiraLineHeight(16, size: 12)
                    .foregroundStyle(isOn ? Color.pandan : .inkMuted)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
                    .padding(.bottom, 7)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isOn ? .isSelected : [])
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
        .background(isOn ? Color.pandanSoft : .clear, in: RoundedRectangle(cornerRadius: KiraRadius.medium))
        .overlay {
            RoundedRectangle(cornerRadius: KiraRadius.medium).strokeBorder(isOn ? Color.pandan : .clear, lineWidth: 1.5)
        }
    }
}
