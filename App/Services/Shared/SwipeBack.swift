/**
 The edge swipe back on every Kira screen. The screens hide the system navigation bar and draw their
 own back button (KiraIconButton.back), which leaves UIKit's interactive pop gesture without its
 delegate, so the swipe stopped working. Every navigation controller becomes its own gesture's
 delegate and lets the swipe start whenever there is a screen to go back to. A swipe pops the
 NavigationStack's path exactly as the back button's dismiss() does, so the path stays in sync. No
 screen blocks going back today; one that must would disable this per screen, not here.
 */
import UIKit

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    /** The swipe starts only when there is a screen under this one, never at the root. */
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === interactivePopGestureRecognizer else { return true }
        return viewControllers.count > 1
    }
}
