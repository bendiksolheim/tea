import XCTest
@testable import Tea

final class ConditionalTuiViewTests: XCTestCase {

    func testTrueConditional() {
        let condition = true
        let view = Horizontal(.Fill, .Fill) {
            if condition {
                Text("test")
            } else {
                Text("loooooong")
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 10, maxHeight: 10)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 10, height: 10))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
    }

    func testFalseConditional() {
        let condition = false
        let view = Horizontal(.Fill, .Fill) {
            if condition {
                Text("test")
            } else {
                Text("looooooong")
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 10, maxHeight: 10)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 10, height: 10))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 10, height: 1))
    }

    func testOptionWhereTrue() {
        let condition = true
        let view = Horizontal(.Fill, .Fill) {
            if condition {
                Text("test")
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 10, maxHeight: 10)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 10, height: 10))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
    }

    func testOptionWhereFalse() {
        let condition = false
        let view = Horizontal(.Fill, .Fill) {
            if condition {
                Text("test")
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 10, maxHeight: 10)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 10, height: 10))
        XCTAssertEqual(layout.children.count, 0)
    }

    func testOptionWithMultipleChildren() {
        let condition = true
        let view = Horizontal(.Fill, .Fill) {
            if condition {
                Text("test")
                Text("tast")
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 10, maxHeight: 10)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 10, height: 10))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 4, y: 0, width: 4, height: 1))
    }
}