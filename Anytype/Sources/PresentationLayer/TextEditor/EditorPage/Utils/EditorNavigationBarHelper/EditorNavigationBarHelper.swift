import Foundation
import UIKit
import Services

final class EditorNavigationBarHelper {
    
    private weak var controller: UIViewController?
    
    private let fakeNavigationBarBackgroundView = UIView()
    private let navigationBarTitleView = EditorNavigationBarTitleView()
    
    private lazy var settingsBarButtonItem = UIBarButtonItem(customView: settingsItem)
    private let doneBarButtonItem: UIBarButtonItem
    private lazy var syncStatusBarButtonItem = UIBarButtonItem(customView: syncStatusItem)

    private let settingsItem: UIEditorBarButtonItem
    private let syncStatusItem = EditorSyncStatusItem(status: .unknown)

    private var contentOffsetObservation: NSKeyValueObservation?
    
    private var isObjectHeaderWithCover = false
    
    private var startAppearingOffset: CGFloat = 0.0
    private var endAppearingOffset: CGFloat = 0.0
    private var currentScrollViewOffset: CGFloat = 0.0

    private var currentEditorState: EditorEditingState?
    private var lastTitleModel: EditorNavigationBarTitleView.Mode.TitleModel?
        
    init(
        viewController: UIViewController,
        onSettingsBarButtonItemTap: @escaping () -> Void,
        onDoneBarButtonItemTap: @escaping () -> Void
    ) {
        self.controller = viewController
        self.settingsItem = UIEditorBarButtonItem(imageAsset: .X24.more, action: onSettingsBarButtonItemTap)

        self.doneBarButtonItem = UIBarButtonItem(
            title: Loc.done,
            image: nil,
            primaryAction: UIAction(handler: { _ in onDoneBarButtonItemTap() }),
            menu: nil
        )
        self.doneBarButtonItem.tintColor = UIColor.Button.accent


        self.fakeNavigationBarBackgroundView.backgroundColor = .Background.primary
        self.fakeNavigationBarBackgroundView.alpha = 0.0
        self.fakeNavigationBarBackgroundView.layer.zPosition = 1
        
        self.navigationBarTitleView.setAlphaForSubviews(0.0)
    }
    
}

// MARK: - EditorNavigationBarHelperProtocol

extension EditorNavigationBarHelper: EditorNavigationBarHelperProtocol {
    
    func addFakeNavigationBarBackgroundView(to view: UIView) {
        view.addSubview(fakeNavigationBarBackgroundView) {
            $0.top.equal(to: view.topAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.bottom.equal(to: view.layoutMarginsGuide.topAnchor)
        }
    }
    
    func handleViewWillAppear(scrollView: UIScrollView) {
        configureNavigationItem()
        
        contentOffsetObservation = scrollView.observe(
            \.contentOffset,
            options: .new
        ) { [weak self] scrollView, _ in
            self?.updateNavigationBarAppearanceBasedOnContentOffset(scrollView.contentOffset.y + scrollView.contentInset.top)
        }
    }
    
    func handleViewWillDisappear() {
        contentOffsetObservation?.invalidate()
        contentOffsetObservation = nil
    }
    
    func configureNavigationBar(using header: ObjectHeader, details: ObjectDetails?) {
        isObjectHeaderWithCover = header.hasCover
        startAppearingOffset = header.startAppearingOffset
        endAppearingOffset = header.endAppearingOffset
        
        updateBarButtonItemsBackground(opacity: 0)

        let titleModel = EditorNavigationBarTitleView.Mode.TitleModel(
            icon: details?.objectIconImage,
            title: details?.title
        )
        self.lastTitleModel = titleModel

        navigationBarTitleView.configure(
            model: .title(titleModel)
        )
    }
    
    func updateSyncStatus(_ status: SyncStatus) {
        syncStatusItem.changeStatus(status)
    }

    func editorEditingStateDidChange(_ state: EditorEditingState) {
        currentEditorState = state
        switch state {
        case .editing:
            controller?.navigationItem.titleView = navigationBarTitleView
            controller?.navigationItem.rightBarButtonItem = settingsBarButtonItem
            controller?.navigationItem.leftBarButtonItem = syncStatusBarButtonItem
            lastTitleModel.map { navigationBarTitleView.configure(model: .title($0)) }
            navigationBarTitleView.setIsReadonly(nil)
            updateNavigationBarAppearanceBasedOnContentOffset(currentScrollViewOffset)
        case .selecting(let blocks):
            navigationBarTitleView.setAlphaForSubviews(1)
            updateBarButtonItemsBackground(opacity: 1)
            fakeNavigationBarBackgroundView.alpha = 1
            controller?.navigationItem.leftBarButtonItem = nil
            controller?.navigationItem.rightBarButtonItem = doneBarButtonItem
            let title = Loc.selectedBlocks(blocks.count)
            navigationBarTitleView.configure(model: .modeTitle(title))
            navigationBarTitleView.setIsReadonly(nil)
        case .moving:
            let title = Loc.Editor.MovingState.scrollToSelectedPlace
            navigationBarTitleView.configure(model: .modeTitle(title))
            controller?.navigationItem.leftBarButtonItem = nil
            controller?.navigationItem.rightBarButtonItem = nil
            navigationBarTitleView.setIsReadonly(nil)
        case .readonly(let mode):
            navigationBarTitleView.setIsReadonly(mode)
        case let .simpleTablesSelection(_, selectedBlocks, _):
            navigationBarTitleView.setAlphaForSubviews(1)
            updateBarButtonItemsBackground(opacity: 1)
            fakeNavigationBarBackgroundView.alpha = 1
            controller?.navigationItem.leftBarButtonItem = nil
            controller?.navigationItem.rightBarButtonItem = doneBarButtonItem
            let title = Loc.selectedBlocks(selectedBlocks.count)
            navigationBarTitleView.configure(model: .modeTitle(title))
            navigationBarTitleView.setIsReadonly(nil)
        case .loading:
            controller?.navigationItem.titleView = navigationBarTitleView
            controller?.navigationItem.rightBarButtonItem = nil
            controller?.navigationItem.leftBarButtonItem = syncStatusBarButtonItem
            navigationBarTitleView.setIsReadonly(nil)
        }
    }
}

// MARK: - Private extension

private extension EditorNavigationBarHelper {
    
    func configureNavigationItem() {
        controller?.navigationItem.backBarButtonItem = nil
        controller?.navigationItem.hidesBackButton = true
    }
    
    func updateBarButtonItemsBackground(opacity: CGFloat) {
        let state = EditorBarItemState(haveBackground: isObjectHeaderWithCover, opacity: opacity)
        settingsItem.changeState(state)
        syncStatusItem.changeState(state)
    }
    
    func updateNavigationBarAppearanceBasedOnContentOffset(_ newOffset: CGFloat) {
        currentScrollViewOffset = newOffset
        guard let percent = countPercentOfNavigationBarAppearance(offset: newOffset) else { return }

        switch currentEditorState {
            case .editing, .readonly: break
            default: return
        }
        
        // From 0 to 0.5 percent -> opacity 0..1
        let barButtonsOpacity = min(percent, 0.5) * 2
        // From 0.5 to 1 percent -> alpha 0..1
        let titleAlpha = (max(percent, 0.5) - 0.5) * 2
        
        navigationBarTitleView.setAlphaForSubviews(titleAlpha)
        updateBarButtonItemsBackground(opacity: barButtonsOpacity)
        fakeNavigationBarBackgroundView.alpha = percent
    }
    
    private func countPercentOfNavigationBarAppearance(offset: CGFloat) -> CGFloat? {
        let navigationBarHeight = fakeNavigationBarBackgroundView.bounds.height
        let yFullOffset = offset + navigationBarHeight

        if yFullOffset < startAppearingOffset {
            return 0
        } else if yFullOffset > endAppearingOffset {
            return 1
        } else if yFullOffset > startAppearingOffset, yFullOffset < endAppearingOffset {
            let currentDiff = yFullOffset - startAppearingOffset
            let max = endAppearingOffset - startAppearingOffset
            return currentDiff / max
        }
        
        return nil
    }
    
}

// MARK: - ObjectHeader

private extension ObjectHeader {
    
    var hasCover: Bool {
        switch self {
        case .filled(let filledState, _):
            return filledState.hasCover
        case .empty:
            return false
        }
    }
    
    var startAppearingOffset: CGFloat {
        switch self {
        case .filled:
            return ObjectHeaderConstants.coverHeight - 100
            
        case .empty:
            return ObjectHeaderConstants.emptyViewHeight - 50
        }
    }
    
    var endAppearingOffset: CGFloat {
        switch self {
        case .filled:
            return ObjectHeaderConstants.coverHeight
            
        case .empty:
            return ObjectHeaderConstants.emptyViewHeight
        }
    }
    
}
