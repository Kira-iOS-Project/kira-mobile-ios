/**
 Gallery pages for content, each section the artifact's preview of the component with its words:
 tags, notices, avatars and accordions; amounts (and the hero card they sit on); progress, steps
 and bars. A few more variants follow a preview where the component has them.
 */
#if DEBUG
    import SwiftUI

    struct GalleryLabels: View {
        var body: some View {
            GallerySection(title: "gallery.section.tag") {
                KiraFlowRow {
                    KiraTag("gallery.tag.verified", tone: .pandan, icon: .shield)
                    KiraTag("gallery.tag.soon", tone: .turmeric, icon: .clock)
                    KiraTag("gallery.tag.paid", tone: .healthy, icon: .check)
                    KiraTag("gallery.tag.overdue", tone: .vulnerable)
                    KiraTag("gallery.tag.simulationOnly")
                    KiraTag("gallery.tag.emergency", tone: .emergency)
                    KiraTag("gallery.tag.thisMonth", tone: .hero).padding(KiraSpacing.space2).background(.hero)
                }
            }
            GallerySection(title: "gallery.section.notice") {
                KiraNotice(
                    .simulation, title: "gallery.notice.simulation.title", message: "gallery.notice.simulation.body")
                KiraNotice(
                    .education, title: "gallery.notice.education.title", message: "gallery.notice.education.body")
                KiraNotice(.aiText, message: "gallery.notice.ai.body")
                KiraNotice(.privacy, message: "gallery.notice.privacy.body")
                KiraNotice(.warning, title: "gallery.notice.warning.title", message: "gallery.notice.warning.body")
                KiraNotice(.safe, title: "gallery.notice.safe.title")
                KiraNotice(message: "gallery.notice.info.body", icon: .clock)
            }
            GallerySection(title: "gallery.section.avatar") {
                HStack(spacing: 10) {
                    KiraAvatar("D", label: "gallery.avatar.label")
                    KiraAvatar("RA", tone: .green, label: "gallery.avatar.label")
                    KiraAvatar("MS", tone: .sky, label: "gallery.avatar.label")
                    KiraAvatar("T", size: 56, tone: .peach, label: "gallery.avatar.label")
                }
            }
            GallerySection(title: "gallery.section.accordion") {
                KiraAccordion(
                    "gallery.action.howCalculated", subtitle: "gallery.accordion.subtitle", icon: .calculator
                ) {
                    Text("gallery.accordion.body").font(.subheadline).foregroundStyle(.ink)
                    Text("gallery.type.formula")
                        .kiraFont(.formula)
                        .foregroundStyle(.ink)
                        .padding(.vertical, 10)
                        .padding(.horizontal, KiraSpacing.space3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .kiraCard(.surface, cornerRadius: KiraRadius.small)
                }
                .openByDefault()
                KiraAccordion("gallery.accordion.credit", subtitle: "gallery.accordion.credit.subtitle", icon: .info) {
                    Text("gallery.accordion.credit.body").font(.subheadline).foregroundStyle(.ink)
                }
                .soft()
            }
        }
    }

    struct GalleryAmounts: View {
        var body: some View {
            GallerySection(title: "gallery.section.amount") {
                KiraAmount(1_840_000, size: .large)
                KiraAmount(1_840_000, size: .large).masked()
                KiraFlowRow(spacing: KiraSpacing.space4) {
                    KiraAmount(48000)
                    KiraAmount(25000, size: .small)
                    KiraAmount(7_500_000, size: .small).signed().muted()
                }
                KiraAmount(1_840_000, size: .extraLarge).inverse()
                    .padding(.vertical, KiraSpacing.space3)
                    .padding(.horizontal, KiraSpacing.space5)
                    .background(.hero, in: RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
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

    #Preview { GalleryLabels().galleryPage() }
    #Preview { GalleryAmounts().galleryPage() }
#endif
