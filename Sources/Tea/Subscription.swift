import Foundation
import Slowbox

enum Subscription<Message> {
    case Keyboard((KeyEvent) -> Message)
    case Cursor((Cursor) -> Message)
    case TerminalSize((Size) -> Message)
    case Clock(TimeInterval, (Date) -> Message)
    case None
}

public struct Sub<Msg> {
    let sub: Subscription<Msg>

    init(_ sub: Subscription<Msg>) {
        self.sub = sub
    }
}