import Foundation
import Services

enum SupportedRelationFormat: String, Hashable, CaseIterable {
    case object
    case text
    case number
    case status
    case tag
    case date
    case file
    case checkbox
    case url
    case email
    case phone
}

extension SupportedRelationFormat: Identifiable {
    
    var id: String { self.rawValue }
    
}

extension SupportedRelationFormat {

    var iconAsset: ImageAsset {
        switch self {
        case .text: return RelationFormat.longText.iconAsset
        case .tag: return RelationFormat.tag.iconAsset
        case .status:  return RelationFormat.status.iconAsset
        case .number:  return RelationFormat.number.iconAsset
        case .date:  return RelationFormat.date.iconAsset
        case .file:  return RelationFormat.file.iconAsset
        case .object:  return RelationFormat.object.iconAsset
        case .checkbox: return RelationFormat.checkbox.iconAsset
        case .url:  return RelationFormat.url.iconAsset
        case .email: return RelationFormat.email.iconAsset
        case .phone: return RelationFormat.phone.iconAsset
        }
    }

    var title: String {
        switch self {
        case .text: return Loc.Relation.Format.Text.title
        case .number: return Loc.Relation.Format.Number.title
        case .status: return Loc.Relation.Format.Status.title
        case .date: return Loc.Relation.Format.Date.title
        case .file: return Loc.Relation.Format.FileMedia.title
        case .checkbox: return Loc.Relation.Format.Checkbox.title
        case .url: return Loc.Relation.Format.Url.title
        case .email: return Loc.Relation.Format.Email.title
        case .phone: return Loc.Relation.Format.Phone.title
        case .tag: return Loc.Relation.Format.Tag.title
        case .object: return Loc.Relation.Format.Object.title
        }
    }
}
