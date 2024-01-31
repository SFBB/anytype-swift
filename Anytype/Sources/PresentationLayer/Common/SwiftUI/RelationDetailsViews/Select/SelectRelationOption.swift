import SwiftUI
import Services

struct SelectRelationOption: Equatable, Identifiable {
    let id: String
    let text: String
    let color: Color
}

extension SelectRelationOption {
    
    init(relation: RelationOption) {
        let middlewareColor = MiddlewareColor(rawValue: relation.color)
        
        self.id = relation.id
        self.text = relation.text
        self.color = middlewareColor.map { Color.Dark.color(from: $0) } ?? Color.Dark.grey
    }
    
}

