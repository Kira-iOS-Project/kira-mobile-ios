/**
 ONB-01 Splash (board Splash.dc.html): the hero green with the twig in the top corner, the hills
 and the late sun, the leaf-bubble mark, the wordmark and the handwritten note. It shows while Kira
 starts and moves on by itself; no button, help or dock. The root fades it out, without motion
 under Reduce Motion.
 */
import SwiftUI

struct SplashView: View {
    var body: some View {
        GeometryReader { screen in
            ZStack(alignment: .topLeading) {
                Color.hero
                Circle().fill(.heroAccent).frame(width: 128, height: 128)
                    .position(x: screen.size.width * (222 + 64) / 393, y: screen.size.height - 96 - 64)
                KiraScenery(tone: .hero, height: 250)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                KiraLeaf(.twig, tone: .hero, size: 170).offset(x: -40, y: -20)
                VStack(spacing: 14) {
                    KiraLogo(.mark, tone: .hero, size: 104)
                    Text("splash.title")
                        .font(KiraFont.display(52, .heavy, relativeTo: .largeTitle))
                        .tracking(-0.035 * 52)
                        .kiraLineHeight(56, size: 52, natural: 1.26, relativeTo: .largeTitle)
                        .foregroundStyle(.onHero)
                        .accessibilityHidden(true)
                    KiraHandNote("splash.note", tone: .hero)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, screen.size.height * 262 / 852)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    SplashView()
}
