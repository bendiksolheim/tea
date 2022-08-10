import Foundation
import Slowbox

public struct Vertical: Node {
    public let children: [Node]
    public let rect: Rectangle
    public let scroll: Int
    public let focus: Bool
    public let width: ViewSize
    public let height: ViewSize

    public init(_ width: ViewSize = .Auto, _ height: ViewSize = .Auto, _ focus: Bool = false, @NodeBuilder body: () -> [Node]) {
        children = body()
        rect = Rectangle.empty()
        scroll = 0
        self.focus = focus
        self.width = width
        self.height = height
    }

    private init(_ children: [Node], _ rect: Rectangle, _ scroll: Int, _ focus: Bool, _ width: ViewSize, _ height: ViewSize) {
        self.children = children
        self.rect = rect
        self.scroll = scroll
        self.focus = focus
        self.width = width
        self.height = height
    }

    public func measureContent() -> Self {
        let measuredChildren = children.map { $0.measureContent() }
        let measuredWidth: Int
        if case let ViewSize.Exact(exactWidth) = width {
            measuredWidth = exactWidth
        } else {
            measuredWidth = measuredChildren.map { $0.rect.width }.max() ?? 0
        }
        let measuredHeight: Int
        if case let ViewSize.Exact(exactHeight) = height {
            measuredHeight = exactHeight
        } else {
            measuredHeight = measuredChildren.map { $0.rect.height }.reduce(0, +)
        }
        return Self(measuredChildren, Rectangle(x: 0, y: 0, width: measuredWidth, height: measuredHeight), scroll, focus, width, height)
    }

    public func adjustTo(maxWidth: Int, maxHeight: Int) -> Node {
        let adjustedHeight = adjustSize(height, rect.height, maxHeight)
        let adjustedWidth = adjustSize(width, rect.width, maxWidth)
        let adjustedRect = rect.with(width: adjustedWidth, height: adjustedHeight)

        let totalChildrenHeight = children.map { $0.rect.height }.reduce(0, +)
        var heightLeft = max(adjustedRect.height - totalChildrenHeight, 0) // never go negative
        let rects: [Rectangle] = children.map {
            if $0.height == .Fill {
                let adjustedRect = $0.rect.with(width: adjustedRect.width, height: $0.rect.height + heightLeft)
                heightLeft = 0
                return adjustedRect
            } else {
                return adjustedRect
            }
        }

        let adjustedChildren: [Node] = children.enumerated().map {
            let rect = rects[$0.offset]
            return $0.element.adjustTo(maxWidth: rect.width, maxHeight: rect.height)
        }

        return Self(adjustedChildren, adjustedRect, scroll, focus, width, height)
    }

    public func placeAt(x: Int, y: Int) -> Node {
        var nextY = y
        let placedChildren: [Node] = children.map { child in
            let placedChild = child.placeAt(x: x, y: nextY)
            nextY += placedChild.rect.height
            return placedChild
        }

        return Self(placedChildren, rect.with(x: x, y: y), scroll, focus, width, height)
    }

    public func contentAt(y: Int) -> Node? {
        if let node = children.first(where: { $0.rect.contains(y: y) }) {
            return node.contentAt(y: y)
        } else {
            return nil
        }
    }

    public func actualSize() -> Size {
        let width = children.map { $0.rect.width }.max() ?? 0
        let height = children.map { $0.rect.height }.foldLeft(0, +)
        return Size(width: width, height: height)
    }

    public func scroll(amount: Int) -> Node {
        Self(children, rect, amount, focus, width, height)
    }

    public func modifyFocused(fn: (Node) -> Node) -> Node {
        let modifiedChildren: [Node] = children.map { child in
            if child.focus {
                return fn(child)
            } else {
                return child.modifyFocused(fn: fn)
            }
        }
        return Self(modifiedChildren, rect, scroll, focus, width, height)
    }

    public func renderTo(terminal: Slowbox) {
        children.enumerated().forEach { element in
            if element.offset < rect.height {
                element.element.renderTo(terminal: terminal)
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
