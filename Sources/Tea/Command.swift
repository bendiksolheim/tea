import Foundation

enum Command<Msg> {
    case None
    case Command(Msg)
    case Commands([Cmd<Msg>])
    case Task(TimeInterval, () -> Msg)
    case Quit(QuitResult)
    case Terminal(CursorCommand)
}

public enum QuitResult {
    case Success(String?)
    case Failure
}

public enum Unit {
    case Absolute(Int)
    case Percentage(Int)
}

public enum CursorCommand {
    case MoveCursor(Int, Int)
    case PutCursor(Int, Int)
    case Scroll(Unit)
}

public struct Cmd<Msg> {
    let cmd: Command<Msg>

    init(_ cmd: @escaping () -> Msg) {
        self.cmd = .Task(0.0, cmd)
    }

    init(_ type: Command<Msg>) {
        cmd = type
    }

    public static func message(_ msg: Msg) -> Cmd<Msg> {
        Cmd(.Command(msg))
    }

    public static func none() -> Cmd<Msg> {
        Cmd(.None)
    }

    public static func batch(_ cmds: Cmd<Msg>...) -> Cmd<Msg> {
        Cmd(.Commands(cmds))
    }
}
