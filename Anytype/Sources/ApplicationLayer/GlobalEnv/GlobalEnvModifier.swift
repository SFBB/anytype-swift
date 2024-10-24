import Foundation
import SwiftUI

private struct GlobalEnvModifier: ViewModifier {
    
    @State private var windowHolder = WindowHolder(window: nil)
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    
    func body(content: Content) -> some View {
        content
            .readWindowHolder($windowHolder)
            .setKeyboardDismissEnv(window: windowHolder.window)
            .setPresentedDismissEnv(window: windowHolder.window)
            .setAppInterfaceStyleEnv(window: windowHolder.window)
            // Legacy :(
            .onChange(of: windowHolder) { newValue in
                ViewControllerProvider.shared.sceneWindow = newValue.window
                newValue.window?.overrideUserInterfaceStyle = userDefaults.userInterfaceStyle
            }
            .onAppear {
                ToastPresenter.shared = ToastPresenter()
            }
            
    }
}

extension View {
    func setupGlobalEnv() -> some View {
        self.modifier(GlobalEnvModifier())
    }
}
