import XCTest
@testable import Tea

final class PercentageTuiViewTests: XCTestCase {
    func testZeroPercentWidthHeightHorizontal() {
        let view = Horizontal(.Percentage(1), .Percentage(0)) { }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 5)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 0, height: 0))
    }

    func testZeroPercentWidthHeightVertical() {
        let view = Vertical(.Percentage(0), .Percentage(0)) { }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 5)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 0, height: 0))
    }

    func testFullWidthZeroHeightHorizontal() {
        let view = Horizontal(.Percentage(100), .Percentage(0)) { }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 5)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 5, height: 0))
    }

    func testZeroWidthFullHeightHorizontal() {
        let view = Horizontal(.Percentage(0), .Percentage(100)) { }
        let layout = Layout.calculateLayout(view, maxWidth: 0, maxHeight: 5)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 0, height: 5))
    }

    func testFullWidthZeroHeightVertical() {
        let view = Vertical(.Percentage(100), .Percentage(0)) { }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 5)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 5, height: 0))
    }

    func testZeroWidthFullHeightVertical() {
        let view = Vertical(.Percentage(0), .Percentage(100)) { }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 5)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 0, height: 5))
    }

    func testHorizontalContainerWithTwoHalfWidthInside() {
        let view = Horizontal(.Fill, .Fill) {
            Horizontal(.Percentage(50), .Fill) { }
            Horizontal(.Percentage(50), .Fill) { }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 10, maxHeight: 5)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 10, height: 5))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 5, height: 5))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 5, y: 0, width: 5, height: 5))
    }

    func testVerticalContainerWithTwoHalfHeightsInside() {
        let view = Vertical(.Fill, .Fill) {
            Vertical(.Fill, .Percentage(50)) { }
            Vertical(.Fill, .Percentage(50)) { }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 10)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 5, height: 10))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 5, height: 5))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 0, y: 5, width: 5, height: 5))
    }
}
