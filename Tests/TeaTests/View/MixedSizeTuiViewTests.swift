import XCTest
import Slowbox
@testable import Tea

final class MixedSizeTuiViewTests: XCTestCase {
    func testOne() {
        let view = Vertical(.Fill, .Fill) {
            Vertical(.Fill, .Fill) {}
            Text("test")
        }
        let layout = Layout.calculateLayout(view, maxWidth: 10, maxHeight: 10)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 10, height: 10))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 10, height: 9))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 0, y: 9, width: 4, height: 1))
    }

    /*
     +---------+
     |    |    |
     |    |    |
     +----+----+
     |    |    |
     |    |    |
     +---------+
     */

    func testDividedIntoFourHorizontalThenVertical() {
        let view = Horizontal(.Fill, .Fill) {
            Vertical(.Percentage(50), .Fill) {
                Vertical(.Fill, .Percentage(50)) { }
                Vertical(.Fill, .Percentage(50)) { }
            }
            Vertical(.Percentage(50), .Fill) {
                Vertical(.Fill, .Percentage(50)) { }
                Vertical(.Fill, .Percentage(50)) { }
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 100, maxHeight: 100)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 100, height: 100))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 50, height: 100))
        XCTAssertEqual(layout.children[0].children[0].rect, Rectangle(x: 0, y: 0, width: 50, height: 50))
        XCTAssertEqual(layout.children[0].children[1].rect, Rectangle(x: 0, y: 50, width: 50, height: 50))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 50, y: 0, width: 50, height: 100))
        XCTAssertEqual(layout.children[1].children[0].rect, Rectangle(x: 50, y: 0, width: 50, height: 50))
        XCTAssertEqual(layout.children[1].children[1].rect, Rectangle(x: 50, y: 50, width: 50, height: 50))
    }

    func testDividedIntoFourVerticalThenHorizontal() {
        let view = Vertical(.Fill, .Fill) {
            Horizontal(.Fill, .Percentage(50)) {
                Horizontal(.Percentage(50), .Fill) { }
                Horizontal(.Percentage(50), .Fill) { }
            }
            Horizontal(.Fill, .Percentage(50)) {
                Horizontal(.Percentage(50), .Fill) { }
                Horizontal(.Percentage(50), .Fill) { }
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 100, maxHeight: 100)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 100, height: 100))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 100, height: 50))
        XCTAssertEqual(layout.children[0].children[0].rect, Rectangle(x: 0, y: 0, width: 50, height: 50))
        XCTAssertEqual(layout.children[0].children[1].rect, Rectangle(x: 50, y: 0, width: 50, height: 50))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 0, y: 50, width: 100, height: 50))
        XCTAssertEqual(layout.children[1].children[0].rect, Rectangle(x: 0, y: 50, width: 50, height: 50))
        XCTAssertEqual(layout.children[1].children[1].rect, Rectangle(x: 50, y: 50, width: 50, height: 50))
    }

    func testHorizontalTextLayoutWithFill() {
        let view = Vertical(.Fill, .Fill) {
            Horizontal(.Fill, .Auto) {
                Text("hash")
                Text("Message", .Fill)
                Text("hmm")
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 20, maxHeight: 1)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 20, height: 1))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 20, height: 1))
        XCTAssertEqual(layout.children[0].children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
        XCTAssertEqual(layout.children[0].children[1].rect, Rectangle(x: 4, y: 0, width: 13, height: 1))
        XCTAssertEqual(layout.children[0].children[2].rect, Rectangle(x: 17, y: 0, width: 3, height: 1))
    }

    func testArray() {
        let children = [Text("test"), Text("test")]
        let view = Vertical(.Fill, .Fill) {
            children
        }
        let layout = Layout.calculateLayout(view, maxWidth: 10, maxHeight: 10)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 10, height: 10))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 0, y: 1, width: 4, height: 1))
    }
}
