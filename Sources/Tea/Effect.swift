import Foundation
import Bow
import BowEffects

public struct Effect<R> {
    let task: IO<Error, R>
    let delay: TimeInterval

    public init(_ task: IO<Error, R>) {
        self.task = task
        delay = 0.0
    }

    init(_ task: IO<Error, R>, _ delay: TimeInterval) {
        self.task = task
        self.delay = delay
    }

    public func perform<Msg>(_ failure: @escaping (Error) -> Msg, _ success: @escaping (R) -> Msg) -> Cmd<Msg> {
        Cmd(.Task(delay) {
            task.unsafeRunSyncEither(on: taskQueue).fold(failure, success)
        })
    }

    public func perform<Msg>(_ mapper: @escaping(Either<Error, R>) -> Msg) -> Cmd<Msg> {
        Cmd(.Task(delay) {
            mapper(task.unsafeRunSyncEither(on: taskQueue))
        })
    }
    public func andThen<R2>(_ fn: @escaping (R) -> R2) -> Effect<R2> {
        Effect<R2>(task.map { fn($0) }^)
    }

    public static func sequence(_ tasks: [Effect<R>]) -> Effect<[R]> {
        Effect<[R]>(tasks.map {
                    $0.task
                }
                .sequence()^)
    }
}
