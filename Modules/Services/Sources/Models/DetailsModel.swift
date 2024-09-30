import Foundation

public protocol DetailsModel {
    init(details: ObjectDetails) throws
    static var subscriptionKeys: [BundledRelationKey] { get }
}
