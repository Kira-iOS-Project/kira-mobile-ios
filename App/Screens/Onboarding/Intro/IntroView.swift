/**
 The three intro pages (ONB-02 to ONB-04): Kuku says hello, recording by chat, and the Kira
 Score. A swipe or "Lanjut" turns the page; "Lewati" (not on the last page) and "Mulai Pakai Kira"
 open Buat Akun, "Aku Sudah Punya Akun" opens Masuk. No help button before sign-up.
 */
import Features
import SwiftUI

struct IntroView: View {
    let flow: OnboardingFlowModel
    @State private var page = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let pageCount = 3

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, KiraSpacing.screen)
                .padding(.top, KiraSpacing.space1)
            TabView(selection: $page) {
                IntroPage { IntroWelcome() }.tag(0)
                IntroPage { IntroChat() }.tag(1)
                IntroPage { IntroScore() }.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            VStack(spacing: KiraSpacing.space2) {
                KiraButton(isLast ? "onboarding.intro.start" : "onboarding.intro.next") { advance() }.block()
                KiraButton("onboarding.intro.haveAccount", variant: .secondary) { flow.open(.signIn) }.block()
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.bottom, KiraSpacing.space2)
        }
        .onboardingBackdrop(leaf: page == 1 ? .twig : .pandan)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var isLast: Bool { page == pageCount - 1 }

    private var header: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? Color.pandan : Color.track)
                        .frame(width: index == page ? 22 : 8, height: 8)
                }
            }
            .padding(.leading, KiraSpacing.space1)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("onboarding.intro.progress \(page + 1) \(pageCount)"))
            Spacer()
            if isLast {
                Color.clear.frame(width: KiraSize.tap, height: KiraSize.tap)
            } else {
                KiraButton("onboarding.intro.skip", variant: .quiet, size: .small) { flow.open(.signUp) }
            }
        }
        .frame(minHeight: KiraSize.tap)
    }

    private func advance() {
        if isLast {
            flow.open(.signUp)
        } else {
            withAnimation(reduceMotion ? nil : .easeInOut) { page += 1 }
        }
    }
}

/** One intro page: its content centred in the space between the header and the buttons. */
private struct IntroPage<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                content()
                    .padding(.horizontal, KiraSpacing.screen)
                    .padding(.bottom, KiraSpacing.space3)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}
