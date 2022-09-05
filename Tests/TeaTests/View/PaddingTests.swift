import XCTest
@testable import Tea

final class PaddingTests: XCTestCase {
    func testPaddingTopHorizontal() {
        let view = Horizontal(padding: Padding(top: 1)) {
            Text("Hello")
        }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 3)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 5, height: 2))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 1, width: 5, height: 1))
    }

    func testPaddingLeftAndTopHorizontal() {
        let view = Horizontal(padding: Padding(top: 1, left: 2)) {
            Text("Hello")
        }
        let layout = Layout.calculateLayout(view, maxWidth: 7, maxHeight: 3)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 7, height: 2))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 2, y: 1, width: 5, height: 1))
    }

    func testPaddingAllSidesHorizontal() {
        let view = Horizontal(padding: Padding(top: 1, right: 1, bottom: 1, left: 1)) {
            Text("a")
        }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 5)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 3, height: 3))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 1, y: 1, width: 1, height: 1))
    }

    func testPaddingTopVertical() {
        let view = Vertical(padding: Padding(top: 1)) {
            Text("Hello")
        }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 3)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 5, height: 2))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 1, width: 5, height: 1))
    }

    func testPaddingLeftAndTopVertical() {
        let view = Vertical(padding: Padding(top: 1, left: 2)) {
            Text("Hello")
        }
        let layout = Layout.calculateLayout(view, maxWidth: 7, maxHeight: 2)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 7, height: 2))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 2, y: 1, width: 5, height: 1))
    }

    func testPaddingAllSidesVertical() {
        let view = Vertical(padding: Padding(top: 1, right: 1, bottom: 1, left: 1)) {
            Text("a")
        }
        let layout = Layout.calculateLayout(view, maxWidth: 3, maxHeight: 3)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 3, height: 3))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 1, y: 1, width: 1, height: 1))
    }

    func testPaddingInsideHorizontal() {
        let view = Horizontal {
            Vertical(padding: Padding(right: 5)) {
                Text("Hello")
            }
            Vertical(padding: Padding(top: 2)) {
                Text("World")
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 20, maxHeight: 3)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 15, height: 3))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 10, height: 1))
        XCTAssertEqual(layout.children[0].children[0].rect, Rectangle(x: 0, y: 0, width: 5, height: 1))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 10, y: 0, width: 5, height: 3))
        XCTAssertEqual(layout.children[1].children[0].rect, Rectangle(x: 10, y: 2, width: 5, height: 1))
    }

    func testPaddingInsideVertical() {
        let view = Vertical {
            Horizontal(padding: Padding(left: 3)) {
                Text("Hello")
            }
            Horizontal(padding: Padding(top: 5)) {
                Text("World")
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 10, maxHeight: 8)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 8, height: 7))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 8, height: 1))
        XCTAssertEqual(layout.children[0].children[0].rect, Rectangle(x: 3, y: 0, width: 5, height: 1))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 0, y: 1, width: 5, height: 6))
        XCTAssertEqual(layout.children[1].children[0].rect, Rectangle(x: 0, y: 6, width: 5, height: 1))
    }
}
