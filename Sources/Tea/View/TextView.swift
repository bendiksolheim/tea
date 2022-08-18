import Foundation
import Slowbox

public typealias ViewEvent<Message> = (KeyEvent, Message)

public struct Text<Message>: Node {
    private let text: TextType
    public let events: [ViewEvent<Message>]
    public let rect: Rectangle
    public var scroll: Int {
        0
    }
    public var focus: Bool {
        false
    }
    public var children: [Node] {
        []
    }

    public let width: ViewSize
    // A TextView is always exactly 1 point high
    public var height: ViewSize {
        .Exact(1)
    }

    public init(_ text: TextType, _ events: [ViewEvent<Message>], _ width: ViewSize = .Auto) {
        self.text = text
        self.events = events
        rect = Rectangle.empty()
        self.width = width
    }

    fileprivate init(_ text: TextType, _ events: [ViewEvent<Message>], _ rect: Rectangle, _ width: ViewSize) {
        self.text = text
        self.events = events
        self.rect = rect
        self.width = width
    }

    public func measureContent() -> Self {
        Self(text, events, rect.with(width: text.count(), height: 1), width)
    }

    public func adjustTo(maxWidth: Int, maxHeight: Int) -> Node {
        let adjustedWidth: Int
        switch width {
        case .Auto:
            adjustedWidth = min(rect.width, maxWidth)
        case let .Percentage(pct):
            adjustedWidth = Int(round(Float((pct) / 100) * Float(maxWidth)))
        case let .Exact(exact):
            adjustedWidth = min(exact, maxWidth)
        case .Fill:
            // remaining parent space is distributed later on -> already done?
            adjustedWidth = max(rect.width, maxWidth)
        }
        let adjustedHeight = min(maxHeight, rect.height)
        return Self(text, events, rect.with(width: adjustedWidth, height: adjustedHeight), width)
    }

    public func placeAt(x: Int, y: Int) -> Node {
        Self(text, events, rect.with(x: x, y: y), width)
    }

    public func contentAt(y: Int) -> Node? {
        if rect.y == y {
            return self
        } else {
            return nil
        }
    }

    public func viewFocused() -> Node? {
        nil
    }

    public func actualSize() -> Size {
        Size(width: text.count(), height: 1)
    }

//    public func scroll(amount: Int) -> Node {
//        self
//    }

    public func modifyCursor(cursorCommand: CursorCommand) ->  Cursor? {
        nil
    }

    public func hasCursor() -> Bool {
        false
    }

    public func renderTo(terminal: Slowbox) {
        text.terminalContent().enumerated().forEach {
            terminal.put(x: rect.x + $0.offset, y: rect.y, cell: Cell($0.element.1, formatting: $0.element.0))
        }
    }

    public func htmlRepresentation() -> HTML {
        let content = text.count() != 0 ? text.description.replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;").replacingOccurrences(of: " ", with: "&nbsp;") : "&nbsp;"
        let style = "left: \(cssPx(rect.x)); top: \(cssPx(rect.y)); width:\(cssPx(rect.width)); height:\(cssPx(rect.height));"
        return div("content", ["data-rect": rect.description, "style": style]) {
            content
        }
    }
}

public extension Text where Message == NSObject {
    init(_ body: TextType, _ width: ViewSize = .Auto) {
        self.init(body, [], width)
    }
}