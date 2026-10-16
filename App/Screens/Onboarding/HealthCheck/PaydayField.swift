/**
 Tanggal Gajian (ONB-10): the row that names the payday ("Setiap Tanggal 25") and opens the
 calendar sheet (ONB-10b), whose "Gajian di akhir bulan" dims the calendar (ONB-10c).
 */
import Domain
import SwiftUI

struct PaydayField: View {
    @Binding var payday: Payday
    @State private var isPicking = false

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            Text("onboarding.payday.label")
                .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                .padding(.horizontal, KiraSpacing.space1)
                .accessibilityHidden(true)
            Button {
                isPicking = true
            } label: {
                HStack(spacing: KiraSpacing.space3) {
                    KiraIcon(.calendar, size: 22).foregroundStyle(.pandan)
                    PaydayName(payday: payday).font(.body).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    KiraIcon(.chevronDown, size: 20).foregroundStyle(.inkMuted)
                }
                .padding(.horizontal, KiraSpacing.space4)
                .frame(minHeight: 52)
                .background(.surfaceRaised, in: RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous)
                        .strokeBorder(isPicking ? Color.pandan : .hairline, lineWidth: 1.5)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("onboarding.payday.label"))
            .accessibilityValue(PaydayName(payday: payday).text)
            Text("onboarding.payday.hint").onboardingNote().padding(.horizontal, KiraSpacing.space1)
        }
        .kiraSheet(
            isPresented: $isPicking, title: "onboarding.payday.sheet.title",
            subtitle: "onboarding.payday.sheet.subtitle", top: 300
        ) {
            PaydaySheet(payday: $payday, isPresented: $isPicking)
        }
    }
}

/** "Setiap Tanggal 25" or "Setiap Akhir Bulan". */
struct PaydayName: View {
    let payday: Payday

    var text: Text {
        if let day = payday.day { return Text("onboarding.payday.every \(day)") }
        return Text("onboarding.payday.endOfMonth")
    }

    var body: some View { text }
}
