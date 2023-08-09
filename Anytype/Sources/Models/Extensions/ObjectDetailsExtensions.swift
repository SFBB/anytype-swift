import Services
import UIKit
import AnytypeCore

extension BundledRelationsValueProvider {
    
    // MARK: - Icon
    
    var icon: ObjectIcon? {
        switch layoutValue {
        case .basic, .set, .collection, .image, .objectType:
            return basicIcon
        case .profile:
            return profileIcon
        case .bookmark:
            return bookmarkIcon
        case .todo, .note, .file, .unknown, .relation, .relationOption, .dashboard, .relationOptionList, .database:
            return nil
        case .space:
            return spaceIcon
        }
    }
    
    private var basicIcon: ObjectIcon? {
        if let iconImageHash = self.iconImage {
            return .basic(iconImageHash.value)
        }
        
        if let iconEmoji = self.iconEmoji {
            return .emoji(iconEmoji)
        }
        
        return nil
    }
    
    private var profileIcon: ObjectIcon? {
        if let iconImageHash = self.iconImage {
            return .profile(.imageId(iconImageHash.value))
        }
        
        if let iconOption, let gradiendId = GradientId(iconOption) {
            return .profile(.gradient(gradiendId))
        }
        
        return title.first.flatMap { .profile(.character($0)) }
    }
    
    private var bookmarkIcon: ObjectIcon? {
        return iconImage.map { .bookmark($0.value) }
    }
    
    private var spaceIcon: ObjectIcon? {
        if let basicIcon {
            return basicIcon
        }
        
        if let iconOption, let gradiendId = GradientId(iconOption) {
            return .space(.gradient(gradiendId))
        }
        
        return title.first.flatMap { .space(.character($0)) }
    }
    
    private var fileIcon: Icon {
        return .asset(FileIconBuilder.convert(mime: fileMimeType, fileName: name))
    }
    
    // MARK: - Cover
    
    var documentCover: DocumentCover? {
        guard !coverId.isEmpty else { return nil }
        
        switch coverTypeValue {
        case .none:
            return nil
        case .uploadedImage:
            return DocumentCover.imageId(coverId)
        case .color:
            return CoverColor.allCases
                .first { $0.data.name == coverId }
                .flatMap { .color($0.uiColor) }
        case .gradient:
            return CoverGradient.allCases
                .first { $0.data.name == coverId }
                .flatMap { .gradient($0.gradientColor) }
        case .unsplash:
            return DocumentCover.imageId(coverId)
        }
    }
    
    var objectIconImage: Icon? {
        guard !isDeleted else {
            return .asset(.ghost)
        }
        
        if let icon = icon {
            return .object(icon)
        }
        
        if layoutValue == .file {
            return fileIcon
        }
        
        if layoutValue == .todo {
            return .object(.todo(isDone))
        }
        
        return nil
    }
    
    var objectIconImageWithPlaceholder: Icon {
        return objectIconImage ?? .object(.placeholder(title.first))
    }
    
    var objectType: ObjectType {
        guard !isDeleted, type.isNotEmpty else {
            return ObjectTypeProvider.shared.defaultObjectType
        }
        
        let parsedType = ObjectTypeProvider.shared.objectType(id: type)
        return parsedType ?? ObjectTypeProvider.shared.deleteObjectType(id: type)
    }
    
    var editorViewType: EditorViewType {
        switch layoutValue {
        case .basic, .profile, .todo, .note, .bookmark, .space, .file, .image, .objectType, .unknown, .relation, .relationOption, .dashboard, .relationOptionList, .database:
            return .page
        case .set, .collection:
            return .set
        }
    }
    
    var isCollection: Bool {
        return layoutValue == .collection
    }
    
    var isSupportedForEdit: Bool {
        return DetailsLayout.supportedForEditLayouts.contains(layoutValue)
    }
    
    var isNotDeletedAndVisibleForEdit: Bool {
        return !isDeleted && !isArchived && DetailsLayout.visibleLayouts.contains(layoutValue)
    }
    
    var isNotDeletedAndSupportedForEdit: Bool {
        return !isDeleted && !isArchived && isSupportedForEdit
    }
    
    var canMakeTemplate: Bool {
        isTemplatesAvailable(for: layoutValue)
    }
    
    var setIsTemplatesAvailable: Bool {
        guard let recommendedLayout = recommendedLayout,
              let recommendedLayout = DetailsLayout(rawValue: recommendedLayout) else {
            return false
        }
        
        return isTemplatesAvailable(for: recommendedLayout)
    }
    
    private func isTemplatesAvailable(for layout: DetailsLayout) -> Bool {
        return !DetailsLayout.layoutsWithoutTemplate.contains(layout) &&
        DetailsLayout.pageLayouts.contains(layout)
    }
}
