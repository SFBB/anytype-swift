import XCTest
import Services
@testable import Anytype

class TypeFieldsMoveHandlerAdditionalTests: XCTestCase {
    var moveHandler: TypeFieldsMoveHandler!
    var mockDocument: MockBaseDocument!
    var mockRelationsService: MockRelationsService!
    
    override func setUp() {
        super.setUp()
        let mockRelationsService = MockRelationsService()
        Container.shared.relationsService.register { mockRelationsService }
        self.mockRelationsService = mockRelationsService
        mockDocument = MockBaseDocument()
        moveHandler = TypeFieldsMoveHandler()
    }
    
    // MARK: - Empty Section Tests
    
    func testMoveToEmptyHeaderSection() async throws {
        let relationRows: [TypeFieldsRow] = [
            .header(.header),
            .emptyRow(.header),
            .header(.fieldsMenu),
            .relation(TypeFieldsRelationRow(section: .fieldsMenu, relation: .mock(id: "f1")))
        ]
        
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: [],
            recommendedRelations: ["f1"]
        )
        
        try await moveHandler.onMove(
            from: 3,
            to: 1,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelationIds,
            []
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelationsIds,
            ["f1"]
        )
    }
    
    func testMoveToEmptyFieldsSection() async throws {
        let relationRows: [TypeFieldsRow] = [
            .header(.header),
            .relation(TypeFieldsRelationRow(section: .header, relation: .mock(id: "h1"))),
            .header(.fieldsMenu),
            .emptyRow(.fieldsMenu)
        ]
        
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1"],
            recommendedRelations: []
        )
        
        try await moveHandler.onMove(
            from: 1,
            to: 3,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelationIds,
            ["h1"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelationsIds,
            []
        )
    }
    
    // MARK: - Edge Cases with Document Details
    
    func testMoveWithMissingRecommendedRelations() async throws {
        let relationRows: [TypeFieldsRow] = [
            .header(.fieldsMenu),
            .relation(TypeFieldsRelationRow(section: .fieldsMenu, relation: .mock(id: "f1"))),
            .relation(TypeFieldsRelationRow(section: .fieldsMenu, relation: .mock(id: "f2")))
        ]
        
        let details = ObjectDetails.mock(recommendedRelations: [])
        mockDocument.mockDetails = details
        
        try await moveHandler.onMove(
            from: 1,
            to: 2,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertNil(mockRelationsService.lastUpdateRecommendedRelations)
    }
    
    func testMoveWithInvalidRelationId() async throws {
        let relationRows: [TypeFieldsRow] = [
            .header(.header),
            .relation(TypeFieldsRelationRow(section: .header, relation: .mock(id: "invalid_id"))),
            .relation(TypeFieldsRelationRow(section: .header, relation: .mock(id: "h2")))
        ]
        
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h2"]
        )
        
        try await moveHandler.onMove(
            from: 1,
            to: 2,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertNil(mockRelationsService.lastUpdateFeaturedRelations)
    }
    
    // MARK: - Concurrent Updates Tests
    
    func testConcurrentMoves() async throws {
        let relationRows: [TypeFieldsRow] = [
            .header(.header),
            .relation(TypeFieldsRelationRow(section: .header, relation: .mock(id: "h1"))),
            .relation(TypeFieldsRelationRow(section: .header, relation: .mock(id: "h2"))),
            .relation(TypeFieldsRelationRow(section: .header, relation: .mock(id: "h3")))
        ]
        
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"]
        )
        
        // Perform multiple moves concurrently
        async let move1: () = moveHandler.onMove(from: 1, to: 2, relationRows: relationRows, document: mockDocument)
        async let move2: () = moveHandler.onMove(from: 2, to: 3, relationRows: relationRows, document: mockDocument)
        
        try await (move1, move2)
        
        // The last update should be applied
        XCTAssertNotNil(mockRelationsService.lastUpdateFeaturedRelations)
    }
    
    // MARK: - Header Navigation Tests
    
    func testMoveToHeaderWithNoNextItem() async throws {
        let relationRows: [TypeFieldsRow] = [
            .header(.header),
            .relation(TypeFieldsRelationRow(section: .header, relation: .mock(id: "h1"))),
            .header(.fieldsMenu)
        ]
        
        do {
            try await moveHandler.onMove(
                from: 1,
                to: 2,
                relationRows: relationRows,
                document: mockDocument
            )
            XCTFail("Expected emptySection error")
        } catch let error as TypeFieldsMoveError {
            XCTAssertEqual(error, .emptySection)
        }
    }
    
    func testMoveToHeaderWithNoPreviousItem() async throws {
        let relationRows: [TypeFieldsRow] = [
            .header(.header),
            .header(.fieldsMenu),
            .relation(TypeFieldsRelationRow(section: .fieldsMenu, relation: .mock(id: "f1")))
        ]
        
        do {
            try await moveHandler.onMove(
                from: 2,
                to: 0,
                relationRows: relationRows,
                document: mockDocument
            )
            XCTFail("Expected emptySection error")
        } catch let error as TypeFieldsMoveError {
            XCTAssertEqual(error, .emptySection)
        }
    }
}
