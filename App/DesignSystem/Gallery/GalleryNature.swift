/**
 Gallery page for nature and handwriting: the leaves in their three tones, the sceneries, and the
 handwritten note's tones, sizes and arrows.
 */
#if DEBUG
    import SwiftUI

    struct GalleryNature: View {
        var body: some View {
            GallerySection(title: "gallery.section.leaves") {
                ForEach(KiraLeaf.Tone.allCases, id: \.self) { tone in
                    HStack(spacing: KiraSpacing.space4) {
                        ForEach(KiraLeaf.Name.allCases, id: \.self) { name in
                            KiraLeaf(name, tone: tone, size: 64)
                        }
                        KiraLeaf(.twig, tone: tone, size: 64, isFlipped: true)
                    }
                    .padding(KiraSpacing.space2)
                    .kiraCard(tone == .hero ? .hero : .surfaceRaised, cornerRadius: KiraRadius.medium)
                }
            }
            GallerySection(title: "gallery.section.scenery") {
                KiraScenery(hasSun: true, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous))
                KiraScenery(height: 90)
                KiraScenery(tone: .hero, height: 90).background(.hero)
            }
            GallerySection(title: "gallery.section.hand") {
                KiraHandNote("gallery.hand.slow")
                KiraHandNote("gallery.hand.growing", tone: .coping, size: .small)
                KiraHandNote("gallery.hand.start", tone: .muted, tilt: 0)
                KiraHandNote("gallery.hand.slow", tone: .hero)
                    .padding(KiraSpacing.space4)
                    .kiraCard(.hero, cornerRadius: KiraRadius.medium)
                ForEach(KiraHandNote.Arrow.allCases.filter { $0 != .none }, id: \.self) { arrow in
                    KiraHandNote("gallery.hand.start", size: .small, arrow: arrow)
                }
            }
        }
    }

    #Preview { GalleryNature().galleryPage() }
#endif
