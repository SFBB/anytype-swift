import Services
import Combine
import AnytypeCore
import Foundation

enum FileUploadingSource {
    case path(String)
    case itemProvider(NSItemProvider)
}

struct FileData {
    let path: String
    let isTemporary: Bool
}

protocol FileActionsServiceProtocol {
    
    func createFileData(source: FileUploadingSource) async throws -> FileData
    
    func uploadDataAt(data: FileData, contextID: BlockId, blockID: BlockId) async throws
    func uploadImage(spaceId: String, data: FileData) async throws -> FileDetails
    
    func uploadDataAt(source: FileUploadingSource, contextID: BlockId, blockID: BlockId) async throws
    func uploadImage(spaceId: String, source: FileUploadingSource) async throws -> FileDetails
    
    func nodeUsage() async throws -> NodeUsageInfo
    
    func clearCache() async throws
}
