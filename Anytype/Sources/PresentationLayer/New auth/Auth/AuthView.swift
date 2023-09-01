import SwiftUI

struct AuthView: View {
    
    @ObservedObject var model: AuthViewModel
    
    var body: some View {
        AuthBackgroundView(url: model.videoUrl()) {
            content
                .navigationBarHidden(true)
                .opacity(model.opacity)
                .onAppear {
                    model.onAppear()
                }
                .background(TransparentBackground())
                .fitIPadToReadableContentGuide()
                .preferredColorScheme(.dark)
        }
    }
    
    private var content: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            greetings
            Spacer()
            buttons
            Spacer.fixedHeight(16)
            privacyPolicy
            Spacer.fixedHeight(14)
        }
        .padding(.horizontal, 30)
        .ignoresSafeArea(.keyboard)
    }
    
    private var greetings: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(asset: .theEverythingApp)
                .onTapGesture(count: 10) {
                    model.showDebugMenu.toggle()
                }
                .sheet(isPresented: $model.showDebugMenu) {
                    model.onDebugMenuAction()
                }
            
            Spacer.fixedHeight(20)
            
            AnytypeText(Loc.Auth.Welcome.subtitle, style: .uxCalloutRegular, color: .Auth.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, UIDevice.isPad ? 75 : 30)
        }
    }

    private var buttons: some View {
        HStack(spacing: 13) {
            StandardButton(
                Loc.Auth.join,
                style: .primaryLarge,
                action: {
                    model.onJoinButtonTap()
                }
            )
            .colorScheme(.light)
            .addEmptyNavigationLink(destination: model.onJoinAction(), isActive: $model.showJoinFlow)
            
            StandardButton(
                Loc.Auth.logIn,
                style: .secondaryLarge,
                action: {
                    model.onLoginButtonTap()
                }
            )
            .addEmptyNavigationLink(destination: model.onLoginAction(), isActive: $model.showLoginFlow)
        }
    }
    
    private var privacyPolicy: some View {
        AnytypeText(
            Loc.Auth.Caption.Privacy.text(AboutApp.termsLink, AboutApp.privacyLink),
            style: .authCaption,
            color: .Auth.caption
        )
        .multilineTextAlignment(.center)
        .padding(.horizontal, 28)
        .accentColor(.Text.secondary)
        .environment(\.openURL, OpenURLAction { url in
            model.onUrlTapAction(url)
            return .handled
        })
    }
}

struct AuthView_Previews : PreviewProvider {
    static var previews: some View {
        AuthView(
            model: AuthViewModel(output: nil)
        )
    }
}
