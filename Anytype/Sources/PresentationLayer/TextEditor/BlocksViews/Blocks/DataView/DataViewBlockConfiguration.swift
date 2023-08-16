import Services
import UIKit

struct DataViewBlockContent: Hashable {
    let title: String?
    let placeholder: String
    let subtitle: String
    let iconImage: Icon?
    let badgeTitle: String?
}

struct DataViewBlockConfiguration: BlockConfiguration {
    typealias View = DataViewBlockView

    let content: DataViewBlockContent
}
