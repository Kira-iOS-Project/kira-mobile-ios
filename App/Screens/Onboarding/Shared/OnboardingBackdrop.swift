/**
 The backdrop every onboarding board draws behind its content: the surface, the nature scenery
 along the bottom edge and a soft leaf in one top corner, all under the status bar and behind the
 home indicator.
 */
import SwiftUI

/** A soft leaf in a top corner of an onboarding screen, as each board places it. */
struct OnboardingLeaf {
    let name: KiraLeaf.Name
    let size: CGFloat
    /** Distance from the top of the screen. */
    let top: CGFloat
    /** Whether it hangs from the right edge (flipped) rather than the left. */
    let isRight: Bool
    /** How far it reaches past its edge. */
    var overhang: CGFloat = 44

    /** The pandan leaf, 120 pt, 40 pt down and 44 pt past the left edge (Onboarding, Masuk). */
    static let pandan = Self(name: .pandan, size: 120, top: 40, isRight: false)
    /** The twig, flipped, 140 pt, 44 pt down, 40 pt past the right edge (Daftar, Kode Verifikasi). */
    static let twig = Self(name: .twig, size: 140, top: 44, isRight: true, overhang: 40)

    /**
     The twig at `size`, `top` down and `overhang` past the right edge (Onboarding 2: 140 at 40,
     40 past; Pilih Fokus 130 at 8 and Utang 130 at 150, both 46 past).
     */
    static func twig(size: CGFloat, top: CGFloat, overhang: CGFloat = 46) -> Self {
        Self(name: .twig, size: size, top: top, isRight: true, overhang: overhang)
    }
}

extension View {
    /**
     Lays the onboarding backdrop behind the screen: scenery of `sceneryHeight`, `leaf` if any, and
     with `showsMascot` Kuku on a branch 90 pt above the bottom edge, 14 pt past the right (the quiz).
     */
    func onboardingBackdrop(
        leaf: OnboardingLeaf? = nil, sceneryHeight: CGFloat = 150, showsMascot: Bool = false
    ) -> some View {
        background {
            ZStack(alignment: .top) {
                Color.surface
                VStack {
                    Spacer(minLength: 0)
                    /** The screen's width, as the scenery asks for 400 pt at 150 pt tall. */
                    KiraScenery(height: sceneryHeight).frame(minWidth: 0, maxWidth: .infinity)
                }
                if showsMascot {
                    KiraMascot(.calm, size: 132, isFramed: false)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .offset(x: 14, y: -90)
                }
                if let leaf {
                    KiraLeaf(leaf.name, tone: .soft, size: leaf.size, isFlipped: leaf.isRight)
                        .frame(maxWidth: .infinity, alignment: leaf.isRight ? .trailing : .leading)
                        .offset(x: leaf.isRight ? leaf.overhang : -leaf.overhang, y: leaf.top)
                }
            }
            .ignoresSafeArea()
            .accessibilityHidden(true)
        }
    }
}
