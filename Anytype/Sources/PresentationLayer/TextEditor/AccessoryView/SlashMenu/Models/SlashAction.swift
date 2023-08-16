import UIKit

enum SlashAction {
    case style(SlashActionStyle)
    case media(SlashActionMedia)
    case objects(SlashActionObject)
    case relations(SlashActionRelations)
    case other(SlashActionOther)
    case actions(BlockAction)
    case color(BlockColor)
    case background(BlockBackgroundColor)
    case alignment(SlashActionAlignment)

    var displayData: NewSlashMenuItemDisplayData {
        switch self {
        case let .actions(action):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(action.iconAsset), title: action.title)
            )
        case let .alignment(alignment):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(alignment.iconAsset), title: alignment.title)
                )
        case let .background(color):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .image(color.image), title: color.title)
            )
        case let .color(color):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .image(color.image), title: color.title)
            )
        case let .media(media):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(media.iconAsset), title: media.title, subtitle: media.subtitle)
            )
        case let .style(style):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(style.imageAsset), title: style.title, subtitle: style.subtitle, expandedIcon: true)
            )
        case let .other(other):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(other.iconAsset), title: other.title, searchAliases: other.searchAliases)
            )
        case let .objects(object):
            switch object {
            case .linkTo:
                return .titleSubtitleDisplayData(
                    SlashMenuItemDisplayData(
                        iconData: .asset(.X40.linkToExistingObject),
                        title: Loc.linkToObject,
                        subtitle: Loc.linkToExistingObject
                    )
                )
            case .objectType(let objectType):
                return .titleSubtitleDisplayData(
                    SlashMenuItemDisplayData(
                        iconData: objectType.objectIconImageWithPlaceholder,
                        title: objectType.name,
                        subtitle: objectType.description
                    )
                )
            }
        case let .relations(relationAction):
            switch relationAction {
            case .newRealtion:
                return .titleSubtitleDisplayData(
                    SlashMenuItemDisplayData(
                        iconData: .asset(.X24.plus),
                        title: Loc.newRelation
                    )
                )
            case .relation(let relation):
                return  .relationDisplayData(relation)
            }
        }
    }
}
