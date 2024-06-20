import Foundation
import Services
import Combine
import UIKit
import SwiftUI

@MainActor
final class SetObjectWidgetInternalViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: BaseDocumentProtocol
    @Injected(\.setSubscriptionDataBuilder)
    private var setSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol
    private let subscriptionStorage: SubscriptionStorageProtocol
    private weak var output: CommonWidgetModuleOutput?
    private let subscriptionId = "SetWidget-\(UUID().uuidString)"
    
    @Injected(\.documentsProvider)
    private var documentService: DocumentsProviderProtocol
    @Injected(\.blockWidgetService)
    private var blockWidgetService: BlockWidgetServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: ObjectActionsServiceProtocol
    @Injected(\.setContentViewDataBuilder)
    private var setContentViewDataBuilder: SetContentViewDataBuilderProtocol
    
    // MARK: - State
    private var widgetInfo: BlockWidgetInfo?
    private var setDocument: SetDocumentProtocol?
    var activeViewId: String? { didSet { updateActiveView() } }
    private var canEditBlocks = true
    private var dataviewState: WidgetDataviewState? { didSet { updateHeader() } }
    private var rowDetails: [SetContentViewItemConfiguration]? { didSet { updateRows() } }
    
    var dragId: String? { widgetBlockId }
    
    @Published var name: String = ""
    @Published var contentTaskId: String?
    @Published var headerItems: [ViewWidgetTabsItemModel]?
    @Published var rows: SetObjectViewWidgetRows = .list([])
    @Published var allowCreateObject = true
    
    init(data: WidgetSubmoduleData) {
        self.widgetBlockId = data.widgetBlockId
        self.widgetObject = data.widgetObject
        self.output = data.output
        
        let storageProvider = Container.shared.subscriptionStorageProvider.resolve()
        self.subscriptionStorage = storageProvider.createSubscriptionStorage(subId: subscriptionId)
    }
    
    // MARK: - Subscriptions
    
    func startPermissionsPublisher() async {
        for await permissions in widgetObject.permissionsPublisher.values {
            canEditBlocks = permissions.canEditBlocks
        }
    }
    
    func startInfoPublisher() async {
        for await newWidgetInfo in widgetObject.blockWidgetInfoPublisher(widgetBlockId: widgetBlockId).values {
            widgetInfo = newWidgetInfo
            if activeViewId.isNil || canEditBlocks {
                activeViewId = widgetInfo?.block.viewID
            }
        }
    }
    
    func startTargetDetailsPublisher() async {
        for await details in widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId).values {
            await updateSetDocument(objectId: details.id)
        }
    }
    
    func startContentSubscription() async {
        guard let setDocument else { return }
        for await _ in setDocument.syncPublisher.values {
            updateDataviewState()
            await updateViewSubscription()
        }
    }
    
    // MARK: - Actions
    
    func onActiveViewTap(_ viewId: String) {
        guard setDocument?.activeView.id != viewId else { return }
        Task { @MainActor in
            if canEditBlocks {
                try? await blockWidgetService.setViewId(contextId: widgetObject.objectId, widgetBlockId: widgetBlockId, viewId: viewId)
            } else {
                activeViewId = viewId
            }
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onCreateObjectTap() {
        guard let setDocument else { return }
        output?.onCreateObjectInSetDocument(setDocument: setDocument)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onHeaderTap() {
        guard let details = setDocument?.details else { return }
        let screenData = details.editorScreenData()
        AnytypeAnalytics.instance().logSelectHomeTab(source: .object(type: setDocument?.details?.analyticsType ?? .object(typeId: "")))
        output?.onObjectSelected(screenData: screenData)
    }
    
    // MARK: - Private for view updates
    
    private func updateRows() {
        withAnimation {
            switch setDocument?.activeView.type {
            case .table, .list, .kanban, .calendar, .graph, nil:
                let listRows = rowDetails?.map { details in
                    ListWidgetRowModel(
                        objectId: details.id,
                        icon: details.icon,
                        title: details.title,
                        description: details.description,
                        onTap: details.onItemTap
                    )
                }
                rows = .list(listRows)
            case .gallery:
                let galleryRows = rowDetails?.map { details in
                    GalleryWidgetRowModel(
                        objectId: details.id,
                        title: details.title,
                        icon: details.icon,
                        onTap: details.onItemTap
                    )
                }
                rows = .gallery(galleryRows)
                rows = .gallery([])
            }
        }
    }
    
    private func updateHeader() {
        withAnimation(headerItems.isNil ? nil : .default) {
            headerItems = dataviewState?.dataview.map { dataView in
                ViewWidgetTabsItemModel(
                    dataviewId: dataView.id,
                    title: dataView.nameWithPlaceholder,
                    isSelected: dataView.id == dataviewState?.activeViewId,
                    onTap: { [weak self] in
                        self?.onActiveViewTap(dataView.id)
                    }
                )
            }
        }
    }
    
    private func updateDone(details: ObjectDetails) {
        guard details.layoutValue == .todo else { return }
        
        Task {
            try await objectActionsService.updateBundledDetails(contextID: details.id, details: [.done(!details.done)])
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }
    
    // MARK: - Private for set logic
        
    private func updateViewSubscription() async {
        guard let setDocument, let widgetInfo else {
            try? await subscriptionStorage.stopSubscription()
            return
        }
        
        guard setDocument.canStartSubscription() else { return }
        
        let subscriptionData = setSubscriptionDataBuilder.set(
            SetSubscriptionData(
                identifier: subscriptionId,
                document: setDocument,
                groupFilter: nil,
                currentPage: 0,
                numberOfRowsPerPage: widgetInfo.fixedLimit,
                collectionId: setDocument.isCollection() ? setDocument.objectId : nil,
                objectOrderIds: setDocument.objectOrderIds(for: setSubscriptionDataBuilder.subscriptionId)
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: subscriptionData) { [weak self] data in
            self?.updateRowDetails(details: data.items)
        }
    }
    
    private func updateDataviewState() {
        guard let setDocument, setDocument.dataView.views.count > 1 else {
            dataviewState = nil
            return
        }
        dataviewState = WidgetDataviewState(
            dataview: setDocument.dataView.views,
            activeViewId: setDocument.activeView.id
        )
    }
    
    private func sortedRowDetails(_ details: [ObjectDetails]?) -> [ObjectDetails]? {
        guard let objectOrderIds = setDocument?.objectOrderIds(for: setSubscriptionDataBuilder.subscriptionId),
                objectOrderIds.isNotEmpty else {
            return details
        }
        return details?.reorderedStable(by: objectOrderIds, transform: { $0.id })
    }
    
    private func updateSetDocument(objectId: String) async {
        guard objectId != setDocument?.objectId else {
            try? await setDocument?.openForPreview()
            updateModelState()
            return
        }
        
        setDocument = documentService.setDocument(objectId: objectId, forPreview: true, inlineParameters: nil)
        try? await setDocument?.openForPreview()
        updateModelState()
        
        rowDetails = nil
        dataviewState = nil
        // Restart document subscription
        contentTaskId = objectId
    }
    
    private func updateModelState() {
        updateActiveView()
        
        guard let setDocument else { return }
        allowCreateObject = setDocument.setPermissions.canCreateObject
        
        guard let details = setDocument.details else { return }
        name = details.title
    }
    
    
    private func updateActiveView() {
        guard let activeViewId, let setDocument, setDocument.activeView.id != activeViewId, setDocument.document.isOpened else { return }
        setDocument.updateActiveViewIdAndReload(activeViewId)
    }
    
    private func updateRowDetails(details: [ObjectDetails]) {
        guard let setDocument else { return }
        rowDetails = setContentViewDataBuilder.itemData(
            details,
            dataView: setDocument.dataView,
            activeView: setDocument.activeView,
            viewRelationValueIsLocked: false,
            storage: subscriptionStorage.detailsStorage,
            spaceId: setDocument.spaceId,
            onItemTap: { [weak self] in
                self?.output?.onObjectSelected(screenData: $0.editorScreenData())
            }
        )
    }
}
