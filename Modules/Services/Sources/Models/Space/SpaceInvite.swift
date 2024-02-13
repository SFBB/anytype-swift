import Foundation
import ProtobufMessages

public struct SpaceInvite {
    public let cid: String
    public let fileKey: String
}

extension Anytype_Rpc.Space.InviteGenerate.Response {
    func asModel() -> SpaceInvite {
        return SpaceInvite(cid: inviteCid, fileKey: inviteFileKey)
    }
}
