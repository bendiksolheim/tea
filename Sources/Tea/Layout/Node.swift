import Foundation
import Slowbox

public protocol Node: CustomStringConvertible, TerminalDebugInfo {
    var rect: Rectangle { get }
    var style: FlexStyle { get }
    
    func withWidth(_ width: Int) -> Node
    func withHeight(_ height: Int) -> Node
    func withX(_ x: Int) -> Node
    func withY(_ y: Int) -> Node
    func measureMainSize() -> Node
    func measureCrossSize() -> Node
    func constrainTo(_ width: Int, _ height: Int) -> Node
    func mainSize(for: FlexDirection) -> Int
    func crossSize(for: FlexDirection) -> Int
    func placeAt(x: Int, y: Int) -> Node
    func children() -> [Node]?
    func renderTo(terminal: Slowbox)
    func contentAt(y: Int) -> Node?
}

public protocol TerminalDebugInfo {

    func terminalDescription(_ depth: Int) -> String
}
