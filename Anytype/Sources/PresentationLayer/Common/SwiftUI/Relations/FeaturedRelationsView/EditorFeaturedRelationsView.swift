import SwiftUI

struct EditorFeaturedRelationsView: View {
    let relations: [Relation]
    let onRelationTap: ((Relation) -> Void)
    
    init(relations: [Relation], onRelationTap: @escaping (Relation) -> Void) {
        self.relations = relations
        self.onRelationTap = onRelationTap
    }
    
    var body: some View {
        if relations.isNotEmpty {
            content
        }
    }
    
    private var content: some View {
        FeaturedRelationsView(
            relations: relations,
            view: { relation in
                RelationValueView(
                    model: RelationValueViewModel(
                        relation:  RelationItemModel(relation: relation),
                        style: .featuredRelationBlock(
                            FeaturedRelationSettings(
                                allowMultiLine: false,
                                error: RelationItemModel(relation: relation).isErrorState,
                                links: relation.links
                            )
                        ),
                        mode: .button(action: { onRelationTap(relation) })
                    )
                )
            }
        )
        .padding(.top, 8)
    }
}
