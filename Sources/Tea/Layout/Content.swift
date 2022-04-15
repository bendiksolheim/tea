import Foundation
import Slowbox

public struct Content<Message>: Node {
    let text: TextType
    public let style: FlexStyle
    public let rect: Rectangle
    public let events: [ViewEvent<Message>]
    
    public init(_ text: TextType, events: [ViewEvent<Message>] = [], _ style: FlexStyle = FlexStyle()) {
        self.text = text
        self.style = style
        let width = text.count()
        let height = 1
        self.rect = Rectangle(x: 0, y: 0, width: width, height: height)
        self.events = events
    }
    
    private init(_ text: Content, _ rect: Rectangle) {
        self.text = text.text
        self.style = text.style
        self.rect = rect
        self.events = text.events
    }
    
    public func placeAt(x: Int, y: Int) -> Node {
        return Content(self, rect.withX(x).withY(y))
    }
    
    public func withWidth(_ width: Int) -> Node {
        return Content(self, rect.withWidth(width))
    }
    
    public func withHeight(_ height: Int) -> Node {
        return Content(self, rect.withHeight(height))
    }
    
    public func withX(_ x: Int) -> Node {
        return Content(self, rect.withX(x))
    }
    
    public func withY(_ y: Int) -> Node {
        return Content(self, rect.withY(y))
    }
    
    public func measureMainSize() -> Node {
        return self
    }
    
    public func measureCrossSize() -> Node {
        return self
    }
    
    public func constrainTo(_ width: Int, _ height: Int) -> Node {
        return withWidth(width).withHeight(height)
    }
    
    public func mainSize(for direction: FlexDirection) -> Int {
        switch direction {
        case .Row:
            return rect.width
        case .Column:
            return rect.height
        }
    }
    
    public func crossSize(for direction: FlexDirection) -> Int {
        switch direction {
        case .Row:
            return rect.height
        case .Column:
            return rect.width
        }
    }
    
    public func children() -> [Node]? {
        return nil
    }
    
    public func renderTo(terminal: Slowbox) {
        text.terminalContent().enumerated().forEach { terminal.put(x: rect.x + $0.offset, y: rect.y, cell: Cell($0.element.1, formatting: $0.element.0))}
    }
    
    public func contentAt(y: Int) -> Node? {
        if rect.y == y {
            return self
        } else {
            return nil
        }
    }
    
    public var description: String {
        return "Content(\(rect)) { \(text) }"
    }

    public func terminalDescription(_ depth: Int) -> String {
        let whitespace = String(repeating: " ", count: depth * 2)
        return "\(whitespace)Content(\(rect), \(style))"
    }
}
