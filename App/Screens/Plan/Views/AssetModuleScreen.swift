/**
 Modul Belajar (REN-08, board ModulKelasAset): one asset class's module, part by part. The nav bar
 with Kira Peduli, "Bagian N dari 4", the class's tile, name, risk Tag and reading time, the
 sections in one card, the education notice, and Bagian Berikutnya (Selesai on the last part,
 which closes the module). Cek Legalitas opens REN-09 through `onOpen`.
 */
import Domain
import Features
import SwiftUI

struct AssetModuleScreen: View {
    @State private var model: AssetModuleModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(assetClass: AssetClass, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: AssetModuleModel(assetClass: assetClass))
        self.onOpen = onOpen
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(
                    "plan.module.title", subtitle: "plan.module.subtitle",
                    leading: .back("plan.module.back") { dismiss() }
                ) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                KiraStepProgress(
                    current: model.part.number, total: AssetModulePart.total,
                    label: "plan.module.progress \(model.part.number) \(AssetModulePart.total)")
                header
                article
                KiraNotice(.education, title: "plan.module.notice.title", message: "plan.module.notice.message")
                button.padding(.top, KiraSpacing.space1)
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.bottom, KiraSpacing.space6)
            .frame(maxWidth: .infinity, alignment: .top)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 136, isFlipped: true)
                    .offset(x: 40, y: -38)
                    .accessibilityHidden(true)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        let tag = model.assetClass.risk.moduleTag
        return VStack(alignment: .leading, spacing: 10) {
            KiraCategoryIcon(model.assetClass.moduleCategory, size: 52)
            Text(model.assetClass.moduleTitle)
                .font(KiraFont.display(28, .heavy, relativeTo: .largeTitle))
                .kiraLineHeight(34, size: 28, natural: 1.26, relativeTo: .largeTitle)
                .tracking(-0.7)
                .foregroundStyle(.ink)
                .accessibilityAddTraits(.isHeader)
            KiraFlowRow(spacing: KiraSpacing.space2) {
                KiraTag(tag.title, tone: tag.tone)
                Label {
                    Text("plan.module.readTime")
                } icon: {
                    KiraIcon(.clock, size: 14)
                }
                .labelStyle(AssetModuleReadTimeStyle())
            }
        }
        .padding(.top, 6)
        .padding(.horizontal, KiraSpacing.space1)
    }

    private var article: some View {
        VStack(alignment: .leading, spacing: 0) {
            let sections = model.assetClass.moduleSections(model.part)
            ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                AssetModuleSectionView(section: section) { onOpen(.legalityCheck) }
                    .padding(.vertical, KiraSpacing.space4)
                    .overlay(alignment: .top) { if index > 0 { Rectangle().fill(.line).frame(height: 1) } }
            }
        }
        .padding(.horizontal, KiraSpacing.space5)
        .padding(.vertical, KiraSpacing.space1)
        .kiraCard(.surfaceRaised, border: .hairline, cornerRadius: KiraRadius.large)
        .id(model.part)
    }

    private var button: some View {
        KiraButton(model.isLastPart ? "plan.module.finish" : "plan.module.next") {
            if !model.advance() { dismiss() }
        }
        .iconEnd(model.isLastPart ? .check : .arrowRight)
        .block()
    }
}

/** One section of the card: its title, then a paragraph or a checked list, and Cek Legalitas. */
private struct AssetModuleSectionView: View {
    let section: AssetModuleSection
    let onCheckLegality: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: section.items.isEmpty ? 6 : KiraSpacing.space2) {
            KiraSectionTitle(section.title, showsLeaf: false)
            if let body = section.body {
                Text(body).font(.body).kiraLineHeight(23, size: 16).foregroundStyle(.ink)
                    .padding(.horizontal, KiraSpacing.space1)
            }
            ForEach(Array(section.items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 10) {
                    KiraIcon(.check, size: 13, weight: .heavy)
                        .foregroundStyle(.healthy)
                        .frame(width: 22, height: 22)
                        .background(.healthySoft, in: Circle())
                        .overlay { Circle().strokeBorder(.healthyLine, lineWidth: 1) }
                        .padding(.top, 1)
                        .accessibilityHidden(true)
                    Text(item).font(.body).kiraLineHeight(23, size: 16).foregroundStyle(.ink)
                }
                .padding(.horizontal, KiraSpacing.space1)
            }
            if section.checksLegality {
                Button(action: onCheckLegality) {
                    HStack(spacing: 6) {
                        KiraIcon(.shield, size: 17)
                        Text("plan.module.checkLegality")
                        KiraIcon(.arrowRight, size: 16, weight: .semibold)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.pandan)
                    .padding(.horizontal, KiraSpacing.space1)
                    .frame(minHeight: KiraSize.tap)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.top, -2)
                .padding(.bottom, -8)
            }
        }
    }
}

/** "3 menit baca": a 14 pt clock, then the muted 13 pt words. */
private struct AssetModuleReadTimeStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            configuration.icon
            configuration.title
        }
        .font(.footnote.weight(.medium))
        .kiraLineHeight(18, size: 13)
        .foregroundStyle(.inkMuted)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack { AssetModuleScreen(assetClass: .moneyMarketFund) { _ in } }
}
