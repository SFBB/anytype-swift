import Foundation
import Services
import AnytypeCore

enum WidgetSource: Equatable, Hashable, Sendable {
    case object(ObjectDetails)
    case library(AnytypeWidgetId)
}

extension WidgetSource {
    
    var sourceId: String {
        switch self {
        case .object(let objectDetails):
            return objectDetails.id
        case .library(let library):
            return library.rawValue
        }
    }    
}

extension WidgetSource {
    var availableWidgetLayout: [BlockWidget.Layout] {
        switch self {
        case .object(let objectDetails):
            return objectDetails.availableWidgetLayout
        case .library(let library):
            switch library {
            case .favorite, .recent, .recentOpen:
                return [.compactList, .list, .tree]
            case .sets, .collections:
                return [.compactList, .list]
            }
        }
    }
}

extension ObjectDetails {
    var availableWidgetLayout: [BlockWidget.Layout] {
        switch editorViewType {
        case .page:
           return [.tree, .link]
        case .list:
            return [.view, .compactList, .list, .link]
        case .date:
            return [.link]
        case .type:
            return []
        }
    }
}
