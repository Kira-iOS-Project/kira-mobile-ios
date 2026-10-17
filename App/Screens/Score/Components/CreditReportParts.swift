/**
 The parts of Cek SLIK (SKR-06): the header with its illustration, and the four steps in a hairline
 card, drawn as the debt guides draw theirs (DebtGuideSteps). The words are the content team's,
 static in the String Catalog.
 */
import SafariServices
import SwiftUI

/** The heading, its lead and the book illustration. */
struct CreditReportHeader: View {
    var body: some View {
        HStack(spacing: KiraSpacing.space3) {
            VStack(alignment: .leading, spacing: 6) {
                Text("creditReport.heading")
                    .font(KiraFont.display(24, .heavy, relativeTo: .title2))
                    .kiraLineHeight(30, size: 24, natural: 1.26, relativeTo: .title2)
                    .tracking(-0.48)
                    .foregroundStyle(.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text("creditReport.body").font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            KiraIllustration(.book, size: 80)
        }
        .padding(.vertical, 2)
    }
}

/** The four steps, each one element to VoiceOver: "1. Buka iDebKu OJK, …". */
struct CreditReportSteps: View {
    /** The 30 pt number disc grows with its number. */
    @ScaledMetric(relativeTo: .subheadline) private var disc: CGFloat = 30

    private static let steps: [(title: LocalizedStringResource, detail: LocalizedStringResource)] = [
        ("creditReport.step1", "creditReport.step1.detail"),
        ("creditReport.step2", "creditReport.step2.detail"),
        ("creditReport.step3", "creditReport.step3.detail"),
        ("creditReport.step4", "creditReport.step4.detail"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Self.steps.indices, id: \.self) { index in
                step(index)
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, KiraSpacing.space4)
        .kiraCard()
    }

    private func step(_ index: Int) -> some View {
        let isLast = index == Self.steps.count - 1
        let step = Self.steps[index]
        return HStack(alignment: .top, spacing: 14) {
            VStack(spacing: KiraSpacing.space1) {
                Text(index + 1, format: .number)
                    .font(KiraFont.display(14, .heavy, relativeTo: .subheadline))
                    .foregroundStyle(index == 0 ? Color.onPandan : .pandan)
                    .frame(width: disc, height: disc)
                    .background(index == 0 ? Color.pandan : .pandanSoft, in: Circle())
                    .overlay { Circle().strokeBorder(index == 0 ? Color.clear : .pandanLine, lineWidth: 1) }
                if !isLast {
                    Capsule().fill(.line).frame(width: 1.5).frame(maxHeight: .infinity)
                        .padding(.bottom, KiraSpacing.space1)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(step.title).font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16)
                    .foregroundStyle(.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(step.detail).font(.subheadline).kiraLineHeight(19, size: 14).foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, KiraSpacing.space1)
            .padding(.bottom, isLast ? 0 : KiraSpacing.space6)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("creditReport.step.spoken \(index + 1) \(Text(step.title)) \(Text(step.detail))"))
    }
}

/**
 The system browser over the screen. SFSafariViewController runs out of the app's process: Kira
 cannot read what is typed into iDebKu's form, nor its cookies, unlike a web view.
 */
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context _: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        let controller = SFSafariViewController(url: url, configuration: configuration)
        controller.dismissButtonStyle = .close
        return controller
    }

    func updateUIViewController(_: SFSafariViewController, context _: Context) {}
}
