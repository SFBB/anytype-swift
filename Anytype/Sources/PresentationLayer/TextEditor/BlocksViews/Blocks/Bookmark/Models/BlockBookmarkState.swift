import Services
import AnytypeCore

struct BlockBookmarkPayload: Hashable, Equatable {
    let source: AnytypeURL?
    let title: String
    let subtitle: String
    let imageObjectId: String
    let faviconObjectId: String
    let isArchived: Bool
}

extension BlockBookmarkPayload {
    
    init(bookmarkData: BlockBookmark, objectDetails: ObjectDetails?) {
        self = objectDetails.map { BlockBookmarkPayload(objectDetails: $0) }
            ?? BlockBookmarkPayload(blockBookmark: bookmarkData)
    }
    
    private init(objectDetails: ObjectDetails) {
        self.source = objectDetails.source
        self.title = objectDetails.title
        self.subtitle = objectDetails.description
        self.imageObjectId = objectDetails.picture
        self.faviconObjectId = objectDetails.iconImage
        self.isArchived = objectDetails.isArchived
    }
    
    init(blockBookmark: BlockBookmark) {
        self.source = blockBookmark.source
        self.title = blockBookmark.title
        self.subtitle = blockBookmark.theDescription
        self.imageObjectId = blockBookmark.imageHash
        self.faviconObjectId = blockBookmark.faviconHash
        self.isArchived = false
    }
}
