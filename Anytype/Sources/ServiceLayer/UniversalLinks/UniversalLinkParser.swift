import Foundation
import AnytypeCore

protocol UniversalLinkParserProtocol: AnyObject {
    func parse(url: URL) -> UniversalLink?
    func createUrl(link: UniversalLink) -> URL?
}

final class UniversalLinkParser: UniversalLinkParserProtocol {

    private enum LinkPaths {
        static let inviteHostProd = "invite.any.coop"
        static let inviteHostStage = "invite-stage.any.coop"
        static let inviteHosts = [inviteHostProd, inviteHostStage]
    }
    
    func parse(url: URL) -> UniversalLink? {
        guard let components = NSURLComponents(string: url.absoluteString.removingPercentEncoding ?? url.absoluteString) else { return nil }
        
        // Link: https://invite.any.coop/<inviteId>#<encryptionkey>
        if let host = components.host, LinkPaths.inviteHosts.contains(host), var path = components.path, let fragment = components.fragment {
            
            if path.hasPrefix("/") {
                path.removeFirst(1)
            }
            
            guard path.isNotEmpty, fragment.isNotEmpty else {
                return nil
            }
            
            return .invite(cid: path, key: fragment)
        }
        
        return nil
    }
    
    func createUrl(link: UniversalLink) -> URL? {
        switch link {
        case .invite(let cid, let key):
            return URL(string: "https://\(LinkPaths.inviteHostProd)/\(cid)#\(key)")
        }
    }
}
