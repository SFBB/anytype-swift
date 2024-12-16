import Services
import Foundation


enum TypeFieldsRow: Identifiable {
    case relation(TypeFieldsRelationRow)
    case header(TypeFieldsSectionRow)
    case emptyRow(TypeFieldsSectionRow)
    
    var id: String {
        switch self {
        case .relation(let relation):
            relation.id
        case .header(let section):
            section.id
        case .emptyRow(let section):
            "emptyRow" + section.id
        }
    }
    
    var relationId: String? {
        switch self {
        case .relation(let relationRow):
            relationRow.relation.id
        case .header, .emptyRow:
            nil
        }
    }
}

struct TypeFieldsRelationRow: Identifiable {
    let section: TypeFieldsSectionRow
    let relation: Relation
    
    var id: String { section.id + relation.id }
}

enum TypeFieldsSectionRow: String, Identifiable {
    case header
    case fieldsMenu
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .header: return Loc.header
        case .fieldsMenu: return Loc.Fields.menu
        }
    }
    
    var isHeader: Bool {
        switch self {
        case .header:
            true
        case .fieldsMenu:
            false
        }
    }
}
