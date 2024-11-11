import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var standardButtonGroupDisable: Binding<Bool> = .constant(false)
}

struct AsyncStandardButtonGroup<Content: View>: View {
    
    @State private var buttonGroupDisable = false
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .environment(\.standardButtonGroupDisable, $buttonGroupDisable)
    }
}
