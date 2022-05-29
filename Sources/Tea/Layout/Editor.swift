import Foundation

public class Editor {
    public static func moveCursor<Msg>(_ dx: Int, _ dy: Int) -> Cmd<Msg> {
        Cmd(.Terminal(.MoveCursor(dx, dy)))
    }

    public static func putCursor<Msg>(_ x: Int, _ y: Int) -> Cmd<Msg> {
        Cmd(.Terminal(.PutCursor(x, y)))
    }

    public static func scroll<Msg>(_ x: Unit) -> Cmd<Msg> {
        Cmd(.Terminal(.Scroll(x)))
    }
}
