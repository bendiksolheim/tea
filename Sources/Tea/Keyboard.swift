import Foundation
import Slowbox

public struct Keyboard {
    public static func onKeyPress<Msg>(_ fn: @escaping (KeyEvent) -> Msg) -> Sub<Msg> {
        Sub(.Keyboard(fn))
    }
}