import Services
import AnytypeCore

// TODO: Navigation: Support it
protocol DocumentDetaisProvider {
    
    var screenData: EditorScreenData { get }
    var documentTitle: String? { get }
    var documentDescription: String? { get }
}

extension EditorPageController: DocumentDetaisProvider {
    
    var screenData: EditorScreenData {
        .page(EditorPageObject(objectId: viewModel.document.objectId, spaceId: viewModel.document.spaceId, isSupportedForEdit: true, isOpenedForPreview: false))
    }
    
    var documentTitle: String? {
        viewModel.document.details?.title
    }
    
    var documentDescription: String? {
        viewModel?.document.details?.description
    }
}
