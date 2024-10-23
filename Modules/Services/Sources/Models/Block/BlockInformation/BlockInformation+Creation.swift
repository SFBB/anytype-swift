public extension BlockInformation {
    
    static var emptyText: BlockInformation {
        empty(content: .text(.empty(contentType: .text)))
    }
    
    static func empty(
        id: String = "", content: BlockContent
    ) -> BlockInformation {
        BlockInformation(
            id: id,
            content: content,
            backgroundColor: nil,
            horizontalAlignment: .left,
            childrenIds: [],
            configurationData: BlockInformationMetadata(backgroundColor: .default),
            fields: [:]
        )
    }
    
    static func emptyLink(targetId: String, spaceId: String) -> BlockInformation {
        let content: BlockContent = .link(
            .init(
                targetBlockID: targetId,
                spaceId: spaceId,
                appearance: .init(iconSize: .small, cardStyle: .card, description: .none, relations: [])
            )
        )

        return BlockInformation.empty(content: content)
    }
    
    static func bookmark(targetId: String) -> BlockInformation {
        let content: BlockContent = .bookmark(.empty(targetObjectID: targetId))
        return BlockInformation.empty(content: content)
    }
    
    static func file(fileDetails: FileDetails) -> BlockInformation {
        let content = BlockContent.file(
            BlockFile(
                metadata: FileMetadata(
                    targetObjectId: fileDetails.id
                ),
                contentType: fileDetails.fileContentType,
                state: .done
            )
        )
        return BlockInformation.empty(content: content)
    }
}
