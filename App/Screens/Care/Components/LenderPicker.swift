/**
 Pemberi Pinjaman (PED-09b, board NaskahNegosiasiDropdown): a field-like button with a chevron; open,
 a list of the person's lenders falls over the fields below, each with its instalment and a check on
 the one picked. Picking one fills Cicilan Sekarang. Without a debt recorded the field says so.
 */
import Domain
import Features
import SwiftUI

struct LenderPicker: View {
    @Bindable var model: NegotiationScriptModel
    let debts: [CareDebt]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("care.script.lender")
                .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted)
                .padding(.horizontal, 4)
                .accessibilityHidden(true)
            Button {
                model.isPickingLender.toggle()
            } label: {
                HStack(spacing: KiraSpacing.space2) {
                    selection.font(.body).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    KiraIcon(.chevronDown, size: 20).foregroundStyle(.inkMuted)
                        .rotationEffect(.degrees(model.isPickingLender ? 180 : 0))
                }
                .padding(.horizontal, KiraSpacing.space4)
                .frame(minHeight: 52)
                .kiraCard(border: model.isPickingLender ? .pandan : .hairline, cornerRadius: KiraRadius.medium)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(debts.isEmpty)
            .accessibilityLabel(Text("care.script.lender"))
            .accessibilityValue(selection)
            .accessibilityHint(Text(debts.isEmpty ? "care.script.noDebts" : "care.script.lenderHint"))
        }
        .overlay(alignment: .topLeading) {
            if model.isPickingLender { list.offset(y: 82) }
        }
    }

    private var selection: Text {
        if let lender = model.lender { return Text(lender.name) }
        return Text(debts.isEmpty ? "care.script.noDebts" : "care.script.lenderPrompt")
    }

    private var list: some View {
        VStack(spacing: 2) {
            ForEach(debts) { debt in
                let isOn = debt.id == model.lender?.id
                Button {
                    model.select(debt)
                } label: {
                    HStack(spacing: KiraSpacing.space3) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(debt.name).font(.body.weight(isOn ? .semibold : .medium)).foregroundStyle(.ink)
                            info(debt).font(.footnote).foregroundStyle(.inkMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        if isOn { KiraIcon(.check, size: 20, weight: .bold).foregroundStyle(.pandan) }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, KiraSpacing.space3)
                    .frame(minHeight: 48)
                    .kiraCard(
                        isOn ? .pandanSoft : .clear, border: isOn ? .pandan : .clear, cornerRadius: KiraRadius.small
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(debt.name))
                .accessibilityValue(info(debt))
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
        .padding(6)
        .kiraCard(border: .lineStrong, cornerRadius: KiraRadius.medium)
        /** An overlay is offered only the picker's own height; the list takes the height its rows need. */
        .fixedSize(horizontal: false, vertical: true)
    }

    /** "Cicilan Rp230.000,00 per bulan": a lender's instalment, on its row and as its VoiceOver value. */
    private func info(_ debt: CareDebt) -> Text {
        Text("care.script.lenderInfo \(Decimal(debt.monthlyInstalment).formatted(.rupiah))")
    }
}
