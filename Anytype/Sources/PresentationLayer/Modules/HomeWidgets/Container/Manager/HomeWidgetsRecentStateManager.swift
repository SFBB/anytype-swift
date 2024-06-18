import Foundation
import Services

protocol HomeWidgetsRecentStateManagerProtocol: AnyObject {
    func setupRecentStateIfNeeded(
        blocks: [BlockInformation],
        widgetObject: BaseDocumentProtocol
    )
}

final class HomeWidgetsRecentStateManager: HomeWidgetsRecentStateManagerProtocol {
    
    // MARK: - DI
    @Injected(\.loginStateService)
    private var loginStateService: LoginStateServiceProtocol
    @Injected(\.blockWidgetExpandedService)
    private var expandedService: BlockWidgetExpandedServiceProtocol
    
    // MARK: - State
    
    private var stateInstalled: Bool = false
    
    init() { }
    
    // MARK: - HomeWidgetsRecentStateManagerProtocol
    
    func setupRecentStateIfNeeded(
        blocks: [BlockInformation],
        widgetObject: BaseDocumentProtocol
    ) {
        guard loginStateService.isFirstLaunchAfterAuthorization || loginStateService.isFirstLaunchAfterRegistration,
              !stateInstalled
            else { return }
        
        blocks.forEach { block in
            guard let widgetInfo = widgetObject.widgetInfo(block: block),
                  widgetInfo.source == .library(.recent) else { return }
            
            expandedService.setState(widgetBlockId: block.id, isExpanded: false)
        }
        stateInstalled = true
    }
}
