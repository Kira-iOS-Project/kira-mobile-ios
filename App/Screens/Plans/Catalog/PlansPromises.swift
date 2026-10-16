/**
 The lower half of Paket Kira: what is always free, Janji Kami, the Beasiswa Kira row, then Nanti
 Saja and Coba Kira Plus with how to pay.
 */
import Domain
import SwiftUI

struct PlansPromises: View {
    let onScholarship: () -> Void
    let onLater: () -> Void
    let onTry: () -> Void

    var body: some View {
        alwaysFree
        KiraListGroup("plans.promise.title") {
            KiraListRow(Text("plans.promise.cancel"), leading: .icon(.check))
                .subtitle(Text("plans.promise.cancel.detail"))
            KiraListRow(Text("plans.promise.reminder"), leading: .icon(.calendar))
                .subtitle(Text("plans.promise.reminder.detail"))
            KiraListRow(Text("plans.promise.price"), leading: .icon(.percent))
                .subtitle(Text("plans.promise.price.detail"))
        }
        KiraListGroup {
            KiraListRow(Text("plans.scholarship.row"), leading: .icon(.gift), action: onScholarship)
                .subtitle(Text("plans.scholarship.row.detail"))
        }
        .accessibilityLabel(Text("plans.scholarship.group"))
        VStack(spacing: KiraSpacing.space3) {
            KiraButtonPair(
                secondary: KiraButton("plans.later", variant: .secondary, action: onLater),
                primary: KiraButton("plans.tryPlus", action: onTry))
            Text("plans.payVia").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
        }
        .padding(.top, KiraSpacing.space1)
    }

    private var alwaysFree: some View {
        HStack(spacing: 14) {
            KiraIllustration(.care, size: 64)
                .clipShape(RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous))
                .hairline(cornerRadius: KiraRadius.medium)
            VStack(alignment: .leading, spacing: 2) {
                Text("plans.alwaysFree.title").font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("plans.alwaysFree.body").font(.subheadline).kiraLineHeight(20, size: 15)
                    .foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 16))
        .kiraCard(.pandanSoft, border: .pandanLine)
    }
}
