import Foundation
import SwiftUI

final class AnytypeNavigationCoordinator: NSObject, UINavigationControllerDelegate {
    
    @Binding private(set) var path: [AnyHashable]
    @Binding private(set) var pathChanging: Bool

    let builder = AnytypeDestinationBuilderHolder()
    var currentViewControllers = [UIHostingController<AnytypeNavigationViewBridge>]()
    var numberOfTransactions: Int = 0
    var popProgress: AnytypeNavigationPopProgress?

    init(path: Binding<[AnyHashable]>, pathChanging: Binding<Bool>) {
        self._path = path
        self._pathChanging = pathChanging
    }

    // MARK: - UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        pathChanging = true
        navigationController.transitionCoordinator?.notifyWhenInteractionChanges { [weak self] transaction in
            self?.popProgress?.settle(cancelled: transaction.isCancelled, duration: transaction.transitionDuration)
            if transaction.isCancelled {
                self?.pathChanging = false
            }
        }
        // A pop reveals a hosting view that may have changed while off screen -
        // force an authoritative layout pass or it can show a stale frame during
        // the transition. Pushes must not get this: forcing layout on a freshly
        // created controller mid-transition makes its content jump after settling.
        let isPop = navigationController.viewControllers.count < currentViewControllers.count
        if isPop {
            navigationController.transitionCoordinator?.animate(alongsideTransition: { _ in
                UIView.performWithoutAnimation {
                    viewController.view.layoutIfNeeded()
                }
            })
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if numberOfTransactions > 0 {
            numberOfTransactions -= 1
        }
        
        if numberOfTransactions == 0  {
            if navigationController.viewControllers.count < path.count {
                path = Array(path[..<navigationController.viewControllers.count])
            }
            if navigationController.viewControllers.count < currentViewControllers.count {
                currentViewControllers = Array(currentViewControllers[..<navigationController.viewControllers.count])
            }
        }
        
        // Same synchronous block as the path update above, so the interpolated opacity of any
        // swipe-tracking chrome hands over to its settled value without a frame in between.
        popProgress?.reset()
        pathChanging = false
    }
}
