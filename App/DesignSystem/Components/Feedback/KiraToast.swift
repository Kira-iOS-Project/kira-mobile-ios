/**
 Toast (design system): a short line that confirms or refuses a small action, such as a copy, and
 goes by itself after 2.5 s. It sits at the bottom, above the home indicator, on its own window
 over every sheet and dialog, and never takes a touch; VoiceOver reads it as an announcement.
 Success is pandan with a tick, failure the vulnerable tone with an alert sign. No shadow: a
 hairline border, as every Kira surface.
 */
import SwiftUI
import UIKit

/** One toast: its tone and its sentence. */
struct KiraToast: Equatable, Identifiable {
    enum Tone: Equatable {
        case success, failure
    }

    let id = UUID()
    let tone: Tone
    let message: LocalizedStringResource

    static func == (lhs: KiraToast, rhs: KiraToast) -> Bool { lhs.id == rhs.id }
}

/** Shows one toast at a time over the whole app; a new one replaces the one on screen. */
@MainActor @Observable
final class KiraToastCenter {
    /** The app's one center. */
    static let shared = KiraToastCenter()

    /** How long a toast stays. */
    static let duration = Duration.milliseconds(2_500)

    private(set) var current: KiraToast?
    @ObservationIgnored private var window: UIWindow?

    /** Shows `toast` and announces it to VoiceOver. */
    func show(_ toast: KiraToast) {
        attach()
        current = toast
        UIAccessibility.post(notification: .announcement, argument: String(localized: toast.message))
    }

    /** Takes `toast` down, unless a newer one replaced it. */
    func dismiss(_ toast: KiraToast) {
        if current == toast { current = nil }
    }

    /** The toast's window, above the app's, made once for the active scene. */
    private func attach() {
        guard window == nil,
            let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
        else { return }
        let host = UIHostingController(rootView: KiraToastLayer(center: self))
        host.view.backgroundColor = .clear
        let overlay = UIWindow(windowScene: scene)
        overlay.rootViewController = host
        overlay.windowLevel = .alert + 1
        overlay.isUserInteractionEnabled = false
        overlay.isHidden = false
        window = overlay
    }
}

/** The window's content: the current toast, bottom centred, sliding in and out. */
private struct KiraToastLayer: View {
    let center: KiraToastCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack {
            Spacer()
            if let toast = center.current {
                KiraToastView(toast: toast)
                    .padding(.horizontal, KiraSpacing.screen)
                    .padding(.bottom, KiraSpacing.space4)
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                    .task(id: toast.id) {
                        try? await Task.sleep(for: KiraToastCenter.duration)
                        center.dismiss(toast)
                    }
            }
        }
        .animation(.snappy(duration: 0.25), value: center.current)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/** One toast drawn: the tone's icon in its circle and the sentence. */
struct KiraToastView: View {
    let toast: KiraToast

    var body: some View {
        HStack(spacing: KiraSpacing.space3) {
            KiraIcon(toast.tone == .success ? .check : .alert, size: 15, weight: .bold)
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(toast.tone == .success ? Color.pandan : Color.vulnerable, in: Circle())
            Text(toast.message)
                .font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15)
                .foregroundStyle(.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .kiraCard(cornerRadius: KiraRadius.medium)
        .accessibilityHidden(true)
    }
}

/** Copies text and says how it went, with a toast. */
@MainActor
enum KiraClipboard {
    /** Puts `text` on the clipboard, then shows `copied`, or `failed` when the clipboard did not take it. */
    static func copy(
        _ text: String, copied: LocalizedStringResource, failed: LocalizedStringResource = "ds.copy.failed"
    ) {
        UIPasteboard.general.string = text
        let taken = UIPasteboard.general.string == text
        KiraToastCenter.shared.show(KiraToast(tone: taken ? .success : .failure, message: taken ? copied : failed))
    }
}
