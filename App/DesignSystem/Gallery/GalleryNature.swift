/**
 Gallery page for nature and handwriting: the leaves in their three tones, the sceneries, and the
 handwritten note's tones, sizes and arrows.
 */
#if DEBUG
    import SwiftUI

    struct GalleryNature: View {
        var body: some View {
            GallerySection(title: "gallery.section.leaves") {
                KiraFlowRow(spacing: 20) {
                    KiraLeaf(.twig)
                    KiraLeaf(.twig, tone: .soft, isFlipped: true)
                    KiraLeaf(.pandan, size: 96)
                    KiraLeaf(.pandan, tone: .hero, size: 90)
                        .frame(width: 96, height: 96, alignment: .bottomTrailing)
                        .background(.hero)
                        .clipShape(RoundedRectangle(cornerRadius: KiraRadius.large, style: .continuous))
                    HStack(spacing: 6) {
                        KiraLeaf(.single)
                        Text("gallery.leaf.sectionTitle").font(.headline).foregroundStyle(.ink)
                    }
                }
            }
            GallerySection(title: "gallery.section.scenery") {
                KiraScenery(hasSun: true, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: KiraRadius.large, style: .continuous))
                    .hairline(cornerRadius: KiraRadius.large)
                KiraScenery(tone: .hero, height: 90)
                    .frame(height: 120, alignment: .bottom)
                    .background(.hero)
                    .clipShape(RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
                KiraScenery(height: 90)
            }
            GallerySection(title: "gallery.section.hand") {
                KiraSectionTitle("gallery.list.nextStep", trailing: .note("gallery.hand.start"))
                KiraHandNote("gallery.hand.growing", tone: .coping, size: .small, tilt: -1)
                KiraHandNote("gallery.hand.slow", tone: .hero)
                    .padding(.vertical, KiraSpacing.space3)
                    .padding(.horizontal, KiraSpacing.space4)
                    .background(.hero, in: RoundedRectangle(cornerRadius: KiraRadius.large, style: .continuous))
                KiraHandNote("gallery.hand.start", tone: .muted, tilt: 0)
                ForEach(KiraHandNote.Arrow.allCases.filter { $0 != .none }, id: \.self) { arrow in
                    KiraHandNote("gallery.hand.start", size: .small, arrow: arrow)
                }
            }
        }
    }

    #Preview { GalleryNature().galleryPage() }
#endif
