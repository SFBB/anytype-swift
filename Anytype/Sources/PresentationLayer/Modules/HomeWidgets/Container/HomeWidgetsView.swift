import Foundation
import SwiftUI

struct HomeWidgetsView: View {
    
    @StateObject var model: HomeWidgetsViewModel
    @State var dndState = DragState()
    
    var body: some View {
        ZStack {
            DashboardWallpaper(wallpaper: model.wallpaper)
            VerticalScrollViewWithOverlayHeader {
                HomeTopShadow()
            } content: {
                VStack(spacing: 12) {
                    ForEach(model.models) { rowModel in
                        rowModel.provider.view
                    }
                    HomeEditButton(text: Loc.Widgets.Actions.editWidgets) {
                        model.onEditButtonTap()
                    }
                    .opacity(model.hideEditButton ? 0 : 1)
                    .animation(.default, value: model.hideEditButton)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .opacity(model.dataLoaded ? 1 : 0)
                .animation(.default.delay(0.3), value: model.dataLoaded)
                .fitIPadToReadableContentGuide()
            }
            .animation(.default, value: model.models.count)
        }
//        .safeAreaInset(edge: .bottom, spacing: 20) {
//            model.bottomPanelProvider.view
//                .fitIPadToReadableContentGuide()
//        }
        .onAppear {
            model.onAppear()
        }
        .onDisappear {
            model.onDisappear()
        }
        .navigationBarHidden(true)
        .anytypeStatusBar(style: .lightContent)
//        .ignoresSafeArea(.all, edges: .bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .anytypeVerticalDrop(data: model.models, state: $dndState) { from, to in
            model.dropUpdate(from: from, to: to)
        } dropFinish: { from, to in
            model.dropFinish(from: from, to: to)
        }
        .iOS16navBarAdapter(.light)
    }
}

extension View {
    func iOS16navBarAdapter(_ colorScheme: ColorScheme) -> some View {
            if #available(iOS 16, *) {
                return self
//                    .toolbarBackground(Color.navigationBar, for: .navigationBar)
//                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarColorScheme(colorScheme, for: .navigationBar)
            } else {
                return self
            }
        }
}
