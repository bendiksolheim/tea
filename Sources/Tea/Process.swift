import BowEffects
import Foundation

public typealias XDelta = Int
public typealias YDelta = Int

public class Tea {
    public static func quit<Msg>(_ msg: String? = nil) -> Cmd<Msg> {
        Cmd(.Quit(.Success(msg)))
    }

    public static func sleep(_ interval: TimeInterval) -> Effect<Void> {
        let cappedInterval = max(interval, 0.0)
        return Effect<Void>(IO.invoke({}), cappedInterval)
    }

    public static func debug(_ message: String, _ file: String = #file) {
        debug_log(message, file)
    }
}
