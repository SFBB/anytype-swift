import Foundation
import UIKit
import Services

protocol CreateObjectModuleAssemblyProtocol {
    func makeCreateObject(
        objectId: String,
        openToEditAction: @escaping () -> Void,
        closeAction: @escaping () -> Void
    ) -> UIViewController
    
    func makeCreateBookmark(
        spaceId: String,
        collectionId: String?,
        closeAction: @escaping (_ details: ObjectDetails?) -> Void
    ) -> UIViewController
}


final class CreateObjectModuleAssembly: CreateObjectModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - CreateObjectModuleAssemblyProtocol
    
    func makeCreateObject(
        objectId: String,
        openToEditAction: @escaping () -> Void,
        closeAction: @escaping () -> Void
    ) -> UIViewController {
        let viewModel = CreateObjectViewModel(
            relationService: serviceLocator.relationService(objectId: objectId),
            openToEditAction: openToEditAction,
            closeAction: closeAction
        )
        return make(viewModel: viewModel)
    }
    
    func makeCreateBookmark(spaceId: String, collectionId: String?, closeAction: @escaping (_ details: ObjectDetails?) -> Void) -> UIViewController {
        let viewModel = CreateBookmarkViewModel(
            spaceId: spaceId,
            collectionId: collectionId,
            bookmarkService: serviceLocator.bookmarkService(),
            objectActionsService: serviceLocator.objectActionsService(),
            closeAction: closeAction
        )
        return make(viewModel: viewModel)
    }
    
    // MARK: - Private
    
    private func make(viewModel: CreateObjectViewModelProtocol) -> UIViewController {
        let view = CreateObjectView(viewModel: viewModel)
        return AnytypePopup(
            contentView: view,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: true, dismissOnBackdropView: true ),
            showKeyboard: true
        )
    }
}
