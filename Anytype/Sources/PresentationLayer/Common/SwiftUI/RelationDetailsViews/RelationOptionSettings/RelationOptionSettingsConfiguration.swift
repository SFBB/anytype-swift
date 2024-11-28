import SwiftUI
import Services

struct RelationOptionSettingsConfiguration {
    let option: RelationOptionParameters
    let mode: RelationOptionSettingsMode
}

enum RelationOptionSettingsMode {
    case create(CreateData)
    case edit
    
    var title: String {
        switch self {
        case .create: return Loc.Relation.View.Create.title
        case .edit: return Loc.Relation.View.Edit.title
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .create: return Loc.create
        case .edit: return Loc.apply
        }
    }
    
    struct CreateData {
        let relationKey: String
        let spaceId: String
    }
}

struct RelationOptionParameters {
    let id: String
    let text: String
    let color: Color
    
    init(id: String = UUID().uuidString, text: String?, color: Color?) {
        self.id = id
        self.text = text ?? ""
        self.color = color ?? MiddlewareColor.allCasesWithoutDefault.randomElement().map { Color.Dark.color(from: $0) } ?? Color.Dark.grey
    }
}
