import ProtobufMessages
import SwiftProtobuf
import Services
import AnytypeCore


final class TypesService: TypesServiceProtocol {
    
    @Injected(\.searchMiddleService)
    private var searchMiddleService: any SearchMiddleServiceProtocol
    @Injected(\.objectActionsService)
    private var actionsService: any ObjectActionsServiceProtocol
    @Injected(\.typesPinsStorage)
    private var pinsStorage: any TypesPinStorageProtocol
    @Injected(\.objectTypeProvider)
    private var typeProvider: any ObjectTypeProviderProtocol
    
    func createType(name: String, spaceId: String) async throws -> ObjectType {
        let details = Google_Protobuf_Struct(
            fields: [
                BundledRelationKey.name.rawValue: name.protobufValue,
            ]
        )
        
        let result = try await ClientCommands.objectCreateObjectType(.with {
            $0.details = details
            $0.spaceID = spaceId
        }).invoke()
        
        let objectDetails = try ObjectDetails(protobufStruct: result.details)
        return ObjectType(details: objectDetails)
    }
    
    func deleteType(typeId: String, spaceId: String) async throws {
        try await actionsService.delete(objectIds: [typeId])
        try pinsStorage.removePin(typeId: typeId, spaceId: spaceId)
    }
    
    // MARK: - Search
    func searchObjectTypes(
        text: String,
        includePins: Bool,
        includeLists: Bool,
        includeBookmarks: Bool,
        includeFiles: Bool,
        includeChat: Bool,
        includeTemplates: Bool,
        incudeNotForCreation: Bool,
        spaceId: String
    ) async throws -> [ObjectDetails] {
        let excludedTypeIds = includePins ? [] : try await searchPinnedTypes(text: "", spaceId: spaceId).map { $0.id }
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastUsedDate,
            type: .desc
        )
                
        var layouts = includeFiles ? DetailsLayout.visibleLayoutsWithFiles : DetailsLayout.visibleLayouts
        
        if !includeLists {
            layouts.removeAll(where: { $0 == .set })
            layouts.removeAll(where: { $0 == .collection })
        }
        
        if !includeBookmarks {
            layouts.removeAll(where: { $0 == .bookmark })
        }
        
        if !includeChat {
            layouts.removeAll(where: { $0 == .chat })
        }
        
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false)
            SearchHelper.layoutFilter([DetailsLayout.objectType])
            SearchHelper.recomendedLayoutFilter(layouts)
            SearchHelper.excludedIdsFilter(excludedTypeIds)
            if !incudeNotForCreation {
                SearchHelper.excludeObjectRestriction(.createObjectOfThisType)
            }
            if !includeTemplates {
                SearchHelper.uniqueKeyFilter(key: ObjectTypeUniqueKey.template.value, include: false)
            }
        }
        
        let result = try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: [sort], fullText: text)

        return result
    }
    
    func searchListTypes(
        text: String,
        includePins: Bool,
        spaceId: String
    ) async throws -> [ObjectType] {
        let excludedTypeIds = includePins ? [] : try await searchPinnedTypes(text: "", spaceId: spaceId).map { $0.id }
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastUsedDate,
            type: .desc
        )
                
        let layouts: [DetailsLayout] = [.set, .collection]
        
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false)
            SearchHelper.layoutFilter([DetailsLayout.objectType])
            SearchHelper.recomendedLayoutFilter(layouts)
            SearchHelper.excludedIdsFilter(excludedTypeIds)
        }
        
        return try await searchMiddleService.search(spaceId: spaceId, filters: filters, sorts: [sort], fullText: text)
            .map { ObjectType(details: $0) }
    }
    
    func searchLibraryObjectTypes(text: String, includeInstalledTypes: Bool, spaceId: String) async throws -> [ObjectDetails] {
        let excludedIds = includeInstalledTypes ? [] : typeProvider.objectTypes(spaceId: spaceId).map(\.sourceObject)
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters = Array.builder {
            SearchHelper.layoutFilter([DetailsLayout.objectType])
            SearchHelper.recomendedLayoutFilter(DetailsLayout.visibleLayouts)
            SearchHelper.excludedIdsFilter(excludedIds)
        }
        
        return try await searchMiddleService.search(spaceId: MarketplaceId.anytypeLibrary.rawValue, filters: filters, sorts: [sort], fullText: text)
    }
    
    func searchPinnedTypes(text: String, spaceId: String) async throws -> [ObjectType] {
        return try pinsStorage.getPins(spaceId: spaceId)
            .filter {
                guard text.isNotEmpty else { return true }
                return $0.name.lowercased().contains(text.lowercased())
            }
    }
    
    func addPinedType(_ type: ObjectType, spaceId: String) throws {
        try pinsStorage.appendPin(type, spaceId: spaceId)
    }
    
    func removePinedType(typeId: String, spaceId: String) throws {
        try pinsStorage.removePin(typeId: typeId, spaceId: spaceId)
    }
    
    func getPinnedTypes(spaceId: String) throws -> [ObjectType] {
        try pinsStorage.getPins(spaceId: spaceId)
    }
}
