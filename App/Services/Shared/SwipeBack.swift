/**
 The edge swipe back on every Kira screen. The screens hide the system navigation bar and draw their
 own back button (KiraIconButton.back), which leaves UIKit's interactive pop gesture without its
 delegate, so the swipe stopped working. Every navigation controller hands its gesture to
 `SwipeBack`, which lets the swipe start whenever there is a screen to go back to. A swipe pops the
 NavigationStack's path exactly as the back button's dismiss() does, so the path stays in sync. No
 screen blocks going back today; one that must would disable this per screen, not here.
 */
import UIKit

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = SwipeBack.shared
    }
}

/** The interactive pop gesture's delegate, shared by every navigation controller (gestures hold it weakly). */
final class SwipeBack: NSObject, UIGestureRecognizerDelegate {
    /** The one delegate, kept alive here. */
    static let shared = SwipeBack()

    /** The swipe starts only when there is a screen under this one, never at the root. */
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigation = gestureRecognizer.view?.next as? UINavigationController else { return false }
        return navigation.viewControllers.count > 1
    }
}
