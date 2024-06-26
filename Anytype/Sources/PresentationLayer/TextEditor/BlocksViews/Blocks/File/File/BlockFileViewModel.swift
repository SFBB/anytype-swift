import UIKit
import Services
import Combine
import AnytypeCore

final class BlockFileViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable { info.id }
    var info: BlockInformation { informationProvider.info }
    
    let informationProvider: BlockModelInfomationProvider
    let handler: any BlockActionHandlerProtocol
    let documentId: String
    let showFilePicker: (String) -> ()
    let onFileOpen: (FilePreviewContext) -> ()
    
    @Injected(\.documentService)
    private var documentService:any OpenedDocumentsProviderProtocol
    
    private var document: (any BaseDocumentProtocol)?
    
    init(
        informationProvider: BlockModelInfomationProvider,
        handler: some BlockActionHandlerProtocol,
        documentId: String,
        showFilePicker: @escaping (String) -> (),
        onFileOpen: @escaping (FilePreviewContext) -> ()
    ) {
        self.informationProvider = informationProvider
        self.handler = handler
        self.documentId = documentId
        self.showFilePicker = showFilePicker
        self.onFileOpen = onFileOpen
        self.document = documentService.document(objectId: documentId)
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        guard case let .file(fileData) = info.content else { return }
        switch fileData.state {
        case .done:
            guard let fileDetails = document?.targetFileDetails(targetObjectId: fileData.metadata.targetObjectId) else {
                anytypeAssertionFailure("File details not found")
                return
            }
            onFileOpen(
                FilePreviewContext(
                    file: FilePreviewMedia(file: fileData, blockId: info.id, fileDetails: fileDetails),
                    sourceView: nil,
                    previewImage: nil,
                    onDidEditFile: { [weak self] url in
                        guard let self else { return }
                        handler.uploadFileAt(localPath: url.relativePath, blockId: info.id)
                    }
                )
            )
        case .empty, .error:
            if case .readonly = editorEditingState { return }
            showFilePicker(blockId)
        case .uploading:
            return
        }
    }
    
    func makeContentConfiguration(maxWidth width: CGFloat) -> UIContentConfiguration {
        guard case let .file(fileData) = info.content else {
            anytypeAssertionFailure("BlockFileViewModel has wrong info.content")
            return UnsupportedBlockViewModel(info: info).makeContentConfiguration(maxWidth: width)
        }
        
        switch fileData.state {
        case .empty:
            return emptyViewConfiguration(text: Loc.Content.File.upload, state: .default)
        case .uploading:
            return emptyViewConfiguration(text: Loc.Content.Common.uploading, state: .uploading)
        case .error:
            return emptyViewConfiguration(text: Loc.Content.Common.error, state: .error)
        case .done:
            return BlockFileConfiguration(data: fileData.mediaData(documentId: documentId)).cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
        }
    }
    
    private func emptyViewConfiguration(text: String, state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            imageAsset: .X32.file,
            text: text,
            state: state
        ).cellBlockConfiguration(
            dragConfiguration: .init(id: info.id),
            styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
}
