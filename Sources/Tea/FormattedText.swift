import Foundation
import Slowbox

public protocol TextType: CustomStringConvertible {
    func terminalContent() -> [(Formatting, Character)]
    func count() -> Int
}

public struct FormattedText: TextType {
    public let content: [(Formatting, Character)]
    
    public init(_ content: String, _ foreground: Color = .Default, _ background: Color = .Default) {
        self.content = Array(content).map { (Formatting(foreground, background), $0)}
    }
    
    init(_ content: [(Formatting, Character)]) {
        self.content = content
    }
    
    public func terminalContent() -> [(Formatting, Character)] {
        content
    }
    
    public func count() -> Int {
        content.count
    }
    
    public var description: String {
        String(content.map {
            $0.1
        })
    }
}

extension String: TextType {
    public func count() -> Int {
        count
    }
    
    public var content: [(Formatting, Character)] {
        Array(self).map { (Formatting(.Default, .Default), $0)}
    }
    
    public func terminalContent() -> [(Formatting, Character)] {
        Array(self).map {
            (Formatting(.Default, .Default), $0)
        }
    }
}

public func + (lhs: FormattedText, rhs: String) -> FormattedText {
    FormattedText(lhs.content + rhs.content)
}

public func + (lhs: String, rhs: FormattedText) -> FormattedText {
    FormattedText(lhs.content + rhs.content)
}

public func + (lhs: FormattedText, rhs: FormattedText) -> FormattedText {
    FormattedText(lhs.content + rhs.content)
}
