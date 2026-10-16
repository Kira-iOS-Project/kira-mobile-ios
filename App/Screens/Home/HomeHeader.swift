/**
 Beranda's header: today's date in full and the avatar (Profil), then the greeting by the WIB time
 of day ("Sore, Dinda"; "Halo, Dinda" before the first transaction) and the help pill.
 */
import Domain
import Features
import SwiftUI

struct HomeHeader: View {
    let home: HomeOverview
    let dayPart: DayPart
    let onOpen: (AppRoute) -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(home.today, format: .kiraWeekdayDate)
                    .font(.footnote.weight(.medium)).kiraLineHeight(18, size: 13)
                    .foregroundStyle(.inkMuted)
                Spacer(minLength: KiraSpacing.space2)
                Button {
                    onOpen(.profile)
                } label: {
                    KiraAvatar(home.initial, size: 34, tone: home.variant == .debtPlan ? .sky : .turmeric)
                        .frame(minWidth: KiraSize.tap, minHeight: KiraSize.tap)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("home.profile \(home.displayName)"))
                .padding(.trailing, -4)
            }
            .frame(minHeight: KiraSize.tap)
            if typeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                    greeting
                    help
                }
            } else {
                HStack(spacing: KiraSpacing.space3) {
                    greeting
                    Spacer(minLength: 0)
                    help
                }
            }
        }
    }

    private var greeting: some View {
        /** BRD-03's board sets its greeting 2 pt smaller, so a longer name keeps one line. */
        let size: CGFloat = home.variant == .debtPlan ? 24 : 26
        return
            greetingText
            .font(KiraFont.display(size, .heavy, relativeTo: .title))
            .kiraLineHeight(32, size: size, natural: 1.26, relativeTo: .title)
            .tracking(-0.02 * size)
            .foregroundStyle(.ink)
            .accessibilityAddTraits(.isHeader)
    }

    private var greetingText: Text {
        guard home.variant != .firstSteps else { return Text("home.greeting.hello \(home.displayName)") }
        switch dayPart {
        case .morning: return Text("home.greeting.morning \(home.displayName)")
        case .midday: return Text("home.greeting.midday \(home.displayName)")
        case .afternoon: return Text("home.greeting.afternoon \(home.displayName)")
        case .night: return Text("home.greeting.night \(home.displayName)")
        }
    }

    private var help: some View {
        KiraHelpButton { onOpen(.unavailable(.care)) }.fixedSize()
    }
}
