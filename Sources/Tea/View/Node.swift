import Foundation
import Slowbox

public protocol Node: TerminalHtmlRepresentation {
    var rect: Rectangle { get }
    var children: [Node] { get }
    var width: ViewSize { get }
    var height: ViewSize { get }
    func measureContent() -> Self
    func adjustTo(maxWidth: Int, maxHeight: Int) -> Node
    func placeAt(x: Int, y: Int) -> Node
    func contentAt(y: Int) -> Node?
    func viewFocused() -> Node?
    func actualSize() -> Size
    func hasCursor() -> Bool
    func modifyCursor(cursorCommand: CursorCommand) -> Cursor?
    func renderTo(terminal: Slowbox)
}

public protocol TerminalHtmlRepresentation {
    func htmlRepresentation() -> HTML
}
