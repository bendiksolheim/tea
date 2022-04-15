import Foundation
import Slowbox
import Darwin

public struct Container: Node {
    let content: [Node]
    public let style: FlexStyle
    public let rect: Rectangle
    
    public init(_ style: FlexStyle, _ children: [Node]) {
        self.style = style
        self.content = children
        self.rect = Rectangle.empty()
    }
    
    public init(_ children: [Node]) {
        self.style = FlexStyle()
        self.content = children
        self.rect = Rectangle.empty()
    }
    
    private init(_ children: [Node], _ style: FlexStyle, _ rect: Rectangle) {
        self.style = style
        self.content = children
        self.rect = rect
    }
    
    public func measureMainSize() -> Node {
        let measuredChildren = content.map { $0.measureMainSize() }
        let measuredMainSize = measuredChildren.reduce(0, { $0 + $1.mainSize(for: style.direction)})
        switch style.direction {
        case .Row:
            return Container(measuredChildren, style, rect.withWidth(measuredMainSize))
        case .Column:
            return Container(measuredChildren, style, rect.withHeight(measuredMainSize))
        }
    }
    
    public func measureCrossSize() -> Node {
        let measuredChildren = content.map { $0.measureCrossSize() }
        let measuredCrossSize = measuredChildren.map { $0.crossSize(for: style.direction) }.max() ?? 0
        switch style.direction {
        case .Row:
            return Container(measuredChildren, style, rect.withHeight(measuredCrossSize))
        case .Column:
            return Container(measuredChildren, style, rect.withWidth(measuredCrossSize))
        }
    }
    
    public func constrainTo(_ _width: Int, _ _height: Int) -> Node {
        switch style.direction {
        case .Row:
            return constrainRowTo(_width, _height)
        case .Column:
            return constrainColumnTo(_width, _height)
        }
    }
    
    func constrainRowTo(_ width: Int, _ height: Int) -> Node {
        if self.rect.width < width {
            // view too small
            let remaining = width - self.rect.width
            let grows = content.map { $0.style.grow }
            let totalGrow = grows.reduce(0) { $0 + $1 }
            let oneGrow = totalGrow == 0 ? 0 : (Float(remaining) / Float(totalGrow))
            let children = content.map { $0.withWidth($0.rect.width + Int(round(Float($0.style.grow) * oneGrow)))}
            let newWidth = children.map { $0.rect.width }.reduce(0, +)
            return self.withChildren(children).withWidth(newWidth)
        } else if self.rect.width > width {
            // view too large
            let scaledShrinkFactors = content.map { $0.style.shrink * Float($0.rect.width) }
            let totalScaledShrinkFactor = scaledShrinkFactors.reduce(0.0) { $0 + $1 }
            let children = content.map { $0.withWidth(Int(round($0.style.shrink * Float($0.rect.width) / totalScaledShrinkFactor))) }
            let newWidth = children.map { $0.rect.width }.reduce(0, +)
            return self.withChildren(children).withWidth(newWidth)
        }
        
        return self
    }
    
    func constrainColumnTo(_ width: Int, _ height: Int) -> Node {
        if self.rect.height < height {
            // view too small
            let remaining = height - self.rect.height
            let grows = content.map { $0.style.grow }
            let totalGrow = grows.reduce(0) { $0 + $1 }
            let oneGrow = totalGrow == 0 ? 0 :  Float(remaining) / Float(totalGrow)
            let children = content.map { $0.withHeight($0.rect.height + Int(round(Float($0.style.grow) * oneGrow)))}
            let newHeight = children.map { $0.rect.height }.reduce(0, +)
            return self.withChildren(children).withHeight(newHeight)
        } else if self.rect.height > height {
            // view too large
            let scaledShrinkFactors = content.map { $0.style.shrink * Float($0.rect.height) }
            let totalScaledShrinkFactor = scaledShrinkFactors.reduce(0.0) { $0 + $1 }
            let children = content.map { $0.withHeight(Int(round($0.style.shrink * Float($0.rect.height) / totalScaledShrinkFactor))) }
            let newHeight = children.map { $0.rect.height }.reduce(0, +)
            return self.withChildren(children).withHeight(newHeight)
        }
        
        return self
    }
    
    public func placeAt(x: Int, y: Int) -> Node {
        switch style.direction {
        case .Row:
            return placeAtRow(x: x, y: y)
        case .Column:
            return placeAtColumn(x: x, y: y)
        }
    }
    
    func placeAtRow(x: Int, y: Int) -> Node {
        var nextX = 0
        let placedChildren: [Node] = content.map {
            let placedChild: Node = $0.withX(nextX).withY(y)
            nextX = placedChild.rect.x + placedChild.rect.width
            return placedChild
        }
        
        return withChildren(placedChildren)
    }
    
    func placeAtColumn(x: Int, y: Int) -> Node {
        var nextY = 0
        let placedChildren: [Node] = content.map {
//            let placedChild = $0.withX(x).withY(nextY)
            let placedChild = $0.placeAt(x: x, y: nextY)
            nextY = placedChild.rect.y + placedChild.rect.height
            return placedChild
        }
        
        return withChildren(placedChildren)
    }
    
    public func withWidth(_ width: Int) -> Node {
        return Container(self.content, self.style, rect.withWidth(width))
    }
    
    public func withHeight(_ height: Int) -> Node {
        return Container(self.content, self.style, rect.withHeight(height))
    }
    
    public func withX(_ x: Int) -> Node {
        return Container(self.content, self.style, rect.withX(x))
    }
    
    public func withY(_ y: Int) -> Node {
        return Container(self.content, self.style, rect.withY(y))
    }
    
    public func withChildren(_ children: [Node]) -> Node {
        return Container(children, self.style, self.rect)
    }
    
    public func mainSize(for direction: FlexDirection) -> Int {
        return content.reduce(0) { $0 + $1.mainSize(for: direction) }
    }
    
    public func crossSize(for direction: FlexDirection) -> Int {
        return content.reduce(0) { $0 + $1.crossSize(for: direction) }
    }
    
    public func children() -> [Node]? {
        return content
    }
    
    public func renderTo(terminal: Slowbox) {
        content.forEach { $0.renderTo(terminal: terminal) }
    }
    
    public func contentAt(y: Int) -> Node? {
        if let node = content.first(where: { $0.rect.contains(y: y) }) {
            return node.contentAt(y: y)
        } else {
            return nil
        }
    }
    
    public var description: String {
        let children = content.map { "  " + $0.description }.joined(separator: "\n")
        return "Container(\(rect)) {\n\(children)\n}"
    }

    public func terminalDescription(_ depth: Int) -> String {
        let whitespace = String(repeating: " ", count: depth * 2)
        let children = content.map { $0.terminalDescription(depth + 1) }.joined(separator: "\n")
        return "\(whitespace)Container(\(rect), \(style)) {\n\(children)\n\(whitespace)}"
    }
}
