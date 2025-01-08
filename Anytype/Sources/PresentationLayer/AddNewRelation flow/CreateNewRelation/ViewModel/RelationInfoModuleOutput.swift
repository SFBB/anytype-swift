import Foundation
import Services

@MainActor
protocol RelationInfoModuleOutput: AnyObject {
    
    func didAskToShowRelationFormats(
        selectedFormat: SupportedRelationFormat,
        onSelect: @escaping (SupportedRelationFormat) -> Void
    )
    func didAskToShowObjectTypesSearch(
        selectedObjectTypesIds: [String],
        onSelect: @escaping ([String]) -> Void
    )
    func didCreateRelation(_ relation: RelationDetails)
    
}
