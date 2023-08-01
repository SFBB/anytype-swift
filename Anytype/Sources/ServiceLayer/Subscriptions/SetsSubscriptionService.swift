import Foundation
import Services
import Combine
import AnytypeCore

protocol SetsSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        objectLimit: Int?,
        update: @escaping SubscriptionCallback
    )
    func stopSubscription()
}

final class SetsSubscriptionService: SetsSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    private let subscriptionService: SubscriptionsServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionId = SubscriptionId(value: "Sets-\(UUID().uuidString)")
    
    init(
        subscriptionService: SubscriptionsServiceProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol
    ) {
        self.subscriptionService = subscriptionService
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.objectTypeProvider = objectTypeProvider
    }
    
    func startSubscription(
        objectLimit: Int?,
        update: @escaping SubscriptionCallback
    ) {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.spaceId(activeWorkspaceStorage.workspaceInfo.accountSpaceId),
            SearchHelper.layoutFilter([DetailsLayout.set])
        ]
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                sorts: [sort],
                filters: filters,
                limit: objectLimit ?? Constants.limit,
                offset: 0,
                keys: BundledRelationKey.objectListKeys.map { $0.rawValue }
            )
        )
        
        subscriptionService.startSubscription(data: searchData, update: update)
    }
    
    func stopSubscription() {
        subscriptionService.stopAllSubscriptions()
    }
}
