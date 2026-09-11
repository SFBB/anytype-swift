import CoreGraphics

/// Geometry shared by the vault's bottom bar and a space's bottom panel.
///
/// One replaces the other across a navigation pop, and the compose button exists on both. It
/// only reads as the same button staying put if both bars size and inset their controls
/// identically, so these numbers belong to the pair rather than to either bar. The two are
/// anchored by different mechanisms, a safe area bar against a bottom-pinned overlay, but both
/// measure this bottom inset from the same edge.
enum HomeBottomBarMetrics {
    static let controlHeight: CGFloat = 48
    static let horizontalInset: CGFloat = 24
    static let bottomInset: CGFloat = 0
}
