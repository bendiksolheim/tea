import Foundation
import Slowbox

public struct Horizontal: Node {
    public let children: [Node]
    public let rect: Rectangle
    public let width: ViewSize
    public let height: ViewSize
    public let padding: Padding

    private let cursor: Cursor?

    public init(_ width: ViewSize = .Auto, _ height: ViewSize = .Auto, _ cursor: Cursor? = nil, padding: Padding = Padding(), @NodeBuilder body: () -> [Node]) {
        children = body()
        rect = Rectangle.empty()
        self.width = width
        self.height = height
        self.cursor = cursor
        self.padding = padding
    }

    private init(_ children: [Node], _ rect: Rectangle, _ cursor: Cursor?, _ width: ViewSize, _ height: ViewSize, _ padding: Padding) {
        self.children = children
        self.rect = rect
        self.width = width
        self.height = height
        self.cursor = cursor
        self.padding = padding
    }

    public func measureContent() -> Self {
        let measuredChildren = children.map { $0.measureContent() }
        let measuredWidth: Int
        if case let ViewSize.Exact(exactWidth) = width {
            measuredWidth = exactWidth
        } else {
            measuredWidth = measuredChildren.map { $0.rect.width }.reduce(0, +) + padding.left + padding.right
        }
        let measuredHeight: Int
        if case let ViewSize.Exact(exactHeight) = height {
            measuredHeight = exactHeight
        } else {
            measuredHeight = (measuredChildren.map { $0.rect.height }.max() ?? 0) + padding.top + padding.bottom
        }
        return Self(measuredChildren, Rectangle(x: 0, y: 0, width: measuredWidth, height: measuredHeight), cursor, width, height, padding)
    }

    public func adjustTo(maxWidth: Int, maxHeight: Int) -> Node {
        let adjustedHeight = adjustSize(height, rect.height, maxHeight)
        let adjustedWidth = adjustSize(width, rect.width, maxWidth)
        let adjustedRect = rect.with(width: adjustedWidth, height: adjustedHeight)

        let totalChildrenWidth = children.map { $0.rect.width }.reduce(0, +)
        var widthLeft = max(adjustedRect.width - totalChildrenWidth, 0) // never go negative
        let rects: [Rectangle] = children.map {
            if $0.width == .Fill {
                let adjustedRect = $0.rect.with(width: $0.rect.width + widthLeft, height: adjustedRect.height)
                widthLeft = 0
                return adjustedRect
            } else {
                return adjustedRect
            }
        }

        let adjustedChildren: [Node] = children.enumerated().map {
            let rect = rects[$0.offset]
            return $0.element.adjustTo(maxWidth: rect.width, maxHeight: rect.height)
        }

        return Self(adjustedChildren, adjustedRect, cursor, width, height, padding)
    }

    public func placeAt(x: Int, y: Int) -> Node {
        var nextX = x + padding.left
        let top = y + padding.top
        let placedChildren: [Node] = children.map { child in
            let placedChild = child.placeAt(x: nextX, y: top)
            nextX += placedChild.rect.width
            return placedChild
        }

        return Self(placedChildren, rect.with(x: x, y: y), cursor, width, height, padding)
    }

    public func contentAt(y: Int) -> Node? {
        if let node = children.first(where: { $0.rect.contains(y: y) }) {
            return node.contentAt(y: y)
        } else {
            return nil
        }
    }

    public func viewFocused() -> Node? {
        if let cursor = cursor {
            if let node = children.first(where: { $0.rect.contains(y: cursor.y) }) {
                return node.contentAt(y: cursor.y)
            } else {
                return nil
            }
        } else {
            let focusedView = children.first(where: { $0.viewFocused() != nil })
            return focusedView?.viewFocused() ?? nil
        }
    }

    public func actualSize() -> Size {
        let width = children.map { $0.rect.width }.max() ?? 0
        let height = children.map { $0.rect.height }.foldLeft(0, +)
        return Size(width: width, height: height)
    }

    public func hasCursor() -> Bool {
        cursor != nil
    }

    public func modifyCursor(cursorCommand: CursorCommand) -> Cursor? {
        if let cursor = cursor {
            switch cursorCommand {
            case let .MoveCursor(_, yDelta):
                return move(yDelta, self, cursor)
            case let .PutCursor(x, y):
//            terminal.moveCursor(x, y)
//                return CursorModel(y: y)
                return cursor.with(y: y)

            case let .Scroll(amount):
                return cursor
                    //return focused // TODO: implement me
            }
        }

        return children.first { $0.hasCursor() }.map { $0.modifyCursor(cursorCommand: cursorCommand)! }
    }

    public func renderTo(terminal: Slowbox) {
        children.enumerated().forEach { element in
            if element.offset < rect.width {
                element.element.renderTo(terminal: terminal)
            }
        }

        if let cursor = cursor {
            terminal.modify(x: 0, y: cursor.y) { cell in
                cell.with(foreground: Color.Black, background: Color.Blue)
            }

            (1..<rect.width).forEach { x in
                terminal.modify(x: x, y: cursor.y) { cell in
                    cell.with(background: Color.Black)
                }
            }
        }
    }

    public func htmlRepresentation() -> HTML {
        let cssStyle = "left: \(cssPx(rect.x)); top: \(cssPx(rect.y)); width:\(cssPx(rect.width)); height:\(cssPx(rect.height));"
        return div("container", ["data-rect": rect.description, "style": cssStyle]) {
            for c in children {
                c.htmlRepresentation()
            }
        }
    }
}