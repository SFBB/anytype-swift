import Services

enum SubscriptionUpdate {
    case initialData([ObjectDetails])
    case update(ObjectDetails)
    case remove(BlockId)
    case add(ObjectDetails, after: BlockId?)
    case move(from: BlockId, after: BlockId?)
    case pageCount(Int)
    
    var isInitialData: Bool {
        switch self {
        case .initialData:
            return true
        default:
            return false
        }
    }
}

typealias SubscriptionCallback = (String, SubscriptionUpdate) -> ()
protocol SubscriptionsServiceProtocol {
   
    // TODO: Needs refactoring
    var storage: ObjectDetailsStorage { get }
    
    func updateSubscription(data: SubscriptionData, required: Bool, update: @escaping SubscriptionCallback)
    
    func startSubscriptions(data: [SubscriptionData], update: @escaping SubscriptionCallback)
    func startSubscription(data: SubscriptionData, update: @escaping SubscriptionCallback)
    // Wait until subscription started and received initial data
    func startSubscriptionAsync(data: SubscriptionData, update: @escaping SubscriptionCallback) async
    
    func stopSubscriptions(ids: [String])
    func stopSubscription(id: String)
    func stopAllSubscriptions()
}
