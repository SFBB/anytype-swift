import SwiftProtobuf
import AnytypeCore

public extension Array where Element == Google_Protobuf_Struct {
    var asDetais: [ObjectDetails] {
        compactMap { $0.asDetails }
    }
}

public extension Google_Protobuf_Struct {
    var asDetails: ObjectDetails? {
        try? ObjectDetails(protobufStruct: self)
    }

	func toDetails() throws -> ObjectDetails {
		try ObjectDetails(protobufStruct: self)
	}
}
