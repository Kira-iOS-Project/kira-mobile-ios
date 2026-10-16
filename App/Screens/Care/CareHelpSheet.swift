/**
 PED-03, Layar Bantuan di Atas Chat (board SheetBantuan): the help over Catat's chat, which stays
 open behind it. No X: it closes with Kembali ke Chat, a swipe down, the scrim or VoiceOver's escape,
 and then `onClose` runs once (Catat offers the check-in). Hubungi Layanan Kira closes it and opens
 the message to Layanan Kira instead. Catat presents it with `.careHelpSheet(…)`.
 */
import Domain
import Features
import SwiftUI

extension View {
    /**
     Presents Kira Peduli's help over this view while `isPresented` is true. `onOpen` gets
     `.trustedMessage` from Hubungi Layanan Kira; `onClose` runs after any other way of closing.
     */
    func careHelpSheet(
        isPresented: Binding<Bool>, service: any CareService, onOpen: @escaping (AppRoute) -> Void,
        onClose: @escaping () -> Void
    ) -> some View {
        modifier(CareHelpPresenter(isPresented: isPresented, service: service, onOpen: onOpen, onClose: onClose))
    }
}

/** Shows the sheet and tells, once it is gone, which way it was left. */
private struct CareHelpPresenter: ViewModifier {
    @Binding var isPresented: Bool
    let service: any CareService
    let onOpen: (AppRoute) -> Void
    let onClose: () -> Void
    @State private var leavesForMessage = false

    func body(content: Content) -> some View {
        content
            .kiraSheet(isPresented: $isPresented, top: 226) {
                CareHelpSheet(service: service) {
                    isPresented = false
                } onMessage: {
                    leavesForMessage = true
                    isPresented = false
                }
            }
            .onChange(of: isPresented) { _, presented in
                guard !presented else { return }
                if leavesForMessage {
                    leavesForMessage = false
                    onOpen(.trustedMessage)
                } else {
                    onClose()
                }
            }
    }
}

/** The sheet's content: the heading, the contacts, Telepon 119 and Kembali ke Chat. */
struct CareHelpSheet: View {
    private let onBack: () -> Void
    private let onMessage: () -> Void
    @State private var model: CareContactsModel

    init(service: any CareService, onBack: @escaping () -> Void, onMessage: @escaping () -> Void) {
        self.onBack = onBack
        self.onMessage = onMessage
        _model = State(initialValue: CareContactsModel(service: service))
    }

    var body: some View {
        GeometryReader { panel in
            ScrollView {
                VStack(spacing: KiraSpacing.space4) {
                    heading
                    KiraListGroup { CareHealingRows(contact: model.contact(.healing119), isShort: true) }
                    CareKiraCard(contact: model.contact(.kiraCare), detail: "care.sheet.kira.detail", action: onMessage)
                    danger
                    Spacer(minLength: 0)
                    footer
                }
                .frame(minHeight: panel.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .task { await model.load() }
    }

    private var heading: some View {
        VStack(spacing: KiraSpacing.space2) {
            KiraIllustration(.care, size: 64)
            Text("care.sheet.title")
                .font(KiraFont.display(22, .heavy, relativeTo: .title2))
                .kiraLineHeight(28, size: 22, natural: 1.26, relativeTo: .title2)
                .tracking(-0.33)
                .foregroundStyle(.ink)
                .padding(.top, 2)
                .accessibilityAddTraits(.isHeader)
            Text("care.sheet.body")
                .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                .frame(maxWidth: 300)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
    }

    /** "Ada bahaya untuk dirimu sekarang?" over Telepon 119, under a line. */
    private var danger: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("care.sheet.emergency")
                .font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15).foregroundStyle(.ink)
                .padding(.horizontal, KiraSpacing.space1)
            CareEmergencyButton(contact: model.contact(.psc119))
        }
        .padding(.top, KiraSpacing.space4)
        .overlay(alignment: .top) { Rectangle().fill(.line).frame(height: 1) }
    }

    private var footer: some View {
        VStack(spacing: 2) {
            KiraButton("care.sheet.back", variant: .quiet, action: onBack)
            Text("care.disclaimer")
                .font(.caption).kiraLineHeight(16, size: 12).foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, KiraSpacing.space2)
    }
}

#Preview {
    Color.surface.ignoresSafeArea()
        .careHelpSheet(isPresented: .constant(true), service: PreviewCareService(), onOpen: { _ in }, onClose: {})
}
