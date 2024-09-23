import AnytypeCore

public protocol ObjectIconBuilderProtocol {
    func objectIcon(relations: BundledRelationsValueProvider) -> ObjectIcon?
    func profileIcon(iconImage: String, objectName: String) -> ObjectIcon?
}

public final class ObjectIconBuilder: ObjectIconBuilderProtocol {
    public init() { }
    
    public func objectIcon(relations: BundledRelationsValueProvider) -> ObjectIcon? {
        guard !relations.isDeleted else {
            return .deleted
        }
        
        if let objectIcon = icon(relations: relations) {
            return objectIcon
        }
        
        if DetailsLayout.fileAndMediaLayouts.contains(relations.layoutValue) {
            return fileIcon(
                fileMimeType: relations.fileMimeType,
                name: FileDetails.formattedFileName(relations.name, fileExt: relations.fileExt)
            )
        }
        
        if relations.layoutValue == .todo {
            return .todo(relations.isDone, relations.id)
        }
        
        return nil
    }
    
    public func profileIcon(iconImage: String, objectName: String) -> ObjectIcon? {
        if iconImage.isNotEmpty {
            return .profile(.imageId(iconImage))
        }
        
        return .profile(.name(objectName))
    }
    
    // MARK: - Private
    
    private func icon(relations: BundledRelationsValueProvider) -> ObjectIcon? {
        switch relations.layoutValue {
        case .basic, .set, .collection, .image, .objectType, .chat:
            return basicIcon(iconImage: relations.iconImage, iconEmoji: relations.iconEmoji)
        case .profile, .participant:
            return profileIcon(iconImage: relations.iconImage, objectName: relations.objectName)
        case .bookmark:
            return bookmarkIcon(iconImage: relations.iconImage)
        case .todo, .note, .file, .UNRECOGNIZED, .relation, .relationOption, .dashboard, .relationOptionsList,
                .audio, .video, .pdf, .date, .chatDerived:
            return nil
        case .space, .spaceView:
            return spaceIcon(iconImage: relations.iconImage, iconOptionValue: relations.iconOptionValue, objectName: relations.objectName)
        case .chat, .chatDerived:
            return nil
        }
    }
    
    private func basicIcon(iconImage: String, iconEmoji: Emoji?) -> ObjectIcon? {
        if iconImage.isNotEmpty {
            return .basic(iconImage)
        }
        
        if let iconEmoji = iconEmoji {
            return .emoji(iconEmoji)
        }
        
        return nil
    }
    
    private func bookmarkIcon(iconImage: String) -> ObjectIcon? {
        return iconImage.isNotEmpty ? .bookmark(iconImage) : nil
    }
    
    private func spaceIcon(iconImage: String, iconOptionValue: GradientId?, objectName: String) -> ObjectIcon? {
        if iconImage.isNotEmpty {
            return .space(.imageId(iconImage))
        }
        
        if let iconOptionValue {
            return .space(.gradient(iconOptionValue))
        }
        
        return .space(.name(objectName))
    }
    
    private func fileIcon(fileMimeType: String, name: String) -> ObjectIcon {
        return .file(mimeType: fileMimeType, name: name)
    }
}
