import XCTest
@testable import Tea

final class FillTuiViewTests: XCTestCase {

    func testSingleHorizontalNoFill() {
        let view = Horizontal(.Auto, .Auto) { Text("test") }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 2)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
    }

    func testSingleVerticalNoFill() {
        let view = Vertical(.Auto, .Auto) { Text("test") }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 2)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
    }

    func testSingleHorizontalFillContainer() {
        let view = Horizontal(.Fill, .Auto) { Text("test") }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 2)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 5, height: 1))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
    }

    func testSingleVerticalFillContainer() {
        let view = Vertical(.Auto, .Fill) { Text("test") }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 2)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 4, height: 2))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
    }

    func testFillHorizontalAndChild() {
        let view = Horizontal(.Fill, .Auto) { Text("test", .Fill) }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 2)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 5, height: 1))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 5, height: 1))
    }
}
