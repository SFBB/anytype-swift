import Foundation
import Services
import AnytypeCore

struct WidgetAnytypeLibrarySource: Hashable {
    let type: AnytypeWidgetId
    let name: String
    let description: String?
    let icon: Icon
}

@MainActor
protocol WidgetSourceSearchInteractorProtocol: AnyObject {
    func objectsTypesSearch(text: String) async throws -> [ObjectDetails]
    func objectsSearch(text: String) async throws -> [ObjectDetails]
    func anytypeLibrarySearch(text: String) async throws -> [WidgetAnytypeLibrarySource]
}

@MainActor
final class WidgetSourceSearchInteractor: WidgetSourceSearchInteractorProtocol {
    
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    private let openedDocumentsProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    
    private let spaceId: String
    private let widgetObjectId: String
    private let anytypeLibrary = AnytypeWidgetId.availableWidgets.map { $0.librarySource }
    private let widgetObject: any BaseDocumentProtocol
    
    private var widgetTypeIds: [String]?
    
    init(spaceId: String, widgetObjectId: String) {
        self.spaceId = spaceId
        self.widgetObjectId = widgetObjectId
        self.widgetObject = openedDocumentsProvider.document(objectId: widgetObjectId, spaceId: spaceId, mode: .preview)
    }
    
    // MARK: - WidgetSourceSearchInteractorProtocol
    
    func objectsSearch(text: String) async throws -> [ObjectDetails] {
        try await searchService.search(text: text, spaceId: spaceId)
    }
    
    func objectsTypesSearch(text: String) async throws -> [ObjectDetails] {
        if widgetTypeIds.isNil {
            let sourceIds = try await sourceIds()
            let objectTypes = objectTypeProvider.objectTypes(spaceId: spaceId)
            let excludedExistedIds = objectTypes
                .filter { sourceIds.contains($0.id) }
                .map { $0.id }
            let excludedTypeIds = objectTypes
                .filter { $0.uniqueKey == ObjectTypeUniqueKey.template || $0.uniqueKey == ObjectTypeUniqueKey.objectType }
                .map { $0.id }
            widgetTypeIds = excludedExistedIds + excludedTypeIds
        }
        
        return try await searchService.searchObjectsWithLayouts(
            text: text,
            layouts: [.objectType],
            excludedIds: widgetTypeIds ?? [],
            spaceId: spaceId
        )
    }
    
    func anytypeLibrarySearch(text: String) async throws -> [WidgetAnytypeLibrarySource] {
        let sourceIds = try await sourceIds()
        let anytypeLibrary = anytypeLibrary.filter { !sourceIds.contains($0.type.rawValue) }
        
        guard text.isNotEmpty else { return anytypeLibrary }
        return anytypeLibrary.filter { $0.name.range(of: text, options: .caseInsensitive) != nil }
    }
    
    private func sourceIds() async throws -> [String] {
        try await widgetObject.open()
        return widgetObject.children
            .filter(\.isWidget)
            .compactMap { widgetObject.targetObjectIdByLinkFor(widgetBlockId: $0.id) }
    }
}

private extension AnytypeWidgetId {
    var librarySource: WidgetAnytypeLibrarySource {
        switch self {
        case .allObjects:
            return WidgetAnytypeLibrarySource(
                type: .allObjects,
                name: Loc.allObjects,
                description: nil,
                icon: FeatureFlags.objectTypeWidgets ? .asset(.SystemWidgets.allObjects) : .object(.emoji(Emoji("🗄")!))
            )
        case .favorite:
            return WidgetAnytypeLibrarySource(
                type: .favorite,
                name: Loc.favorite,
                description: nil,
                icon: FeatureFlags.objectTypeWidgets ? .asset(.SystemWidgets.favorites) : .object(.emoji(Emoji("⭐️")!))
            )
        case .sets:
            return WidgetAnytypeLibrarySource(
                type: .sets,
                name: Loc.sets,
                description: nil,
                icon: .object(.emoji(Emoji("🔎")!))
            )
        case .collections:
            return WidgetAnytypeLibrarySource(
                type: .collections,
                name: Loc.collections,
                description: nil,
                icon: .object(.emoji(Emoji("📂")!))
            )
        case .recent:
            return WidgetAnytypeLibrarySource(
                type: .recent,
                name: Loc.Widgets.Library.RecentlyEdited.name,
                description: nil,
                icon: FeatureFlags.objectTypeWidgets ? .asset(.SystemWidgets.recentlyEdited) : .object(.emoji(Emoji("📝")!))
            )
        case .recentOpen:
            return WidgetAnytypeLibrarySource(
                type: .recentOpen,
                name: Loc.Widgets.Library.RecentlyOpened.name,
                description: Loc.Widgets.Library.RecentlyOpened.description,
                icon: FeatureFlags.objectTypeWidgets ? .asset(.SystemWidgets.recentlyOpened) : .object(.emoji(Emoji("📅")!))
            )
        case .bin:
            return WidgetAnytypeLibrarySource(
                type: .bin,
                name: Loc.bin,
                description: nil,
                icon: FeatureFlags.objectTypeWidgets ? .asset(.SystemWidgets.bin) : .object(.emoji(Emoji("🗑️")!))
            )
        }
    }
}
