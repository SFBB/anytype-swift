import Foundation
import SwiftUI

struct GlobalSearchView: View {
    
    @StateObject private var model: GlobalSearchViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: GlobalSearchModuleData) {
        self._model = StateObject(wrappedValue: GlobalSearchViewModel(data: data))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            header
            sections
            Divider()
            content
        }
        .background(Color.Background.secondary)
        .task(id: model.state) {
            await model.search()
        }
        .onChange(of: model.dismiss) { _ in dismiss() }
        .onChange(of: model.state.searchText) { _ in model.onSearchTextChanged() }
    }
    
    private var header: some View {
        HStack(spacing: 0) {
            searchBar
            if model.state.searchText.isEmpty {
                menu
            }
        }
    }
    
    private var searchBar: some View {
        SearchBar(text: $model.state.searchText, focused: true, shouldShowDivider: false)
            .submitLabel(.go)
            .onSubmit {
                model.onKeyboardButtonTap()
            }
    }
    
    private var menu: some View {
        ObjectsSortMenu(
            sort: $model.state.sort,
            label: {
                Image(asset: .X40.sorts)
            }
        )
        .padding(.leading, -8)
        .padding(.trailing, 16)
        .menuActionDisableDismissBehavior()
    }
    
    private var sections: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ObjectTypeSection.searchSupportedSection, id: \.self) { section in
                    AnytypeText(
                        section.title,
                        style: .uxTitle2Medium
                    )
                    .foregroundColor(model.state.section == section ? .Text.inversion : .Text.secondary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(model.state.section == section ? Color.Control.active : .clear)
                    .cornerRadius(16)
                    .fixTappableArea()
                    .onTapGesture {
                        UISelectionFeedbackGenerator().selectionChanged()
                        model.onSectionChanged(section)
                    }
                    .animation(.default, value: model.state.section == section)
                }
            }
            .padding(.top, 2)
            .padding(.bottom, 10)
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if model.isInitial {
            Spacer()
        } else if model.sections.isEmpty {
            emptyState
        } else {
            searchResults
        }
    }
    
    private var searchResults: some View {
        PlainList {
            ForEach(model.sections) { section in
                if let title = section.data, title.isNotEmpty {
                    ListSectionHeaderView(title: title)
                        .padding(.horizontal, 20)
                }
                ForEach(section.rows) { data in
                    itemRow(for: data)
                }
            }
        }
        .scrollIndicators(.never)
        .id(model.state)
    }
    
    private func itemRow(for data: GlobalSearchData) -> some View {
        GlobalSearchCell(data: data)
            .fixTappableArea()
            .onTapGesture {
                model.onSelect(searchData: data)
            }
    }
    
    private var emptyState: some View {
        EmptyStateView(
            title: Loc.nothingFound,
            subtitle: Loc.GlobalSearch.EmptyState.subtitle,
            style: .plain
        )
    }
}
