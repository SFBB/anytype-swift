import Foundation
import Services

protocol SingleObjectSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        subIdPrefix: String,
        objectId: String,
        additionalKeys: [BundledRelationKey],
        dataHandler: @escaping (ObjectDetails) -> Void
    )
    func stopSubscription(subIdPrefix: String)
}

extension SingleObjectSubscriptionServiceProtocol {
    func startSubscription(subIdPrefix: String, objectId: String, dataHandler: @escaping (ObjectDetails) -> Void) {
        self.startSubscription(subIdPrefix: subIdPrefix, objectId: objectId, additionalKeys: [], dataHandler: dataHandler)
    }
}

final class SingleObjectSubscriptionService: SingleObjectSubscriptionServiceProtocol {
    
    // MARK: - DI
    
    private let subscriptionService: SubscriptionsServiceProtocol
    private let subscriotionBuilder: ObjectsCommonSubscriptionDataBuilderProtocol
    private var subData: SubscriptionData?
    
    private var cache = [String: [ObjectDetails]]()
    
    init(
        subscriptionService: SubscriptionsServiceProtocol,
        subscriotionBuilder: ObjectsCommonSubscriptionDataBuilderProtocol
    ) {
        self.subscriptionService = subscriptionService
        self.subscriotionBuilder = subscriotionBuilder
    }
    
    // MARK: - SingleObjectSubscriptionServiceProtocol
    
    func startSubscription(
        subIdPrefix: String,
        objectId: String,
        additionalKeys: [BundledRelationKey],
        dataHandler: @escaping (ObjectDetails) -> Void
    ) {
        let subData = subscriotionBuilder.build(subIdPrefix: subIdPrefix, objectIds: [objectId], additionalKeys: additionalKeys)
        self.subData = subData
        subscriptionService.startSubscription(data: subData, update: { [weak self] subId, update in
            var details = self?.cache[subIdPrefix] ?? []
            details.applySubscriptionUpdate(update)
            self?.cache[subIdPrefix] = details
            guard let object = details.first else { return }
            dataHandler(object)
        })
    }
    
    func stopSubscription(subIdPrefix: String) {
        guard let subData else { return }
        subscriptionService.stopSubscription(id: subData.identifier)
    }
}
