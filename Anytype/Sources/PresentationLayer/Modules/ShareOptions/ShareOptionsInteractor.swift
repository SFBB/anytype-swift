import Foundation
import Services
import SharedContentManager

protocol ShareOptionsInteractorProtocol: AnyObject {
    func saveContent(saveOptions: SharedSaveOptions, content: SharedContent) async throws
}

final class ShareOptionsInteractor: ShareOptionsInteractorProtocol {
    
    private let blockService: BlockServiceProtocol
    private let bookmarkService: BookmarkServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private let pageRepository: PageRepositoryProtocol
    private let fileService: FileActionsServiceProtocol
    private let documentProvider: DocumentsProviderProtocol
    private let pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol
    
    init(
        blockService: BlockServiceProtocol,
        bookmarkService: BookmarkServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        pageRepository: PageRepositoryProtocol,
        fileService: FileActionsServiceProtocol,
        documentProvider: DocumentsProviderProtocol,
        pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol
    ) {
        self.blockService = blockService
        self.bookmarkService = bookmarkService
        self.objectActionsService = objectActionsService
        self.pageRepository = pageRepository
        self.fileService = fileService
        self.documentProvider = documentProvider
        self.pasteboardMiddlewareService = pasteboardMiddlewareService
    }
    
    func saveContent(saveOptions: SharedSaveOptions, content: SharedContent) async throws {
        switch saveOptions {
        case .container(let spaceId, let linkToObject):
            try await saveNewContainer(spaceId: spaceId, linkToObject: linkToObject, content: content)
        case .newObject(let spaceId, let linkToObject):
            await saveNewObject(spaceId: spaceId, linkToObject: linkToObject, content: content)
        case .blocks(let spaceId, let addToObject):
            await saveNewBlock(spaceId: spaceId, addToObject: addToObject, content: content)
        }
    }
    
    // MARK: - Private
    
    private func saveNewContainer(spaceId: String, linkToObject: ObjectDetails?, content: SharedContent) async throws {
        let noteObject = try await pageRepository.createPage(
            name: content.title ?? "",
            typeUniqueKey: .note,
            shouldDeleteEmptyObject: false,
            shouldSelectType: false,
            shouldSelectTemplate: false,
            spaceId: spaceId,
            origin: .sharingExtension,
            templateId: nil
        )
        await saveNewBlock(spaceId: spaceId, addToObject: noteObject, content: content)
        if let linkToObject {
            try await linkTo(object: linkToObject, newObjectId: noteObject.id, blockInformation: BlockInformation.emptyLink(targetId: noteObject.id))
        }
    }
    
    private func saveNewObject(spaceId: String, linkToObject: ObjectDetails?, content: SharedContent) async {
        for contentItem in content.items {
            do {
                
                let newObjectId: String
                let blockInformation: BlockInformation
                
                switch contentItem {
                case let .text(text):
                    newObjectId = try await createNoteObject(text: text, spaceId: spaceId).id
                    blockInformation = BlockInformation.emptyLink(targetId: newObjectId)
                case let .url(url):
                    newObjectId = try await createBookmarkObject(url: url, spaceId: spaceId).id
                    blockInformation = BlockInformation.bookmark(targetId: newObjectId)
                case let .file(url):
                    newObjectId = try await fileService.uploadFileObject(spaceId: spaceId, data: FileData(path: url.relativePath, isTemporary: false)).id
                    blockInformation = BlockInformation.emptyLink(targetId: newObjectId)
                }
                
                if let linkToObject {
                    try await linkTo(object: linkToObject, newObjectId: newObjectId, blockInformation: blockInformation)
                }
            } catch {}
        }
    }
    
    private func saveNewBlock(spaceId: String, addToObject: ObjectDetails, content: SharedContent) async {
        for contentItem in content.items {
            do {
                switch contentItem {
                case let .text(text):
                    try await createTextBlock(text: text, addToObject: addToObject)
                case let .url(url):
                    try await createBookmarkBlock(url: url, addToObject: addToObject)
                case let .file(url):
                    try await createFileBlock(fileURL: url, addToObject: addToObject)
                }
            } catch {}
        }
    }
    
    private func createBookmarkObject(url: URL, spaceId: BlockId) async throws -> ObjectDetails {
        let newBookmark = try await bookmarkService.createBookmarkObject(
            spaceId: spaceId,
            url: url.absoluteString,
            origin: .sharingExtension
        )
        try await bookmarkService.fetchBookmarkContent(bookmarkId: newBookmark.id, url: url.absoluteString)
        
        AnytypeAnalytics.instance().logCreateObject(
            objectType: .object(typeId: ObjectTypeUniqueKey.bookmark.value),
            route: .sharingExtension
        )
        return newBookmark
    }

    private func createNoteObject(text: String, spaceId: BlockId) async throws -> ObjectDetails {
        let newObject = try await pageRepository.createPage(
            name: "", // TODO: Check it
            typeUniqueKey: .note,
            shouldDeleteEmptyObject: false,
            shouldSelectType: false,
            shouldSelectTemplate: false,
            spaceId: spaceId,
            origin: .sharingExtension,
            templateId: nil
        )
        let lastBlockInDocument = try await blockService.lastBlockId(from: newObject.id)
        _ = try await pasteboardMiddlewareService.pasteText(text, objectId: newObject.id, context: .selected([lastBlockInDocument]))
        
        AnytypeAnalytics.instance().logCreateObject(
            objectType: .object(typeId: ObjectTypeUniqueKey.note.value),
            route: .sharingExtension
        )
        return newObject
    }
    
    private func createTextBlock(text: String, addToObject: ObjectDetails) async throws {
        let lastBlockInDocument = try await blockService.lastBlockId(from: addToObject.id)
        let newBlockId = try await blockService.add(
            contextId: addToObject.id,
            targetId: lastBlockInDocument,
            info: .emptyText,
            position: .bottom
        )
        _ = try await pasteboardMiddlewareService.pasteText(text, objectId: addToObject.id, context: .selected([newBlockId]))
        AnytypeAnalytics.instance().logCreateBlock(type: BlockInformation.emptyText.content.type, route: .sharingExtension)
    }
    
    private func createBookmarkBlock(url: URL, addToObject: ObjectDetails) async throws {
        let blockInformation = url.attributedString.blockInformation
        let lastBlockInDocument = try await blockService.lastBlockId(from: addToObject.id)
        _ = try await blockService.add(
            contextId: addToObject.id,
            targetId: lastBlockInDocument,
            info: blockInformation,
            position: .bottom
        )
        AnytypeAnalytics.instance().logCreateBlock(type: blockInformation.content.type, route: .sharingExtension)
    }
    
    private func createFileBlock(fileURL: URL, addToObject: ObjectDetails) async throws {
        let lastBlockInDocument = try await blockService.lastBlockId(from: addToObject.id)
        let fileDetails = try await fileService.uploadFileObject(
            spaceId: addToObject.spaceId,
            data: FileData(path: fileURL.relativePath, isTemporary: false)
        )
        let blockInformation = BlockInformation.file(fileDetails: fileDetails)
        _ = try await blockService.add(
            contextId: addToObject.id,
            targetId: lastBlockInDocument,
            info: blockInformation,
            position: .bottom
        )
        AnytypeAnalytics.instance().logCreateBlock(type: blockInformation.content.type, route: .sharingExtension)
    }
    
    private func linkTo(object linkToObject: ObjectDetails, newObjectId: String, blockInformation: BlockInformation) async throws {
        if linkToObject.isCollection {
            try await objectActionsService
                .addObjectsToCollection(
                    contextId: linkToObject.id,
                    objectIds: [newObjectId]
                )
        } else {
            let lastBlockInDocument = try await blockService.lastBlockId(from: linkToObject.id)
            _ = try await blockService.add(
                contextId: linkToObject.id,
                targetId: lastBlockInDocument,
                info: blockInformation,
                position: .bottom
            )
            AnytypeAnalytics.instance().logCreateBlock(type: blockInformation.content.type, route: .sharingExtension)
        }
    }
}

private extension NSAttributedString {
    var blockInformation: BlockInformation {
        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: self)
        return BlockInformation.empty(
            content: .text(
                .init(
                    text: middlewareString.text,
                    marks: middlewareString.marks,
                    color: nil,
                    contentType: .text,
                    checked: false,
                    iconEmoji: "",
                    iconImage: ""
                )
            )
        )
    }
}
