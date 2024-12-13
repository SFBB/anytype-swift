import QuickLook
import Combine
import Services
import AnytypeCore

final class FilePreviewMedia: NSObject, PreviewRemoteItem {
    
    // MARK: - PreviewRemoteItem
    var id: String { fileDetails.id }
    let fileDetails: FileDetails
    let didUpdateContentSubject = PassthroughSubject<Void, Never>()

    // MARK: - QLPreviewItem
    var previewItemTitle: String? { fileDetails.fileName }
    var previewItemURL: URL?

    private let fileDownloader = FileDownloader()

    init(fileDetails: FileDetails) {
        self.fileDetails = fileDetails
        
        super.init()

        startDownloading()
    }

    func startDownloading() {
        Task {
            do {
                guard let url = fileDetails.contentUrl else { return }
                let data = try await fileDownloader.downloadData(url: url)
                let path = FileManager.originalPath(objectId: fileDetails.id, fileName: fileDetails.fileName)

                try FileManager.default.createDirectory(
                    at: path.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )

                try data.write(to: path, options: [.atomic])
                previewItemURL = path
                didUpdateContentSubject.send()
            } catch {
                anytypeAssertionFailure("Failed to write file into temporary directory")
            }
        }
    }
}
