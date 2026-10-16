/** The content of the three intro pages, each as its board lays it out. */
import SwiftUI

/** Onboarding 1 · Kenalan: Kuku, happy, 248 pt. */
struct IntroWelcome: View {
    var body: some View {
        IntroCopy(overline: "onboarding.intro.welcome.overline", title: "onboarding.intro.welcome.title",
            lead: "onboarding.intro.welcome.lead") {
            KiraMascot(.happy, size: 248)
            KiraHandNote("onboarding.intro.welcome.note")
        }
    }
}

/** Onboarding 2 · Catat: a static example chat, read into two records (not an AI call). */
struct IntroChat: View {
    var body: some View {
        IntroCopy(overline: "onboarding.intro.chat.overline", title: "onboarding.intro.chat.title",
            lead: "onboarding.intro.chat.lead") {
            VStack(spacing: KiraSpacing.space3) {
                Text("onboarding.intro.chat.time")
                    .font(.caption.weight(.semibold)).kiraLineHeight(16, size: 12).foregroundStyle(.inkMuted)
                KiraChatBubble(.user, initial: "D") { Text("onboarding.intro.chat.message") }
                KiraChatBubble(.kira, meta: "onboarding.intro.chat.meta") { Text("onboarding.intro.chat.reply") }
                    .saved([
                        KiraSavedTransaction(
                            label: Text("onboarding.intro.chat.coffee"), amount: 5000, category: .coffee,
                            categoryName: Text("onboarding.intro.chat.foodAndDrink")),
                        KiraSavedTransaction(
                            label: Text("onboarding.intro.chat.fuel"), amount: 30000, category: .transport,
                            categoryName: Text(KiraCategory.transport.title)),
                    ])
            }
            .padding(EdgeInsets(top: 14, leading: 12, bottom: 12, trailing: 12))
            .kiraCard(.surfaceMuted, border: .hairline, cornerRadius: KiraRadius.extraLarge)
            KiraHandNote("onboarding.intro.chat.note")
        }
    }
}

/** Onboarding 3 · Tumbuh: Kuku, calm, 232 pt, and two promises. */
struct IntroScore: View {
    var body: some View {
        IntroCopy(overline: "onboarding.intro.score.overline", title: "onboarding.intro.score.title",
            lead: "onboarding.intro.score.lead") {
            KiraMascot(.calm, size: 232)
            KiraHandNote("onboarding.intro.score.note")
        } footer: {
            HStack(spacing: KiraSpacing.space2) {
                IntroPromise(icon: .lock, text: "onboarding.intro.score.private")
                IntroPromise(icon: .heart, text: "onboarding.intro.score.care")
            }
            .padding(.top, 6)
        }
    }
}

/** The art of a page, then its overline, heading and lead, centred. */
private struct IntroCopy<Art: View, Footer: View>: View {
    let overline: LocalizedStringResource
    let title: LocalizedStringResource
    let lead: LocalizedStringResource
    @ViewBuilder let art: () -> Art
    @ViewBuilder var footer: () -> Footer

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 6) { art() }
            VStack(spacing: 10) {
                Text(overline).onboardingOverline()
                OnboardingHeading(text: title)
                Text(lead).onboardingLead().frame(maxWidth: 320)
                footer()
            }
            .multilineTextAlignment(.center)
        }
    }
}

extension IntroCopy where Footer == EmptyView {
    init(
        overline: LocalizedStringResource, title: LocalizedStringResource, lead: LocalizedStringResource,
        @ViewBuilder art: @escaping () -> Art
    ) {
        self.init(overline: overline, title: title, lead: lead, art: art) { EmptyView() }
    }
}

/** A promise pill: a pandan icon and a short line on a hairline capsule. */
private struct IntroPromise: View {
    let icon: KiraIconName
    let text: LocalizedStringResource

    var body: some View {
        HStack(spacing: 6) {
            KiraIcon(icon, size: 16).foregroundStyle(.pandan)
            Text(text).font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.ink)
        }
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 12))
        .kiraCard(.surfaceRaised, border: .hairline, cornerRadius: KiraRadius.full)
    }
}
