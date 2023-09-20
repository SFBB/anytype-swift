import SwiftUI

struct WidgetObjectListView: View {
    
    @StateObject var model: WidgetObjectListViewModel
    @State private var searchText: String = ""
    // TODO: Navigation: Delete edit mode configurataion
    @State private var editMode: EditMode = .active
    
//    init(model: WidgetObjectListViewModel) {
//        self.model = model
//        self._editMode = State(initialValue: (model.editModel == .editOnly) ? .active : .inactive)
//    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                if model.isSheet {
                    DragIndicator()
                }
                TitleView(title: model.title) {
                    editButton
                }
                SearchBar(text: $searchText, focused: false, placeholder: Loc.search)
                content
            }
            .safeAreaInset(edge: .bottom, content: {
                Spacer.fixedHeight(EditorBottomNavigationView.Constants.height) // Navigation bottom panel offset
            })
            optionsView
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            model.onAppear()
        }
        .onDisappear() {
            model.onDisappear()
        }
        .onChange(of: searchText) { model.didAskToSearch(text: $0) }
        .onChange(of: editMode) { _ in model.onSwitchEditMode() }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .environment(\.editMode, $editMode)
        .homeBottomPanelHidden(model.homeBottomPanelHiddel)
    }
    
    @ViewBuilder
    private var content: some View {
        switch model.data {
        case .list(let sections):
            dataList(sections: sections)
        case .error(let error):
            NewSearchErrorView(error: error)
        }
    }
    
    @ViewBuilder
    private func dataList(sections: [ListSectionData<String?, WidgetObjectListRowModel>]) -> some View {
        PlainList {
            ForEach(sections) { section in
                if let title = section.data, title.isNotEmpty {
                    ListSectionBigHeaderView(title: title)
                }
                ForEach(section.rows, id: \.id) { row in
                    WidgetObjectListRowView(model: row)
                }
                .if(allowDnd) {
                    $0.onMove { from, to in
                        model.onMove(from: from, to: to)
                    }
                }
            }
            Spacer.fixedHeight(130 - EditorBottomNavigationView.Constants.height) // Additional space for action view
        }
        .hideScrollIndicatorLegacy()
        .hideKeyboardOnScrollLegacy()
    }
    
    @ViewBuilder
    private var editButton: some View {
        if model.contentIsNotEmpty {
            switch model.editModel {
            case .normal:
                EditButton()
                    .foregroundColor(Color.Button.active)
            case .editOnly:
                Button {
                    model.onSelectAll()
                } label: {
                    AnytypeText(model.selectButtonText, style: .uxBodyRegular, color: .Button.active)
                }
            }
        }
    }
    
    @ViewBuilder
    private var optionsView: some View {
        if model.showActionPanel {
            SelectionOptionsView(viewModel: SelectionOptionsViewModel(itemProvider: model))
                .frame(height: 100)
                .cornerRadius(16, style: .continuous)
                .shadow(radius: 16)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
    }
    
    private var allowDnd: Bool {
        switch model.editModel {
        case let .normal(allowDnd):
            return allowDnd
        case .editOnly:
            return false
        }
    }
}
