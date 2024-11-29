import SwiftUI

struct SetFiltersTextView: View {
    @StateObject private var viewModel: SetFiltersTextViewModel
    
    init(filter: SetFilter, onApplyText: @escaping (String) -> Void) {
        _viewModel = StateObject(wrappedValue: SetFiltersTextViewModel(filter: filter, onApplyText: onApplyText))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(10)
            textField
            Spacer.fixedHeight(10)
            button
        }
        .padding(.horizontal, 20)
        .background(Color.Background.secondary)
    }
    
    var textField: some View {
        AutofocusedTextField(
            placeholder: Loc.EditSet.Popup.Filters.TextView.placeholder,
            font: .uxBodyRegular,
            text: $viewModel.input
        )
        .foregroundColor(.Text.primary)
        .keyboardType(viewModel.keyboardType)
        .frame(height: 48)
        .divider()
    }
    
    private var button: some View {
        StandardButton(Loc.apply, style: .primaryLarge) {
            viewModel.handleText()
        }
        .disabled(viewModel.input.isEmpty)
        .padding(.top, 10)
    }
}
