import Foundation
import Services

@MainActor
protocol EditorSetModuleOutput: AnyObject, ObjectHeaderModuleOutput {
    func showEditorScreen(data: ScreenData)
    func replaceEditorScreen(data: ScreenData)
    func closeEditor()
    
    func showSetViewPicker(document: some SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage)
    func showSetViewSettings(document: some SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage)
    func showQueries(document: some SetDocumentProtocol, selectedObjectId: String?, onSelect: @escaping (String) -> ())

    // NavigationContext
    func showCreateObject(document: some SetDocumentProtocol, setting: ObjectCreationSetting?)
    func showKanbanColumnSettings(
        hideColumn: Bool,
        selectedColor: BlockBackgroundColor?,
        onSelect: @escaping (Bool, BlockBackgroundColor?) -> Void
    )
    func showSettings()
    func showCoverPicker(document: some BaseDocumentProtocol)
    func showIconPicker(document: some BaseDocumentProtocol)
    func showRelationValueEditingView(objectDetails: ObjectDetails, relation: Relation)
    func showSetObjectCreationSettings(
        document: some SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> ()
    )
    func showSyncStatusInfo(spaceId: String)
    // TODO: Open toast inside module
    func showFailureToast(message: String)
}
