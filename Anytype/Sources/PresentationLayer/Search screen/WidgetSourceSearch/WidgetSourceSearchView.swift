import Foundation
import SwiftUI

struct WidgetSourceSearchView: View {
    
    let data: WidgetSourceSearchModuleModel
    let onSelect: (_ source: WidgetSource, _ openObject: EditorScreenData?) -> Void
    
    var body: some View {
        // TODO: Migrate from LegacySearchView
        LegacySearchView(
             viewModel: LegacySearchViewModel(
                 title: Loc.Widgets.sourceSearch,
                 searchPlaceholder: Loc.search,
                 style: .default,
                 itemCreationMode: .unavailable,
                 internalViewModel: WidgetSourceSearchViewModel(
                     interactor: WidgetSourceSearchInteractor(
                        spaceId: data.spaceId
                     ),
                     internalModel: WidgetSourceSearchSelectInternalViewModel(data: data, onSelect: onSelect)
                 )
             )
         )
    }
}
