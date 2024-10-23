public final class SearchFiltersBuilder {
    
    public static func build(isArchived: Bool) -> [DataviewFilter] {
        .builder {
            SearchHelper.notHiddenFilters(isArchive: isArchived)
        }
    }
    
    public static func build(isArchived: Bool, layouts: [DetailsLayout]) -> [DataviewFilter] {
        var filters = build(isArchived: isArchived)
        filters.append(SearchHelper.layoutFilter(layouts))
        filters.append(SearchHelper.templateScheme(include: false))
        return filters
    }
}
