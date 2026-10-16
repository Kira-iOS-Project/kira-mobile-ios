/**
 Gallery page for progress, each section the artifact's preview of the component with its words:
 the progress ribbon (on the screen and on the hero card), the step bar and the bars.
 */
#if DEBUG
    import SwiftUI

    struct GalleryProgress: View {
        var body: some View {
            GallerySection(title: "gallery.section.ribbon") {
                KiraProgressRibbon(value: 4_800_000, target: 12_600_000, label: "gallery.ribbon.fund")
                    .milestones([
                        .init(position: 1_050_000, label: "gallery.ribbon.week"),
                        .init(position: 4_200_000, label: "gallery.ribbon.month"),
                        .init(position: 8_400_000, label: "gallery.ribbon.twoMonths"),
                        .init(position: 12_600_000, label: "gallery.ribbon.threeMonths"),
                    ])
                    .caption("gallery.ribbon.caption")
                KiraProgressRibbon(
                    value: 5_660_000, target: 7_500_000, label: "gallery.ribbon.used",
                    valueLabel: "gallery.ribbon.usedValue"
                )
                .inverse()
                .padding(KiraSpacing.space5)
                .background(.hero, in: RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
                KiraProgressRibbon(
                    value: 4, target: 6, label: "gallery.ribbon.plan", valueLabel: "gallery.ribbon.planValue"
                )
                .tone(.healthy)
            }
            GallerySection(title: "gallery.section.steps") {
                KiraStepProgress(current: 2, total: 6, label: "gallery.steps.question")
                KiraStepProgress(current: 5, total: 5)
            }
            GallerySection(title: "gallery.section.bars") {
                KiraBars(
                    "gallery.bars.label",
                    columns: [
                        .init(label: "gallery.bars.thu", value: 180_000),
                        .init(label: "gallery.bars.fri", value: 240_000),
                        .init(label: "gallery.bars.sat", value: 410_000),
                        .init(label: "gallery.bars.sun", value: 320_000),
                        .init(label: "gallery.bars.mon", value: 95000),
                        .init(label: "gallery.bars.tue", value: 150_000),
                        .init(
                            label: "gallery.bars.wed", value: 210_000, isHighlighted: true,
                            caption: "gallery.bars.now"),
                    ])
            }
        }
    }

    #Preview { GalleryProgress().galleryPage() }
#endif
