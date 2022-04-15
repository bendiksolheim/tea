import XCTest
@testable import Tea

final class FlexTests: XCTestCase {
    enum Msg: Equatable {
        case Dummy
    }
    
    func testEmptyChildren() throws {
        let parent = Layout.calculate(node: Container(FlexStyle(), []), width: 100, height: 100)
        XCTAssertEqual(parent.rect, Rectangle(x: 0, y: 0, width: 0, height: 0))
    }
    
    func testSingleChild() {
        let parent = Layout.calculate(node: Container(FlexStyle(), [Content<Msg>("Hello", FlexStyle(grow: 1))]), width: 10, height: 10)
        XCTAssertEqual(parent.rect, Rectangle(x: 0, y: 0, width: 10, height: 1))
    }
    
    func testMultipleChildrenOnRow() {
        let parent = Layout.calculate(node: Container(FlexStyle(), [Content<Msg>("Hello"), Content("There")]), width: 10, height: 10)
        XCTAssertEqual(parent.rect, Rectangle(x: 0, y: 0, width: 10, height: 1))
    }
    
    func testMultipleChildrenOnColumn() {
        let childStyle = FlexStyle(grow: 1)
        let parent = Layout.calculate(node: Container(FlexStyle(direction: .Column), [Content<Msg>("Hello", childStyle), Content<Msg>("There", childStyle)]), width: 10, height: 10)
        XCTAssertEqual(parent.rect, Rectangle(x: 0, y: 0, width: 5, height: 10))
    }
    
    func testSingeChildWithoutGrow() {
        let style = FlexStyle(grow: 0)
        let container = Container(FlexStyle(grow: 0), [Content<Msg>("Hello", style)])
        let parent = Layout.calculate(node: container, width: 10, height: 10)
        XCTAssertEqual(parent.rect, Rectangle(x: 0, y: 0, width: 5, height: 1))
    }
    
    func testPlacementOfTwoContentsInColumn() {
        let style = FlexStyle(direction: .Column)
        let container = Container(style, [Content<Msg>("Hello"), Content<Msg>("There")])
        let parent = Layout.calculate(node: container, width: 5, height: 2)
        let placements = parent.children()!.map { $0.rect }
        let expectedPlacements = [
            Rectangle(x: 0, y: 0, width: 5, height: 1),
            Rectangle(x: 0, y: 1, width: 5, height: 1)
        ]
        XCTAssertEqual(placements, expectedPlacements)
    }
    
    func testPlacementOfTwoContentsInColumnFirstGrowing() {
        let style = FlexStyle(direction: .Column)
        let container = Container(style, [
            Content<Msg>("Hello", FlexStyle(grow: 1)),
            Content<Msg>("There")
        ])
        let parent = Layout.calculate(node: container, width: 5, height: 3)
        let placements = parent.children()!.map { $0.rect }
        let expectedPlacements = [
            Rectangle(x: 0, y: 0, width: 5, height: 2),
            Rectangle(x: 0, y: 2, width: 5, height: 1)
        ]
        XCTAssertEqual(placements, expectedPlacements)
    }
    
    func testPlacementOfTwoContentsInColumnBothGrowing() {
        let style = FlexStyle(direction: .Column)
        let childStyle = FlexStyle(grow: 1)
        let container = Container(style, [
            Content<Msg>("Hello", childStyle),
            Content<Msg>("There", childStyle)
        ])
        let parent = Layout.calculate(node: container, width: 5, height: 4)
        let placements = parent.children()!.map { $0.rect }
        let expectedPlacements = [
            Rectangle(x: 0, y: 0, width: 5, height: 2),
            Rectangle(x: 0, y: 2, width: 5, height: 2)
        ]
        XCTAssertEqual(placements, expectedPlacements)
    }
    
    func testTwoTooLargeContainersWithShrink() {
        let style = FlexStyle(direction: .Column)
        let container = Container(style, [
            Content<Msg>("Hello\nThere"),
            Content<Msg>("I am\nHere")
        ])
        let parent = Layout.calculate(node: container, width: 5, height: 2)
        let placements = parent.children()!.map { $0.rect }
        let expectedPlacements = [
            Rectangle(x: 0, y: 0, width: 11, height: 1),
            Rectangle(x: 0, y: 1, width: 9, height: 1)
        ]
        XCTAssertEqual(placements, expectedPlacements)
    }
    
    func testNestedContainerWithContent() {
        let container = Container([
            Container([
                Content<Msg>("Hello, world!")
            ])
        ])
        let parent = Layout.calculate(node: container, width: 13, height: 1)
        let innerContainerPlacement = parent.children()!.map { $0.rect }
        let textPlacement = parent.children()!.flatMap { $0.children()!.map { $0.rect } }
        XCTAssertEqual(innerContainerPlacement, [Rectangle(x: 0, y: 0, width: 13, height: 1)])
        XCTAssertEqual(textPlacement, [Rectangle(x: 0, y: 0, width: 13, height: 1)])
    }
    
    func testUnnecessarilyNestedContainersWithContent() {
        let container = Container([
            Container([
                Container([
                    Content<Msg>("Hello, world!")
                ])
            ])
        ])
        let parent = Layout.calculate(node: container, width: 13, height: 1)
        let c1 = parent.rect
        let c2 = parent.children()!.map { $0.rect }[0]
        let c3 = parent.children()!.flatMap { $0.children()!.map { $0.rect }}[0]
        let t = parent.children()!.flatMap { $0.children()!.flatMap { $0.children()!.map { $0.rect }}}[0]
        let expectedRect = Rectangle(x: 0, y: 0, width: 13, height: 1)
        XCTAssertEqual(c1, expectedRect)
        XCTAssertEqual(c2, expectedRect)
        XCTAssertEqual(c3, expectedRect)
        XCTAssertEqual(t, expectedRect)
    }

    func testGrowToFillContainer() {
        let main = Container(FlexStyle(direction: .Column, grow: 1, shrink: 0), [Content<Msg>("Hello"), Content<Msg>("There")])
        let info = Content<Msg>("Something")
        let container = Container(FlexStyle(direction: .Column, grow: 1, shrink: 0), [main, info])
        let layout = Layout.calculate(node: container, width: 10, height: 5)
        // outer box
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 10, height: 5))
        // main
        XCTAssertEqual(layout.children()![0].rect, Rectangle(x: 0, y: 0, width: 5, height: 4))
        // "Hello" text
        XCTAssertEqual(layout.children()![0].children()![0].rect, Rectangle(x: 0, y: 0, width: 5, height: 1))
        // "There" text
        XCTAssertEqual(layout.children()![0].children()![1].rect, Rectangle(x: 0, y: 1, width: 5, height: 1))
        // info
        XCTAssertEqual(layout.children()![1].rect, Rectangle(x: 0, y: 4, width: 9, height: 1))
    }
}
