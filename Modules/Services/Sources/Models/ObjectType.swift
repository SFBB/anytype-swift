//
//  ObjectType.swift
//  Services
//
//  Created by Konstantin Mordan on 10.06.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import ProtobufMessages
import AnytypeCore

public struct ObjectType: Equatable, Hashable, Codable {
    
    public let id: String
    public let name: String
    public let iconEmoji: Emoji
    public let description: String
    public let hidden: Bool
    public let readonly: Bool
    public let isArchived: Bool
    public let isDeleted: Bool
    public let sourceObject: String
    public let spaceId: String
    public let uniqueKey: ObjectTypeUniqueKey
    public let defaultTemplateId: String
    
    public let recommendedRelations: [ObjectId]
    public let recommendedLayout: DetailsLayout?
    
    public init(
        id: String,
        name: String,
        iconEmoji: Emoji,
        description: String,
        hidden: Bool,
        readonly: Bool,
        isArchived: Bool,
        isDeleted: Bool,
        sourceObject: String,
        spaceId: String,
        uniqueKey: ObjectTypeUniqueKey,
        defaultTemplateId: String,
        recommendedRelations: [ObjectId],
        recommendedLayout: DetailsLayout?
    ) {
        self.id = id
        self.name = name
        self.iconEmoji = iconEmoji
        self.description = description
        self.hidden = hidden
        self.readonly = readonly
        self.isArchived = isArchived
        self.isDeleted = isDeleted
        self.sourceObject = sourceObject
        self.spaceId = spaceId
        self.uniqueKey = uniqueKey
        self.defaultTemplateId = defaultTemplateId
        self.recommendedRelations = recommendedRelations
        self.recommendedLayout = recommendedLayout
    }
}

extension ObjectType {
    
    public init(details: ObjectDetails) {
        self.init(
            id: details.id,
            name: details.name,
            iconEmoji: details.iconEmoji ?? Emoji.default,
            description: details.description,
            hidden: details.isHidden,
            readonly: details.isReadonly,
            isArchived: details.isArchived,
            isDeleted: details.isDeleted,
            sourceObject: details.sourceObject,
            spaceId: details.spaceId,
            uniqueKey: details.uniqueKeyValue,
            defaultTemplateId: details.defaultTemplateId,
            recommendedRelations: details.recommendedRelations,
            recommendedLayout: details.recommendedLayoutValue
        )
    }
    
}

extension ObjectType {
    public var isTemplateType: Bool {
        uniqueKey == .template
    }
    
    public var isSetType: Bool {
        uniqueKey == .set
    }
    
    public var isCollectionType: Bool {
        uniqueKey == .collection
    }
    
    public var isNoteType: Bool {
        uniqueKey == .note
    }
}
