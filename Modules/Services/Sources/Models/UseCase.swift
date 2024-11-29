import Foundation
import ProtobufMessages

public enum UseCase: Sendable {
    case none
    case getStarted
    case empty
}

extension UseCase {
    func toMiddleware() -> Anytype_Rpc.Object.ImportUseCase.Request.UseCase {
        switch self {
        case .none:
            return .none
        case .getStarted:
            return .getStarted
        case .empty:
            return .empty
        }
    }
}
