import Foundation
import Services
import AnytypeCore

protocol BlockActionHandlerProtocol: AnyObject {
    func turnInto(_ style: BlockText.Style, blockId: String)
    @discardableResult
    func turnIntoPage(blockId: String) async throws -> String?
    
    func setTextColor(_ color: BlockColor, blockIds: [String])
    func setBackgroundColor(_ color: BlockBackgroundColor, blockIds: [String])
    func duplicate(blockId: String)
    func fetch(url: AnytypeURL, blockId: String) async throws
    func checkbox(selected: Bool, blockId: String)
    func toggle(blockId: String)
    func setAlignment(_ alignment: LayoutAlignment, blockIds: [String])
    func delete(blockIds: [String])
    func moveToPage(blockId: String, pageId: String)
    func createEmptyBlock(parentId: String)
    func addLink(targetDetails: ObjectDetails, blockId: String)
    func changeMarkup(blockIds: [String], markType: MarkupType)
    func addBlock(_ type: BlockContentType, blockId: String, blockText: NSAttributedString?, position: BlockPosition?)
    func toggleWholeBlockMarkup(
        _ attributedString: NSAttributedString?,
        markup: MarkupType,
        info: BlockInformation
    ) -> NSAttributedString?
    func upload(blockId: String, filePath: String) async throws
    func createPage(targetId: String, spaceId: String, typeUniqueKey: ObjectTypeUniqueKey, templateId: String) async throws -> String?

    func setObjectType(type: ObjectType) async throws
    func setObjectSetType() async throws
    func setObjectCollectionType() async throws
    func applyTemplate(objectId: String, templateId: String) async throws
    func changeText(_ text: NSAttributedString, blockId: String)
    func setTextStyle(
        _ attribute: MarkupType,
        range: NSRange,
        blockId: String,
        currentText: NSAttributedString?,
        contentType: BlockContentType
    )
    func uploadMediaFile(uploadingSource: FileUploadingSource, type: MediaPickerContentType, blockId: String)
    func uploadFileAt(localPath: String, blockId: String)
    func createAndFetchBookmark(
        targetID: String,
        position: BlockPosition,
        url: AnytypeURL
    ) async throws
    func setAppearance(blockId: String, appearance: BlockLink.Appearance)
    func createTable(
        blockId: String,
        rowsCount: Int,
        columnsCount: Int,
        blockText: SafeSendable<NSAttributedString?>
    ) async throws -> String
    func pasteContent()
}

extension BlockActionHandlerProtocol {
    func addBlock(_ type: BlockContentType, blockId: String, blockText: NSAttributedString? = nil) {
        addBlock(type, blockId: blockId, blockText: blockText, position: nil)
    }
}
