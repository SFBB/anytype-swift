// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension Anytype_Rpc.BlockTable.RowCreate.Response: ResultWithError {}
extension Anytype_Rpc.BlockTable.RowCreate.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

