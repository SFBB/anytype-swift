import Foundation
import Services
import Combine
import AnytypeCore

protocol TemplatesSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        objectType: ObjectTypeId,
        spaceId: String,
        update: @escaping SubscriptionCallback
    )
}

final class TemplatesSubscriptionService: TemplatesSubscriptionServiceProtocol {
    private let subscriptionId = "Templates-\(UUID().uuidString)"
    private let subscriptionService: SubscriptionsServiceProtocol
    
    deinit {
        stopSubscription()
    }
    
    init(subscriptionService: SubscriptionsServiceProtocol) {
        self.subscriptionService = subscriptionService
    }
    
    func startSubscription(
        objectType: ObjectTypeId,
        spaceId: String,
        update: @escaping SubscriptionCallback
    ) {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.addedDate,
            type: .desc
        )
        let filters = SearchHelper.templatesFilters(type: objectType, spaceId: spaceId)
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                sorts: [sort],
                filters: filters,
                limit: 100,
                offset: 0,
                keys: BundledRelationKey.templatePreviewKeys.map { $0.rawValue }
            )
        )
        
        subscriptionService.startSubscription(data: searchData, update: update)
    }
    
    private func stopSubscription() {
        subscriptionService.stopSubscription(id: subscriptionId)
    }
}
