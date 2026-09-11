import Foundation
import SwiftUI

/// How far an in-flight back swipe has travelled: 0 at rest, 1 when the top screen has fully
/// slid off. Published by `AnytypeNavigationView` so chrome that lives outside the navigation
/// stack can cross-fade in step with the finger instead of snapping when the gesture commits.
@Observable
final class AnytypeNavigationPopProgress {

    /// True from the first moment of a back swipe until the navigation path has caught up with
    /// its outcome. Readers should interpolate towards the destination screen only while set.
    private(set) var isPopping = false

    /// 0...1 fraction of the screen width the swipe has covered.
    private(set) var value: CGFloat = 0

    func update(_ value: CGFloat) {
        isPopping = true
        self.value = min(max(value, 0), 1)
    }

    /// The finger has lifted and UIKit is animating the remainder itself. Run out the rest of
    /// the progress on a comparable clock so the cross-fade lands with the slide.
    func settle(cancelled: Bool, duration: TimeInterval) {
        guard isPopping else { return }

        let target: CGFloat = cancelled ? 0 : 1
        let remaining = abs(target - value)

        withAnimation(.easeOut(duration: duration * remaining)) {
            value = target
        }
    }

    /// The navigation path now reflects the finished pop, so the interpolation has nothing left
    /// to say. This has to happen in the same transaction as the path update: readers switch
    /// from the interpolated value to the settled one, and a gap between the two would flash.
    func reset() {
        guard isPopping else { return }

        isPopping = false
        value = 0
    }
}

extension EnvironmentValues {
    @Entry var anytypeNavigationPopProgress = AnytypeNavigationPopProgress()
}

extension View {

    func anytypeNavigationPopProgress(_ progress: AnytypeNavigationPopProgress) -> some View {
        environment(\.anytypeNavigationPopProgress, progress)
    }

    /// Fades this in as a back swipe reveals the screen it belongs to, against the chrome of the
    /// screen being left behind fading out. Fully visible whenever no swipe is in flight, so a
    /// screen that is simply on top is unaffected.
    func anytypeNavigationPopRevealFade() -> some View {
        modifier(AnytypeNavigationPopRevealFade())
    }
}

private struct AnytypeNavigationPopRevealFade: ViewModifier {

    @Environment(\.anytypeNavigationPopProgress) private var popProgress

    func body(content: Content) -> some View {
        content.opacity(popProgress.isPopping ? Double(popProgress.value) : 1)
    }
}
