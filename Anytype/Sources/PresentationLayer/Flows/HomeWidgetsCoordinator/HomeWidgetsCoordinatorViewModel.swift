import SwiftUI
import DeepLinks
import Services
import Combine
import AnytypeCore

@MainActor
final class HomeWidgetsCoordinatorViewModel: ObservableObject, HomeWidgetsModuleOutput, SetObjectCreationCoordinatorOutput {
    
    let spaceInfo: AccountInfo
    var pageNavigation: PageNavigation?
    
    @Published var showChangeSourceData: WidgetChangeSourceSearchModuleModel?
    @Published var showChangeTypeData: WidgetTypeChangeData?
    @Published var showCreateWidgetData: CreateWidgetCoordinatorModel?
    @Published var showSpaceSettingsData: AccountInfo?
    
    @Injected(\.legacySetObjectCreationCoordinator)
    private var setObjectCreationCoordinator: any SetObjectCreationCoordinatorProtocol
    
    init(spaceInfo: AccountInfo) {
        self.spaceInfo = spaceInfo
    }
    
    func onFinishCreateSource(screenData: EditorScreenData?) {
        if let screenData {
            pageNavigation?.push(screenData)
        }
    }
    
    func onFinishChangeSource(screenData: EditorScreenData?) {
        showChangeSourceData = nil
        if let screenData {
            pageNavigation?.push(screenData)
        }
    }
    
    // MARK: - HomeWidgetsModuleOutput
    
    func onSpaceSelected() {
        showSpaceSettingsData = spaceInfo
    }
    
    func onCreateWidgetSelected(context: AnalyticsWidgetContext) {
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            spaceId: spaceInfo.accountSpaceId,
            widgetObjectId: spaceInfo.widgetsId,
            position: .end,
            context: context
        )
    }
    
    func onObjectSelected(screenData: EditorScreenData) {
        pageNavigation?.push(screenData)
    }
    
    func onChangeSource(widgetId: String, context: AnalyticsWidgetContext) {
        showChangeSourceData = WidgetChangeSourceSearchModuleModel(
            widgetObjectId: spaceInfo.widgetsId,
            spaceId: spaceInfo.accountSpaceId,
            widgetId: widgetId,
            context: context
        )
    }
    
    func onChangeWidgetType(widgetId: String, context: AnalyticsWidgetContext) {
        showChangeTypeData = WidgetTypeChangeData(
            widgetObjectId: spaceInfo.widgetsId,
            widgetId: widgetId,
            context: context,
            onFinish: { [weak self] in
                self?.showChangeTypeData = nil
            }
        )
    }
    
    func onAddBelowWidget(widgetId: String, context: AnalyticsWidgetContext) {
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            spaceId: spaceInfo.accountSpaceId,
            widgetObjectId: spaceInfo.widgetsId,
            position: .below(widgetId: widgetId),
            context: context
        )
    }
    
    func onCreateObjectInSetDocument(setDocument: some SetDocumentProtocol) {
        setObjectCreationCoordinator.startCreateObject(setDocument: setDocument, output: self, customAnalyticsRoute: .widget)
    }
    
    // MARK: - SetObjectCreationCoordinatorOutput
    
    func showEditorScreen(data: EditorScreenData) {
        pageNavigation?.push(data)
    }
}
