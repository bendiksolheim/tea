import Foundation

public struct Cursor: Equatable, Encodable {
    let y: Int
    let scroll: Int

    public static func initial() -> Cursor {
        Cursor(y: 0, scroll: 0)
    }

    func with(y: Int? = nil, scroll: Int? = nil) -> Cursor {
        Self(y: y ?? self.y, scroll: scroll ?? self.scroll)
    }

    public static func move<Msg>(_ dx: Int, _ dy: Int) -> Cmd<Msg> {
        Cmd(.Terminal(.MoveCursor(dx, dy)))
    }

    public static func put<Msg>(_ x: Int, _ y: Int) -> Cmd<Msg> {
        Cmd(.Terminal(.PutCursor(x, y)))
    }

    public static func scroll<Msg>(_ x: Unit) -> Cmd<Msg> {
        Cmd(.Terminal(.Scroll(x)))
    }

    public static func onMove<Msg>(_ fn: @escaping (Cursor) -> Msg) -> Sub<Msg> {
        Sub(.Cursor(fn))
    }
}