import SwiftUI
import AnytypeCore

// The vault bottom bar with unified search on: a search-field-shaped button that
// pushes the search screen, sharing the row with the create-channel menu (the
// native iOS 26 bottom-toolbar arrangement). Deliberately not `.searchable` -
// activating the native search UI mid-push wrecks the navigation transition.
struct VaultSearchBottomBar: View {

    // Quick capture takes the trailing slot here; creating a channel moves up
    // to the profile row, since capture is the far more frequent action
    let quickCaptureEnabled: Bool
    // Attention effect on the search entry until the user taps it once
    let highlightSearch: Bool
    let onTapSearch: () -> Void
    let onTapQuickCapture: () -> Void
    let onTapCreatePersonalChannel: () -> Void
    let onTapCreateGroupChannel: () -> Void
    let onTapJoinViaQrCode: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var glimmerStart = Date()

    var body: some View {
        GlassEffectContainerIOS26(spacing: 6) {
            HStack(spacing: 10) {
                searchButton
                if quickCaptureEnabled {
                    quickCaptureButton
                } else if #available(iOS 26.0, *) {
                    createMenu
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .fitIPadToReadableContentGuide()
    }

    private var quickCaptureButton: some View {
        Button {
            onTapQuickCapture()
        } label: {
            Image(systemName: "square.and.pencil")
                .foregroundStyle(Color.Control.primary)
                .frame(width: 44, height: 44)
                .barBackground
        }
        .buttonStyle(.plain)
        .accessibilityLabel("QuickCaptureButton")
    }

    private var searchButton: some View {
        Button {
            onTapSearch()
        } label: {
            HStack(spacing: 8) {
                Image(asset: .X18.search)
                    // Reduce Motion gets a still cue in place of the glimmer
                    .foregroundStyle(highlightSearch && reduceMotion ? Color.Control.accent100 : Color.Control.secondary)
                // Call to action for the unified search entry: it now covers every channel, objects and messages
                AnytypeText(Loc.UnifiedSearch.placeholder, style: .uxBodyRegular)
                    .foregroundStyle(Color.Text.secondary)
                Spacer()
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 12)
            // Part of the glass content, applied before the glass: anything layered after
            // glassEffect sits outside the glass element and makes the bar's scroll-edge
            // effect fall back to a hard dark band under the toolbar
            .overlay {
                if highlightSearch, !reduceMotion {
                    searchGlimmer
                }
            }
            .barBackground
            .fixTappableArea()
        }
        .buttonStyle(.plain)
    }

    // A light band sweeps the capsule every few seconds until the first tap. It is drawn as
    // glass content, so the material itself stays at rest (Apple: let glass rest, limit effects).
    // The periodic timeline hands each sweep a fresh band, which keeps the sweep Core
    // Animation-driven between ticks and restarts it after the app was in the background.
    private var searchGlimmer: some View {
        GeometryReader { geometry in
            TimelineView(.periodic(from: glimmerStart, by: SearchGlimmerBand.period)) { context in
                SearchGlimmerBand(travel: geometry.size.width, height: geometry.size.height)
                    .id(context.date)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
        }
        .clipShape(Capsule())
        .allowsHitTesting(false)
    }
    @available(iOS 26.0, *)
    private var createMenu: some View {
        Menu {
            CreateChannelMenuItems(
                onTapPersonal: { onTapCreatePersonalChannel() },
                onTapGroup: { onTapCreateGroupChannel() },
                onTapJoinQR: { onTapJoinViaQrCode() }
            )
        } label: {
            Image(systemName: "plus")
                .foregroundStyle(Color.Control.primary)
                .frame(width: 44, height: 44)
                .glassEffect(.regular.interactive(), in: .circle)
        }
    }
}

private extension View {
    @ViewBuilder
    var barBackground: some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: .capsule)
        } else {
            self
                .background(Color.Background.highlightedMedium)
                .clipShape(.capsule)
        }
    }
}

private struct SearchGlimmerBand: View {
    static let period: TimeInterval = 6

    let travel: CGFloat
    let height: CGFloat

    @State private var phase: CGFloat = -1

    var body: some View {
        Rectangle()
            // Normal blending on purpose: a blend mode inside a GlassEffectContainer forces an
            // offscreen compositing group, and the glass backdrop then renders as a flat card
            .fill(LinearGradient(
                colors: [.clear, .white.opacity(0.28), .clear],
                startPoint: .leading,
                endPoint: .trailing
            ))
            .frame(width: travel * 0.3, height: height * 3)
            .rotationEffect(.degrees(18))
            .offset(x: phase * travel)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4)) {
                    phase = 1
                }
            }
    }
}
