import Foundation
import ProtobufMessages

public extension ObjectRestrictionsContainer {
    
    func set(data: Anytype_Event.Object.Restrictions.Set) {
        restrinctions = MiddlewareObjectRestrictionsConverter.convertObjectRestrictions(middlewareRestrictions: data.restrictions)
    }
}
