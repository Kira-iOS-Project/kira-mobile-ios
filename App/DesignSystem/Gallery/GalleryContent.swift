/**
 Gallery pages for content: tags, notices, avatars, accordions, amounts with the hero card, and the
 progress bars.
 */
#if DEBUG
    import SwiftUI

    struct GalleryLabels: View {
        var body: some View {
            GallerySection(title: "gallery.section.tag") {
                KiraFlowRow {
                    KiraTag("gallery.tag.verified", tone: .pandan, icon: .check)
                    KiraTag("gallery.tag.soon", tone: .turmeric)
                    KiraTag("gallery.tag.paid", tone: .healthy)
                    KiraTag("gallery.tag.overdue", tone: .vulnerable)
                    KiraTag("gallery.tag.fromGallery")
                    KiraTag("gallery.tag.emergency", tone: .emergency)
                    KiraTag("gallery.tag.thisMonth", tone: .hero).padding(KiraSpacing.space2).background(.hero)
                }
            }
            GallerySection(title: "gallery.section.notice") {
                KiraNotice(
                    .simulation, title: "gallery.notice.simulation.title", message: "gallery.notice.simulation.body")
                KiraNotice(
                    .education, title: "gallery.notice.education.title", message: "gallery.notice.education.body")
                KiraNotice(.aiText, title: "gallery.notice.ai.title", message: "gallery.notice.ai.body")
                KiraNotice(.privacy, title: "gallery.notice.privacy.title", message: "gallery.notice.privacy.body")
                KiraNotice(.safe, title: "gallery.notice.safe.title")
                KiraNotice(
                    .warning, title: "gallery.notice.warning.title", message: "gallery.notice.warning.body")
                KiraNotice(message: "gallery.notice.info.body", icon: .clock)
            }
            GallerySection(title: "gallery.section.avatar") {
                HStack(spacing: KiraSpacing.space3) {
                    KiraAvatar("D", label: "gallery.avatar.label")
                    KiraAvatar("AR", tone: .green, label: "gallery.avatar.label")
                    KiraAvatar("S", size: 32, tone: .sky, label: "gallery.avatar.label")
                    KiraAvatar("M", size: 52, tone: .peach, label: "gallery.avatar.label")
                }
            }
            GallerySection(title: "gallery.section.accordion") {
                KiraAccordion(
                    "gallery.action.howCalculated", subtitle: "gallery.accordion.subtitle", icon: .calculator
                ) {
                    Text("gallery.type.formula").kiraFont(.formula).foregroundStyle(.ink)
                    Text("gallery.accordion.body").font(.subheadline).foregroundStyle(.inkMuted)
                }
                KiraAccordion("gallery.accordion.legal", icon: .book) {
                    Text("gallery.accordion.legal.body").font(.subheadline).foregroundStyle(.inkMuted)
                }
                .soft()
            }
        }
    }

    struct GalleryAmounts: View {
        var body: some View {
            GallerySection(title: "gallery.section.amount") {
                KiraAmount(1_840_000, size: .extraLarge)
                KiraAmount(1_250_000, size: .large)
                KiraAmount(48000)
                KiraAmount(25000, size: .small).signed()
                KiraAmount(-48000, size: .small).signed()
                KiraAmount(Decimal(string: "10000.5") ?? 0).muted()
                KiraAmount(2_450_000, size: .large).masked()
            }
            GallerySection(title: "gallery.section.hero") { heroCard }
        }

        private var heroCard: some View {
            VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                Text("gallery.hero.label").font(.subheadline.weight(.semibold)).foregroundStyle(.onHeroMuted)
                KiraAmount(1_840_000, size: .extraLarge).inverse()
                KiraProgressRibbon(value: 75, target: 100, label: "gallery.hero.used").inverse()
                    .caption("gallery.hero.period")
                    .padding(.top, KiraSpacing.space3)
            }
            .padding(KiraSpacing.space5)
            .padding(.bottom, KiraSpacing.space5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(alignment: .bottom) { KiraScenery(tone: .hero, height: 70) }
            .background(alignment: .topTrailing) { KiraLeaf(.pandan, tone: .hero, size: 96) }
            .background(.hero)
            .clipShape(RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
        }
    }

    struct GalleryProgress: View {
        var body: some View {
            GallerySection(title: "gallery.section.ribbon") {
                KiraProgressRibbon(value: 1_200_000, target: 4_200_000, label: "ds.category.emergency")
                    .milestones([
                        .init(position: 300_000, label: "gallery.ribbon.week"),
                        .init(position: 1_400_000, label: "gallery.ribbon.month"),
                        .init(position: 4_200_000, label: "gallery.ribbon.goal"),
                    ])
                    .caption("gallery.ribbon.caption")
                KiraProgressRibbon(
                    value: 4, target: 6, label: "gallery.ribbon.plan", valueLabel: "gallery.ribbon.planValue"
                )
                .tone(.healthy)
            }
            GallerySection(title: "gallery.section.steps") {
                KiraStepProgress(current: 2, total: 6)
                KiraStepProgress(current: 5, total: 5)
            }
            GallerySection(title: "gallery.section.bars") {
                KiraBars(
                    "gallery.bars.label",
                    columns: [
                        .init(label: "gallery.bars.w1", value: 640_000),
                        .init(label: "gallery.bars.w2", value: 820_000),
                        .init(label: "gallery.bars.w3", value: 410_000),
                        .init(
                            label: "gallery.bars.w4", value: 530_000, isHighlighted: true, caption: "gallery.bars.now"),
                    ])
            }
        }
    }

    #Preview { GalleryLabels().galleryPage() }
    #Preview { GalleryAmounts().galleryPage() }
#endif
