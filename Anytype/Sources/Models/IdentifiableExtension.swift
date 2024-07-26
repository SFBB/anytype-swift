import Foundation

// For show modules with one String arg
struct StringIdentifiable: Identifiable {
    
    let value: String
    
    init(value: String) {
        self.value = value
    }
    
    var id: String { value }
}

extension String {
    var identifiable: StringIdentifiable {
        StringIdentifiable(value: self)
    }
}

// For show modules with one Int arg
struct IntIdentifiable: Identifiable {
    
    let value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    var id: Int { value }
}

extension Int {
    var identifiable: IntIdentifiable {
        IntIdentifiable(value: self)
    }
}
