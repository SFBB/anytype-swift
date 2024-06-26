import Foundation
import AnytypeCore
import Services

@MainActor
protocol RelationValueProcessingServiceProtocol {
    func handleRelationValue(
        relation: Relation,
        objectDetails: ObjectDetails,
        analyticsType: AnalyticsEventsRelationType,
        onToastShow: (String) -> Void
    ) -> RelationValueData?
}

@MainActor
fileprivate final class RelationValueProcessingService: RelationValueProcessingServiceProtocol {
    
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    
    nonisolated init() {}
    
    func handleRelationValue(
        relation: Relation,
        objectDetails: ObjectDetails,
        analyticsType: AnalyticsEventsRelationType,
        onToastShow: (String) -> Void
    ) -> RelationValueData? {
        if case .date = relation, !relation.isEditable {
            onToastShow(Loc.Relation.Date.Locked.Alert.title(relation.name))
            return nil
        }
        
        switch relation {
        case .status, .tag, .object, .date, .file, .text, .number, .url, .email, .phone:
            return RelationValueData(
                relation: relation,
                objectDetails: objectDetails, 
                analyticsType: analyticsType
            )
        case .checkbox(let checkbox):
            guard relation.isEditable else { return nil }
            let newValue = !checkbox.value
            AnytypeAnalytics.instance().logChangeOrDeleteRelationValue(
                isEmpty: !newValue,
                type: analyticsType,
                spaceId: objectDetails.spaceId
            )
            Task {
                try await relationsService.updateRelation(objectId: objectDetails.id, relationKey: checkbox.key, value: newValue.protobufValue)
            }
        case .unknown:
            return nil
        }
        
        return nil
    }
}

struct RelationValueData: Identifiable {
    let id = UUID()
    let relation: Relation
    let objectDetails: ObjectDetails
    let analyticsType: AnalyticsEventsRelationType
}

extension Container {
    var relationValueProcessingService: Factory<any RelationValueProcessingServiceProtocol> {
        self { RelationValueProcessingService() }.shared
    }
}
