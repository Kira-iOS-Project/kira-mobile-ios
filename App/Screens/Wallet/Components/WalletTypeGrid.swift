/**
 "Jenis" (board TambahDompet): the six kinds as tiles, three to a row, the chosen one pandan-soft with
 a pandan border and a check; fewer to a row as the text grows, so every name keeps its line. Under
 them, the note that a credit card, paylater or pinjol goes to Akun Utang.
 */
import Domain
import Features
import SwiftUI

struct WalletTypeGrid: View {
    let model: AddWalletModel
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            Text("wallet.add.type").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1)
                .accessibilityAddTraits(.isHeader)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columns), spacing: 8) {
                ForEach(WalletType.selectableCases, id: \.self) { tile($0) }
            }
            HStack(alignment: .top, spacing: 6) {
                KiraIcon(.info, size: 16).foregroundStyle(.inkMuted).accessibilityHidden(true)
                Text("wallet.add.debtNote").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
            .padding(.horizontal, KiraSpacing.space1)
        }
    }

    private var columns: Int {
        if typeSize >= .accessibility3 { return 1 }
        return typeSize.isAccessibilitySize ? 2 : 3
    }

    private func tile(_ type: WalletType) -> some View {
        let isOn = type == model.type
        return Button {
            model.select(type)
        } label: {
            VStack(spacing: 6) {
                KiraCategoryIcon(type.category)
                Text(type.titleKey)
                    .font(.footnote.weight(isOn ? .bold : .medium)).kiraLineHeight(18, size: 13)
                    .foregroundStyle(isOn ? Color.pandan : .ink)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(isOn ? Color.pandanSoft : .surfaceRaised, in: RoundedRectangle(cornerRadius: KiraRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: KiraRadius.medium)
                    .strokeBorder(isOn ? Color.pandan : .hairline, lineWidth: isOn ? 1.5 : 1)
            }
            .overlay(alignment: .topTrailing) {
                if isOn {
                    KiraIcon(.check, size: 12, weight: .bold).foregroundStyle(.onPandan)
                        .frame(width: 20, height: 20).background(.pandan, in: Circle())
                        .padding(6).accessibilityHidden(true)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(type.titleKey))
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}
