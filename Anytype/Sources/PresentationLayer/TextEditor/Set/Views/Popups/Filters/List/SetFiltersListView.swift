import SwiftUI

struct SetFiltersListView: View {
    @StateObject var viewModel: SetFiltersListViewModel
    
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        DragIndicator()
        NavigationView {
            content
                .navigationTitle(Loc.EditSet.Popup.Filters.NavigationView.title)
                .navigationBarTitleDisplayMode(.inline)
                .environment(\.editMode, $editMode)
                .onChange(of: viewModel.rows) { newValue in
                    if editMode == .active && viewModel.rows.count == 0 {
                        editMode = .inactive
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
    
    private var addButton: some View {
        Group {
            if editMode == .inactive {
                Button {
                    viewModel.addButtonTapped()
                } label: {
                    Image(asset: .X32.plus)
                        .foregroundColor(.Button.active)
                }
            }
        }
    }
    
    private var content: some View {
        Group {
            if viewModel.rows.isNotEmpty {
                filtersList
            } else {
                emptyState
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                addButton
            }
        }
    }
    
    private var emptyState: some View {
        VStack {
            Spacer.fixedHeight(20)
            AnytypeText(
                Loc.EditSet.Popup.Filters.EmptyView.title,
                style: .uxCalloutRegular,
                color: .Text.secondary
            )
                .frame(height: 68)
            Spacer()
        }
    }
    
    private var filtersList: some View {
        List {
            ForEach(viewModel.rows) {
                if #available(iOS 15.0, *) {
                    row(with: $0)
                        .divider(leadingPadding: 60)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
                } else {
                    row(with: $0)
                }
            }
            .onDelete {
                viewModel.delete($0)
            }
        }
        .listStyle(.plain)
        .buttonStyle(BorderlessButtonStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .foregroundColor(Color.Button.active)
            }
        }
    }
    
    private func row(with configuration: SetFilterRowConfiguration) -> some View {
        SetFilterRow(configuration: configuration)
            .environment(\.editMode, $editMode)
    }
    
}
