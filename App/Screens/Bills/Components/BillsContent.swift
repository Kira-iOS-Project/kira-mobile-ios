/**
 Tagihan & Cicilan's body (board Tagihan): the calendar illustration with the count, the monthly
 total and the Beranda note, then one group per due window, each row with its category, schedule,
 amount and tags.
 */
import Domain
import Features
import SwiftUI

struct BillsContent: View {
    let overview: BillOverview
    let model: BillsModel
    let open: (Bill) -> Void

    var body: some View {
        BillsSummary(count: overview.count, monthlyTotal: overview.monthlyTotal)
        ForEach(overview.sections, id: \.group) { section in
            KiraListGroup(
                section.group.title,
                footer: section.group == overview.instalmentNoteGroup ? "bills.instalment.footer" : nil
            ) {
                ForEach(section.bills) { bill in
                    KiraListRow(Text(bill.name), leading: .category(bill.kiraCategory), trailing: .automatic) {
                        open(bill)
                    } extra: {
                        BillTags(tag: model.tag(for: bill, in: section.group), isEstimate: bill.isEstimate)
                    }
                    .subtitle(Text(bill.schedule))
                    .amount(KiraAmount(bill.amount.rupiah))
                }
            }
        }
    }
}

/** "6 tagihan berulang", the monthly total "per bulan", and "Yang paling dekat tampil di Beranda". */
struct BillsSummary: View {
    let count: Int
    let monthlyTotal: Int

    var body: some View {
        HStack(spacing: KiraSpacing.space4) {
            KiraIllustration(.calendar, size: 84).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("bills.count \(count)").font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15)
                    .foregroundStyle(.inkMuted)
                KiraFlowRow(spacing: 6) {
                    KiraAmount(monthlyTotal.rupiah)
                    Text("bills.perMonth").font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                }
                Text("bills.homeNote").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
        }
        .padding(.vertical, KiraSpacing.space1)
        .padding(.trailing, KiraSpacing.space1)
        .accessibilityElement(children: .combine)
    }
}

/** A row's tags: when it is due or that it is paid, and "Perkiraan" for an estimated amount. */
private struct BillTags: View {
    let tag: BillTag
    let isEstimate: Bool

    var body: some View {
        KiraFlowRow(spacing: 6) {
            switch tag {
            case .daysLeft(let days, let urgent):
                KiraTag("bills.tag.days \(days)", tone: urgent ? .turmeric : .neutral, icon: .clock)
            case .date(let day):
                KiraTag("bills.tag.date \(BillCopy.date(day))", icon: .calendar)
            case .paid(let month):
                KiraTag("bills.tag.paid \(BillCopy.month(month))", tone: .healthy, icon: .check)
            }
            if isEstimate { KiraTag("bills.tag.estimate") }
        }
    }
}
