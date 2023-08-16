struct SlashMenuItemDisplayData {
    let iconData: Icon
    let title: String
    let subtitle: String?
    let searchAliases: [String]
    let expandedIcon: Bool
    let customPredicate: ((String) -> SlashAction?)?
    
    init(
        iconData: Icon,
        title: String,
        subtitle: String? = nil,
        searchAliases: [String] = [],
        expandedIcon: Bool = false,
        customPredicate: ((String) -> SlashAction?)? = nil
    ) {
        self.iconData = iconData
        self.title = title
        self.subtitle = subtitle
        self.searchAliases = searchAliases
        self.expandedIcon = expandedIcon
        self.customPredicate = customPredicate
    }
}


enum NewSlashMenuItemDisplayData: ComparableDisplayData {
    case titleSubtitleDisplayData(SlashMenuItemDisplayData)
    case relationDisplayData(Relation)

    var title: String? {
        switch self {
        case let .titleSubtitleDisplayData(slashMenuItemDisplayData):
            return slashMenuItemDisplayData.title
        case let .relationDisplayData(relation):
            return relation.name
        }
    }

    var subtitle: String? {
        switch self {
        case let .titleSubtitleDisplayData(slashMenuItemDisplayData):
            return slashMenuItemDisplayData.subtitle
        case .relationDisplayData:
            return nil
        }
    }
    
    var aliases: [String]? {
        switch self {
        case let .titleSubtitleDisplayData(slashMenuItemDisplayData):
            return slashMenuItemDisplayData.searchAliases
        case .relationDisplayData:
            return nil
        }
    }
}
