/**
 SKR-06, Panduan SLIK (board PanduanSLIK, "Cek SLIK"): what SLIK is, the four steps to request the
 iDeb from OJK, the privacy notice and the warning about paid services, then Buka iDebKu OJK, which
 opens OJK's own site (idebku.ojk.go.id) in the browser. Static copy; Kira sends nothing.
 */
import Features
import SwiftUI

struct CreditReportGuideScreen: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    /** OJK's official iDeb service: the only link the board draws. */
    static let officialURL = URL(string: "https://idebku.ojk.go.id")

    init(onOpen: @escaping (AppRoute) -> Void) {
        self.onOpen = onOpen
    }

    var body: some View {
        GeometryReader { screen in
            ScrollView {
                VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                    KiraNavBar("slik.title", subtitle: "slik.subtitle", leading: .back("slik.back") { dismiss() }) {
                        KiraHelpButton(.icon) { onOpen(.care) }
                    }
                    header
                    KiraSectionTitle("slik.steps", trailing: .note("slik.steps.note")).padding(.top, KiraSpacing.space1)
                    CreditReportSteps()
                    KiraNotice(.privacy, message: "slik.privacy")
                    KiraNotice(.warning, title: "slik.warning.title", message: "slik.warning")
                    Spacer(minLength: 0)
                    KiraButton("slik.open") { if let url = Self.officialURL { openURL(url) } }
                        .iconEnd(.external).block()
                        .accessibilityHint(Text("slik.open.hint"))
                }
                .padding(.horizontal, KiraSpacing.screen)
                .padding(.vertical, KiraSpacing.space2)
                .frame(maxWidth: .infinity, minHeight: screen.size.height, alignment: .top)
                .background(alignment: .topTrailing) {
                    KiraLeaf(.twig, tone: .soft, size: 130, isFlipped: true).offset(x: 38, y: -28)
                        .accessibilityHidden(true)
                }
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            KiraIllustration(.shield, size: 96)
            Text("slik.headline")
                .font(KiraFont.display(28, axisWeight: 750, relativeTo: .largeTitle, typeSize: typeSize))
                .kiraLineHeight(34, size: 28, natural: 1.26, relativeTo: .largeTitle)
                .tracking(-0.56).foregroundStyle(.ink)
                .accessibilityAddTraits(.isHeader)
            Text("slik.lead").font(.body).kiraLineHeight(24, size: 17).foregroundStyle(.inkMuted)
        }
        .padding(KiraSpacing.space1)
    }
}

/** Cara Ceknya: the four steps, numbered, the first one filled, joined by a line. */
private struct CreditReportSteps: View {
    private let steps: [(LocalizedStringResource, LocalizedStringResource)] = [
        ("slik.step1", "slik.step1.detail"), ("slik.step2", "slik.step2.detail"),
        ("slik.step3", "slik.step3.detail"), ("slik.step4", "slik.step4.detail"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 14) {
                    number(index + 1)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.0).font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16).foregroundStyle(.ink)
                        Text(step.1).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                    }
                    .padding(.top, 3)
                }
                .padding(.vertical, 12)
                .accessibilityElement(children: .combine)
            }
        }
        .padding(.horizontal, KiraSpacing.space4)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
    }

    private func number(_ step: Int) -> some View {
        Text(step, format: .number)
            .font(KiraFont.display(13, .heavy, relativeTo: .footnote))
            .foregroundStyle(step == 1 ? Color.onPandan : Color.pandan)
            .frame(width: 28, height: 28)
            .background(step == 1 ? Color.pandan : Color.pandanSoft, in: Circle())
            .overlay { Circle().strokeBorder(step == 1 ? Color.clear : Color.pandanLine, lineWidth: 1) }
            .accessibilityHidden(true)
    }
}
