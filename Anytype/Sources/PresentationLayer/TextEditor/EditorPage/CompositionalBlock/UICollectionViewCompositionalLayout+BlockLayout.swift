import UIKit

// https://stackoverflow.com/questions/32082726/the-behavior-of-the-uicollectionviewflowlayout-is-not-defined-because-the-cell
final class CellCollectionViewCompositionalLayout: UICollectionViewCompositionalLayout {
    override func shouldInvalidateLayout(forBoundsChange: CGRect) -> Bool {
        return true
    }
}

extension UICollectionViewCompositionalLayout {
    static func flexibleView(
        widthDimension: NSCollectionLayoutDimension = .estimated(20),
        heightDimension: NSCollectionLayoutDimension = .estimated(32),
        interItemSpacing: NSCollectionLayoutSpacing = .fixed(6),
        groundEdgeSpacing: NSCollectionLayoutEdgeSpacing,
        interGroupSpacing: CGFloat = 4
    ) -> UICollectionViewCompositionalLayout {
        CellCollectionViewCompositionalLayout(
            sectionProvider: {
                (sectionIndex: Int, layoutEnvironment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in


                let itemSize = NSCollectionLayoutSize(
                    widthDimension: widthDimension,
                    heightDimension: heightDimension
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(layoutEnvironment.container.contentSize.width),
                    heightDimension: heightDimension
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.edgeSpacing = groundEdgeSpacing
                group.interItemSpacing = interItemSpacing

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = interGroupSpacing

                return section
            },
            configuration: UICollectionViewCompositionalLayoutConfiguration()
        )
    }
}

extension NSCollectionLayoutEdgeSpacing {
    static var defaultBlockEdgeSpacing: NSCollectionLayoutEdgeSpacing {
        NSCollectionLayoutEdgeSpacing(
            leading: nil,
            top: nil,
            trailing: nil,
            bottom: NSCollectionLayoutSpacing.fixed(0)
        )
    }
}
