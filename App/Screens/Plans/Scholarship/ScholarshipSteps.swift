/** The three numbered steps the Beasiswa Kira boards share (`ol`): done, current or to come. */
import Domain
import SwiftUI

struct ScholarshipStep {
    /** How far a step is. */
    enum Progress {
        case done, current, upcoming
    }

    let number: Int
    let title: LocalizedStringResource
    let detail: Text
    let state: Progress
}

struct ScholarshipSteps: View {
    let steps: [ScholarshipStep]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(steps, id: \.number) { step in
                HStack(alignment: .top, spacing: KiraSpacing.space3) {
                    marker(step)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.title).font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16)
                            .foregroundStyle(.ink)
                        step.detail.font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                    }
                    .padding(.top, 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(KiraSpacing.space4)
        .kiraCard()
    }

    @ViewBuilder private func marker(_ step: ScholarshipStep) -> some View {
        switch step.state {
        case .done:
            KiraIcon(.check, size: 16, weight: .bold).foregroundStyle(.onPandan)
                .frame(width: 28, height: 28).background(.pandan, in: Circle())
        case .current:
            number(step.number).foregroundStyle(.pandan)
                .background(.pandanSoft, in: Circle())
                .overlay { Circle().strokeBorder(.pandan, lineWidth: 2) }
        case .upcoming:
            number(step.number).foregroundStyle(.inkMuted)
                .background(.surfaceMuted, in: Circle())
                .overlay { Circle().strokeBorder(.hairline, lineWidth: 1) }
        }
    }

    private func number(_ value: Int) -> some View {
        Text(value, format: .number).font(KiraFont.display(14, .heavy, relativeTo: .footnote))
            .frame(width: 28, height: 28)
            .accessibilityHidden(true)
    }
}

extension ScholarshipApplication {
    /** "16 Oktober 2026 · 12.10 WIB": when the application was sent. */
    var sentAtText: Text {
        Text("scholarship.step.sent.at \(submittedAt, format: .plansFullDay) \(submittedAt, format: .plansTime)")
    }
}
