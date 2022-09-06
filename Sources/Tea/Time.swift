import Foundation

public struct Time {
    public static func every<Msg>(seconds: TimeInterval, _ fn: @escaping (Date) -> Msg) -> Sub<Msg> {
        Sub(.Clock(seconds, fn))
    }
}