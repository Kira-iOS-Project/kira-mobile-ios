/**
 The frame every Akun screen shares (canvas Profil, Keamanan, Data & Privasi, Tentang Kira): the
 twig leaf behind the top right corner, the nav bar with an icon-only back button and, on the
 main screens, the help button, then the content 16 pt apart on the surface. The boards' 34 pt
 under the content is the home indicator's safe area, so nothing is added to it; the column is at
 least the screen's height, so a Spacer pins a document's actions to the bottom.
 */
import APIClient
import SwiftUI

/** A scrolling Akun screen with its nav bar. */
struct AccountPage<Content: View, Background: View>: View {
    private let title: LocalizedStringResource
    private let backLabel: LocalizedStringResource
    private var onHelp: (() -> Void)?
    private var leafSize: CGFloat = 140
    private let content: Content
    private let background: Background
    @Environment(\.dismiss) private var dismiss

    init(
        _ title: LocalizedStringResource, back backLabel: LocalizedStringResource,
        @ViewBuilder content: () -> Content, @ViewBuilder background: () -> Background
    ) {
        self.title = title
        self.backLabel = backLabel
        self.content = content()
        self.background = background()
    }

    var body: some View {
        GeometryReader { screen in
            ScrollView {
                VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                    KiraNavBar(title, leading: .back(backLabel) { dismiss() }) {
                        if let onHelp { KiraHelpButton(.icon, action: onHelp) }
                    }
                    content
                }
                .padding(.horizontal, KiraSpacing.screen)
                .padding(.top, KiraSpacing.space2)
                .background(alignment: .topTrailing) {
                    KiraLeaf(.twig, tone: .soft, size: leafSize, isFlipped: true).offset(x: 36, y: -22)
                }
                .frame(maxWidth: .infinity, minHeight: screen.size.height, alignment: .top)
            }
        }
        .background { background }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }

    /** The same screen with a larger leaf (Profil's is 150 pt). */
    func leaf(size: CGFloat) -> Self {
        var page = self
        page.leafSize = size
        return page
    }

    /** The same screen with the help button, which opens Kira Peduli. */
    func onHelp(_ action: @escaping () -> Void) -> Self {
        var page = self
        page.onHelp = action
        return page
    }
}

extension AccountPage where Background == EmptyView {
    init(
        _ title: LocalizedStringResource, back backLabel: LocalizedStringResource, @ViewBuilder content: () -> Content
    ) {
        self.init(title, back: backLabel, content: content) { EmptyView() }
    }
}

/** The centred art and words under the nav bar of Keamanan and Data & Privasi. */
struct AccountIntro: View {
    let illustration: KiraIllustrationName
    let title: LocalizedStringResource
    var message: LocalizedStringResource?

    var body: some View {
        VStack(spacing: 10) {
            KiraIllustration(illustration, size: 104)
            VStack(spacing: KiraSpacing.space1) {
                Text(title)
                    .font(KiraFont.display(20, .bold, relativeTo: .title3)).kiraLineHeight(
                        26, size: 20, natural: 1.26, relativeTo: .title3
                    )
                    .tracking(-0.2)
                    .accessibilityAddTraits(.isHeader)
                    .balancedLines()
                    .frame(maxWidth: 280)
                if let message {
                    Text(message).font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                        .balancedLines()
                        .frame(maxWidth: 300)
                }
            }
            .multilineTextAlignment(.center)
        }
        .padding(EdgeInsets(top: 4, leading: 24, bottom: 8, trailing: 24))
        .frame(maxWidth: .infinity)
    }
}

/** A screen whose account could not be loaded: the problem's message and Coba Lagi. */
struct AccountFailure: View {
    let problem: AppProblem
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            KiraNotice(.warning, title: "account.failure.title", message: problem.message)
            if problem.showsReference {
                Text("account.failure.reference \(problem.reference)")
                    .font(.footnote).foregroundStyle(.inkMuted)
            }
            KiraButton("account.retry", variant: .secondary, action: retry).block()
        }
    }
}

extension FormatStyle where Self == Date.FormatStyle {
    /** A day in full, as Kira writes it: "1 November 2026", on the WIB calendar. */
    static var accountDay: Date.FormatStyle {
        Date.FormatStyle(date: .long, time: .omitted, timeZone: .wib)
    }

    /** A day without its year, for the start of a range: "25 September". */
    static var accountDayMonth: Date.FormatStyle {
        Date.FormatStyle(timeZone: .wib).day().month(.wide)
    }
}

extension TimeZone {
    /** Western Indonesia Time, which every date of the API is in. */
    fileprivate static let wib = TimeZone(identifier: "Asia/Jakarta") ?? .current
}
