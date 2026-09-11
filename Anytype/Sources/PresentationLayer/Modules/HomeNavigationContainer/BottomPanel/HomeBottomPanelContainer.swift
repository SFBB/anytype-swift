import Foundation
import SwiftUI

struct HomeBottomPanelContainer<Content: View, BottomContent: View>: View {
    
    @State private var bottomPanelState = HomeBottomPanelState()
    @State private var popProgress = AnytypeNavigationPopProgress()

    private var content: Content
    private var bottomPanel: BottomContent
    @Binding private var path: HomePath
    @State private var bottomSize: CGSize = .zero
    
    init(path: Binding<HomePath>, @ViewBuilder content: () -> Content, @ViewBuilder bottomPanel: () -> BottomContent) {
        self._path = path
        self.content = content()
        self.bottomPanel = bottomPanel()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .anytypeNavigationPanelSize(bottomSize)
            
            bottomPanel
                .readSize {
                    bottomSize = $0
                }
                .anytypeIgnoreBottomSafeArea()
                .opacity(bottomPanelOpacity)
                .allowsHitTesting(bottomPanelOpacity > 0)
                .animation(.default, value: path.count)
        }
        .homeBottomPanelState($bottomPanelState)
        .anytypeNavigationPopProgress(popProgress)
    }

    // The panel sits outside the navigation stack, so a back swipe would otherwise leave it
    // hanging over the revealed screen until the gesture commits. While a swipe is in flight,
    // cross-fade towards what the destination screen asks for, in step with the finger. The
    // revealed screen's own bar fades in against this, so the two trade places under the thumb.
    private var bottomPanelOpacity: Double {
        let current = opacity(for: path.path.last)

        guard popProgress.isPopping else { return current }

        let destination = opacity(for: path.path.dropLast().last)
        return current + (destination - current) * Double(popProgress.value)
    }

    private func opacity(for item: AnyHashable?) -> Double {
        guard let item, let hidden = bottomPanelState.hidden(for: item) else { return 1 }
        return hidden ? 0 : 1
    }
}
