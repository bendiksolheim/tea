import Foundation
import Slowbox

public protocol TextType: CustomStringConvertible {
    func terminalContent() -> [(Formatting, Character)]
    func count() -> Int
}

public struct Text: TextType {
    public let content: [(Formatting, Character)]
    
    public init(_ content: String, _ foreground: Color = .Default, _ background: Color = .Default) {
        self.content = Array(content).map { (Formatting(foreground, background), $0)}
    }
    
    init(_ content: [(Formatting, Character)]) {
        self.content = content
    }
    
    public func terminalContent() -> [(Formatting, Character)] {
        return content
    }
    
    public func count() -> Int {
        return content.count
    }
    
    public var description: String {
        return String(content.map { $0.1 })
    }
}

extension String: TextType {
    public func count() -> Int {
        return self.count
    }
    
    public var content: [(Formatting, Character)] {
        Array(self).map { (Formatting(.Default, .Default), $0)}
    }
    
    public func terminalContent() -> [(Formatting, Character)] {
        return Array(self).map { (Formatting(.Default, .Default), $0)}
    }
}

public func + (lhs: Text, rhs: String) -> Text {
    return Text(lhs.content + rhs.content)
}

public func + (lhs: String, rhs: Text) -> Text {
    return Text(lhs.content + rhs.content)
}

public func + (lhs: Text, rhs: Text) -> Text {
    return Text(lhs.content + rhs.content)
}
