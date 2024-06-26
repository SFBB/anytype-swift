import Foundation

public struct SharedContent: Codable, Sendable {
    public let title: String?
    public let items: [SharedContentItem]
    public let debugInfo: SharedContentDebugInfo
}
