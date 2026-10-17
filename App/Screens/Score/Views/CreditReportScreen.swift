/**
 Cek SLIK (SKR-06, board PanduanSLIK): four steps to one's own credit record at iDebKu OJK, free;
 the promise that Kira never asks for, stores or reads SLIK data; a warning about paid check
 services; and Buka iDebKu OJK, which opens OJK's site in the system browser (SFSafariViewController,
 never a web view). Reached from UNG-03's Panduan SLIK card through `AppRoute.creditReport`.
 */
import Features
import SwiftUI

struct CreditReportScreen: View {
    @State private var model = CreditReportModel()
    let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(
                    "creditReport.title", subtitle: "creditReport.subtitle",
                    leading: .back("creditReport.back") { dismiss() }
                ) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                CreditReportHeader()
                VStack(alignment: .leading, spacing: 10) {
                    KiraSectionTitle("creditReport.steps", trailing: .note("creditReport.steps.note"))
                    CreditReportSteps()
                }
                KiraNotice(.privacy, title: "creditReport.privacy.title", message: "creditReport.privacy.body")
                KiraNotice(.warning, title: "creditReport.paid.title", message: "creditReport.paid.body")
                action
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, 62 - 59)
            .padding(.bottom, KiraSpacing.space8)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 130, isFlipped: true).offset(x: 38, y: 34 - 59)
                    .accessibilityHidden(true)
            }
        }
        .kiraScrollEdges()
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: siteBinding) {
            if let site = model.presentedSite { SafariView(url: site).ignoresSafeArea() }
        }
    }

    /** The static guide is always loaded; without a site it keeps its steps and drops the button. */
    @ViewBuilder private var action: some View {
        switch model.phase {
        case .loaded:
            VStack(spacing: KiraSpacing.space2) {
                KiraButton("creditReport.open") { model.openSite() }.iconEnd(.external).block()
                Text("creditReport.outbound")
                    .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, KiraSpacing.space2)
        case .loading, .empty, .failed:
            EmptyView()
        }
    }

    private var siteBinding: Binding<Bool> {
        Binding(get: { model.presentedSite != nil }, set: { if !$0 { model.closeSite() } })
    }
}

#Preview {
    NavigationStack { CreditReportScreen { _ in } }
}
