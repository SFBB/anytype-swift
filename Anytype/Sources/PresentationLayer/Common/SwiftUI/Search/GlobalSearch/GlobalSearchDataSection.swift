import Foundation
import Services

struct GlobalSearchData: Identifiable, Hashable {
    let id: String
    let iconImage: Icon
    let title: AttributedString
    let highlights: [HighlightsData]
    let objectTypeName: String
    let editorScreenData: ScreenData
    let score: String
}

enum HighlightsData: Identifiable, Hashable {
    case text(AttributedString)
    case status(name: String, option: Relation.Status.Option)
    case tag(name: String, option: Relation.Tag.Option)
    
    var id: Int { hashValue }
}
