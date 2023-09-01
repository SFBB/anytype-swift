import SwiftUI

struct SetSortsListView: View {
    @StateObject var viewModel: SetSortsListViewModel
    
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        DragIndicator()
        NavigationView {
            content
                .navigationTitle(Loc.EditSet.Popup.Sorts.NavigationView.title)
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
                sortsList
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
                Loc.EditSet.Popup.Sorts.EmptyView.title,
                style: .uxCalloutRegular,
                color: .Text.secondary
            )
                .frame(height: 68)
            Spacer()
        }
    }
    
    private var sortsList: some View {
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
            .onMove { from, to in
                viewModel.move(from: from, to: to)
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
    
    private func row(with configuration: SetSortRowConfiguration) -> some View {
        SetSortRow(configuration: configuration)
            .environment(\.editMode, $editMode)
    }
    
}
