import Services

extension SpaceUxType {
    var analyticsValue: String {
        switch self {
        case .chat:
            return "Сhat"
        case .data:
            return "Private"
        case .stream:
            return "Stream"
        case .UNRECOGNIZED:
            return "UNRECOGNIZED"
        }
    }
}
