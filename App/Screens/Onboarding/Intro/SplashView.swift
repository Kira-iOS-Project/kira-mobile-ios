/**
 Splash (ONB-01): the hero-green opening while the app loads: the leaf-bubble mark, the Kira
 wordmark, the note "pelan-pelan, uangmu tumbuh", hills and the evening sun. No button: the root
 moves on by itself once it knows whether a session exists (new person to the intro, a locked
 account to Buka Kunci).
 */
import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack(spacing: 14) {
            KiraLogo(.mark, tone: .hero, size: 104)
            Text("onboarding.splash.name")
                .font(KiraFont.display(52, .heavy, relativeTo: .largeTitle))
                .kiraLineHeight(56, size: 52, natural: 1.26, relativeTo: .largeTitle)
                .tracking(-1.82)
                .accessibilityHidden(true)
            KiraHandNote("onboarding.splash.note", tone: .hero)
        }
        .foregroundStyle(.onHero)
        .padding(.top, 262 - 59)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background { backdrop }
    }

    private var backdrop: some View {
        ZStack(alignment: .bottomLeading) {
            Color.hero
            Circle().fill(.heroAccent).frame(width: 128, height: 128).offset(x: 222, y: -96)
            /** Its own width, as the scenery at 250 pt asks for 655 pt and would push the sun aside. */
            KiraScenery(tone: .hero, height: 250).frame(minWidth: 0, maxWidth: .infinity)
            KiraLeaf(.twig, tone: .hero, size: 170)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .offset(x: -40, y: -20)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

#Preview { SplashView() }
