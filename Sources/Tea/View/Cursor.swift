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
}