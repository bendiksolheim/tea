import XCTest
@testable import Tea

final class ExactSizeTuiViewTests: XCTestCase {
    func testEmptyHorizontal() {
//        let view = horizontal { }
        let view = Horizontal {}
        let layout = Layout.calculateLayout(view, maxWidth: 0, maxHeight: 0)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 0, height: 0))
   }

    func testHorizontalWithText() {
        let view = Horizontal { Text("test") }
        let layout = Layout.calculateLayout(view, maxWidth: 4, maxHeight: 1)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
    }

    func testHorizontalWithTwoChildren() {
        let view = Horizontal {
            Text("test")
            Text("hehe")
        }
        let layout = Layout.calculateLayout(view, maxWidth: 8, maxHeight: 1)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 8, height: 1))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 4, y: 0, width: 4, height: 1))
    }

    func testEmptyVertical() {
        let layout = Layout.calculateLayout(Vertical {}, maxWidth: 0, maxHeight: 0)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 0, height: 0))
    }

    func testVerticalWithText() {
        let view = Vertical { Text("test") }
        let layout = Layout.calculateLayout(view, maxWidth: 4, maxHeight: 1)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
    }

    func testVerticalWithTwoChildren() {
        let view = Vertical {
            Text("test")
            Text("hehe")
        }
        let layout = Layout.calculateLayout(view, maxWidth: 4, maxHeight: 2)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 4, height: 2))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 0, y: 1, width: 4, height: 1))
    }

    func testHorizontalContainingVerticalContainingTwoChildren() {
        let view = Horizontal {
            Vertical {
                Text("hello")
                Text("there")
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 5, maxHeight: 2)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 5, height: 2))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 5, height: 2))
        XCTAssertEqual(layout.children[0].children[0].rect, Rectangle(x: 0, y: 0, width: 5, height: 1))
        XCTAssertEqual(layout.children[0].children[1].rect, Rectangle(x: 0, y: 1, width: 5, height: 1))
    }

    func testVerticalContainingHorizontalContainingTwoChildren() {
        let view = Vertical {
            Horizontal {
                Text("hello")
                Text("there")
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 10, maxHeight: 1)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 10, height: 1))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 10, height: 1))
        XCTAssertEqual(layout.children[0].children[0].rect, Rectangle(x: 0, y: 0, width: 5, height: 1))
        XCTAssertEqual(layout.children[0].children[1].rect, Rectangle(x: 5, y: 0, width: 5, height: 1))
    }

    func testHorizontalContainingTwoVerticalContainingTwoChildren() {
        let view = Horizontal {
            Vertical {
                Text("test")
                Text("hehe")
            }
            Vertical {
                Text("hello")
                Text("there")
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 9, maxHeight: 2)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 9, height: 2))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 2))
        XCTAssertEqual(layout.children[0].children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
        XCTAssertEqual(layout.children[0].children[1].rect, Rectangle(x: 0, y: 1, width: 4, height: 1))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 4, y: 0, width: 5, height: 2))
        XCTAssertEqual(layout.children[1].children[0].rect, Rectangle(x: 4, y: 0, width: 5, height: 1))
        XCTAssertEqual(layout.children[1].children[1].rect, Rectangle(x: 4, y: 1, width: 5, height: 1))
    }

    func testVerticalContainingTwoHorizontalContainingTwoChildren() {
        let view = Vertical {
            Horizontal {
                Text("test")
                Text("hehe")
            }
            Horizontal {
                Text("hello")
                Text("there")
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 10, maxHeight: 2)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 10, height: 2))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 8, height: 1))
        XCTAssertEqual(layout.children[0].children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
        XCTAssertEqual(layout.children[0].children[1].rect, Rectangle(x: 4, y: 0, width: 4, height: 1))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 0, y: 1, width: 10, height: 1))
        XCTAssertEqual(layout.children[1].children[0].rect, Rectangle(x: 0, y: 1, width: 5, height: 1))
        XCTAssertEqual(layout.children[1].children[1].rect, Rectangle(x: 5, y: 1, width: 5, height: 1))
    }

    func testHorizontalContainingVerticalAndHorizontalContainingTwoChildren() {
        let view = Horizontal {
            Vertical {
                Text("test")
                Text("hehe")
            }
            Horizontal {
                Text("hello")
                Text("there")
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 14, maxHeight: 2)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 14, height: 2))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 2))
        XCTAssertEqual(layout.children[0].children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
        XCTAssertEqual(layout.children[0].children[1].rect, Rectangle(x: 0, y: 1, width: 4, height: 1))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 4, y: 0, width: 10, height: 1))
        XCTAssertEqual(layout.children[1].children[0].rect, Rectangle(x: 4, y: 0, width: 5, height: 1))
        XCTAssertEqual(layout.children[1].children[1].rect, Rectangle(x: 9, y: 0, width: 5, height: 1))
    }

    func testVerticalContainingHorizontalAndVerticalContainingTwoChildren() {
        let view = Vertical {
            Horizontal {
                Text("test")
                Text("hehe")
            }
            Vertical {
                Text("hello")
                Text("there")
            }
        }
        let layout = Layout.calculateLayout(view, maxWidth: 8, maxHeight: 3)
        XCTAssertEqual(layout.rect, Rectangle(x: 0, y: 0, width: 8, height: 3))
        XCTAssertEqual(layout.children[0].rect, Rectangle(x: 0, y: 0, width: 8, height: 1))
        XCTAssertEqual(layout.children[0].children[0].rect, Rectangle(x: 0, y: 0, width: 4, height: 1))
        XCTAssertEqual(layout.children[0].children[1].rect, Rectangle(x: 4, y: 0, width: 4, height: 1))
        XCTAssertEqual(layout.children[1].rect, Rectangle(x: 0, y: 1, width: 5, height: 2))
        XCTAssertEqual(layout.children[1].children[0].rect, Rectangle(x: 0, y: 1, width: 5, height: 1))
        XCTAssertEqual(layout.children[1].children[1].rect, Rectangle(x: 0, y: 2, width: 5, height: 1))
    }
}
