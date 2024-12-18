import SwiftUI
import Services

struct SimpleSearchListView: View {
    
    @StateObject private var model: SimpleSearchListViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(items: [SimpleSearchListItem]) {
        self._model = StateObject(wrappedValue: SimpleSearchListViewModel(items: items))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            SearchBar(text: $model.searchText, focused: false, placeholder: Loc.search)
            list
        }
        .task(id: model.searchText) {
            await model.search()
        }
    }
    
    private var list: some View {
        PlainList {
            ForEach(model.searchedItems) { item in
                searchCell(for: item)
            }
            AnytypeNavigationSpacer(minHeight: 130)
        }
        .scrollIndicators(.never)
    }
    
    private func searchCell(for item: SimpleSearchListItem) -> some View {
        HStack(spacing: 10) {
            IconView(icon: item.icon)
            AnytypeText(item.title, style: .bodyRegular)
                .foregroundColor(.Text.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .newDivider()
        .padding(.horizontal, 20)
        .fixTappableArea()
        .onTapGesture {
            dismiss()
            item.onTap()
        }
    }
}

#Preview {
    SimpleSearchListView(items: [])
}
