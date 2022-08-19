import Darwin
import Foundation
import os.log
import ReactiveSwift
import Slowbox
import Swifter

let termQueue = DispatchQueue(label: "term.queue", qos: .background)
let taskQueue = DispatchQueue(label: "task.queue", qos: .userInitiated)

public enum Sub<Message> {
    case Keyboard((KeyEvent) -> Message)
    case Cursor((Cursor) -> Message)
    case TerminalSize((Size) -> Message)
    case None
}

enum AppEvent<Message> {
    case App(Message)
    case Cursor(CursorCommand)
}

public struct App<Model: Equatable & Encodable, Message> {
    public let initialize: () -> (Model, Cmd<Message>)
    public let render: (Model) -> Node
    public let update: (Message, Model) -> (Model, Cmd<Message>)
    public let subscriptions: [Sub<Message>]

    public init(initialize: @escaping () -> (Model, Cmd<Message>),
                render: @escaping (Model) -> Node,
                update: @escaping (Message, Model) -> (Model, Cmd<Message>),
                subscriptions: [Sub<Message>]) {
        self.initialize = initialize
        self.render = render
        self.update = update
        self.subscriptions = subscriptions
    }
}

public struct TerminalInfo {
    public let cursor: Cursor
    public let size: Size
}

public func application<Model: Equatable & Encodable, Message>(
        _ app: App<Model, Message>
) -> QuitResult {
    let runLoop = CFRunLoopGetCurrent()
    let terminal = Slowbox(io: TTY(), screen: .Alternate)
    var exitMessage: QuitResult = .Success(nil)

    let (initialModel, initialCommand) = app.initialize()
    var model = initialModel
    var view = measure("Initial render") {
        Layout.calculateLayout(app.render(model), maxWidth: terminal.terminalSize().width, maxHeight: terminal.terminalSize().height)
    }
    render(view, terminal)

    let debugServer = HttpServer()
    debugServer["/"] = { req in
        .ok(.html(viewRepresentation(view, terminal)))
    }
    debugServer["/model"] = { req in
        .ok(.html(modelRepresentation(model)))
    }
    debugServer["/log"] = { req in
        .ok(.html(logRepresentation()))
    }
    try! debugServer.start(8090)

    let keyboardSubscription = getKeyboardSubscription(subscriptions: app.subscriptions)
    let terminalSizeSubscription = getTerminalResizeSubscription(subscriptions: app.subscriptions)
    let cursorSubscription = getCursorSubscription(subscriptions: app.subscriptions)

    let (messageOutput, messageInput) = Signal<AppEvent<Message>, Never>.pipe()

    messageOutput.observeValues { ev in
        debug_log("messageOutput")
        switch ev {
        case let .App(message):
            debug_log("App message: \(message)")
            let (updatedModel, command) = app.update(message, model)
            let modelChanged = !(updatedModel == model)
            model = updatedModel
            process(command: command, messageInput, terminal, view, &exitMessage)

            if modelChanged {
                view = measure("Msg render") {
                    Layout.calculateLayout(app.render(model), maxWidth: terminal.terminalSize().width, maxHeight: terminal.terminalSize().height)
                }
                async {
                    render(view, terminal)
                }
            }
        case let .Cursor(cursorCommand):
            debug_log("Cursor command: \(cursorCommand)")
            let newModel = view.modifyCursor(cursorCommand: cursorCommand)
            if let cursorSubscription = cursorSubscription, let newModel = newModel {
                let message = cursorSubscription(newModel)
                async {
                    messageInput.send(value: .App(message))
                }
            }
//            view = view.modifyCursor { focused in
//                debug_log("Modifying focused")
//                switch cursorCommand {
//                case let .MoveCursor(_, yDelta):
//                    return move(yDelta, focused, terminal)
//                case let .PutCursor(x, y):
//                    terminal.moveCursor(x, y)
//                    return focused
//
//                case let .Scroll(amount):
//                    return focused // TODO: implement me
//                }
//            }
//            async {
//                render(view, terminal)
//            }
        }
    }

    let eventProducer: SignalProducer<Event, Never> = SignalProducer { (observer, lifetime) in
        while !lifetime.hasEnded {
            if let event = terminal.poll() {
                if event == .Key(.CtrlC) {
                    observer.sendCompleted()
                    messageInput.sendCompleted()
                } else {
                    observer.send(value: event)
                }
            }
        }
    }

    let eventHandler = { (event: Event) in
        debug_log("New event: \(event)")
        switch event {
        case let .Key(key):
            debug_log("Key event: \(key)")
            if let node = view.viewFocused() {
                debug_log("App has focused view")
                // Send key event to node under cursor
                var swallowed = false
                if let content = node as? Text<Message> {
                    content.events.forEach { evChar, message in
                        if evChar == key {
                            swallowed = true
                            async {
                                debug_log("Key captured by focused view")
                                messageInput.send(value: .App(message))
                            }
                        }
                    }
                }
                if !swallowed {
                    if let msg = keyboardSubscription?(key) {
                        async {
                            debug_log("Key not captured, sending to app")
                            messageInput.send(value: .App(msg))
                        }
                    }
                }
            } else {
                debug_log("Checking for keyboard subscription")
                if let msg = keyboardSubscription?(key) {
                    async {
                        debug_log("Sending to app")
                        messageInput.send(value: .App(msg))
                    }
                }
            }
        case let .Resize(size):
            view = measure("Resize render") {
                Layout.calculateLayout(app.render(model), maxWidth: terminal.terminalSize().width, maxHeight: terminal.terminalSize().height)
            }
            async {
                render(view, terminal)
                if let msg = terminalSizeSubscription?(size) {
                    messageInput.send(value: .App(msg))
                }
            }
        }
    }

    let completedHandler = {
        debug_log("Quitting")
        CFRunLoopStop(runLoop)
        debug_log("After CFRunLoopStop")
    }

    process(command: initialCommand, messageInput, terminal, view, &exitMessage)

    let eventConsumer = Signal<Event, Never>.Observer(value: eventHandler, completed: completedHandler)

    messageOutput.observeCompleted {
        eventConsumer.sendCompleted()
    }

    // Run on separate thread, as .start blocks the thread it runs on, which in turn will block rendering
    termQueue.async {
        eventProducer.start(eventConsumer)
    }

    CFRunLoopRun()

    debugServer.stop()
    terminal.restore()
    return exitMessage
}

func render(_ view: Node, _ terminal: Slowbox) {
    view.renderTo(terminal: terminal)
    terminal.present()
    terminal.clearBuffer()
}

func process<Msg>(command: Cmd<Msg>, _ messageProducer: Signal<AppEvent<Msg>, Never>.Observer, _ terminal: Slowbox, _ view: Node, _ quitResult: inout QuitResult) {
    debug_log("Processing command: \(command)")
    switch command.cmd {
    case .None:
        break

    case let .Command(message):
        async {
            messageProducer.send(value: .App(message))
        }

    case let .Commands(commands):
        for command in commands {
            process(command: command, messageProducer, terminal, view, &quitResult)
        }

    case let .Task(delay, task):
        taskQueue.asyncAfter(deadline: .now() + delay) {
            let value = task()
            messageProducer.send(value: .App(value))
        }

    case let .Quit(result):
        quitResult = result
        // Exit strategy: first complete the message thread, as that is what we have access to from here. Then, from the
        // message thread completion callback, complete the polling thread.
        messageProducer.sendCompleted()

    case let .Terminal(terminalCommand):
        async {
            messageProducer.send(value: .Cursor(terminalCommand))
        }
    }
}

func async(_ fn: @escaping () -> Void) {
    DispatchQueue.main.async(qos: .userInteractive) {
        fn()
    }
}

func getKeyboardSubscription<Message>(subscriptions: [Sub<Message>]) -> ((KeyEvent) -> Message)? {
    for subscription in subscriptions {
        switch subscription {
        case let .Keyboard(fn):
            return fn
        default:
            break
        }
    }

    return nil
}

func getTerminalResizeSubscription<Message>(subscriptions: [Sub<Message>]) -> ((Size) -> Message)? {
    for subscription in subscriptions {
        switch subscription {
        case let .TerminalSize(fn):
            return fn
        default:
            break
        }
    }

    return nil
}

func getCursorSubscription<Message>(subscriptions: [Sub<Message>]) -> ((Cursor) -> Message)? {
    for subscription in subscriptions {
        switch subscription {
        case let .Cursor(fn):
            return fn
        default:
            break
        }
    }

    return nil
}

//func scroll(_ model: Model, _ steps: Int, _ viewHeight: Int, _ current: Int, _ terminalHeight: Int, _ view: View) -> (Model, Cmd<Message>) {
//    let scroll = view.viewModel.scroll
//    if steps < 0 {
//        // scrolling up
//        let newScroll = max(scroll + steps, 0)
//        if newScroll != scroll + steps {
//            // We have reached the top, start moving cursor instead
//            let (movedModel, movedCmd) = move(model, scroll + steps - newScroll, viewHeight, current, terminalHeight, view)
//            return (movedModel.replace(buffer: view.with(viewModel: UIModel(scroll: newScroll))), movedCmd)
//        } else {
//            return (model.replace(buffer: view.with(viewModel: UIModel(scroll: newScroll))), Cmd.none())
//        }
//    } else {
//        // scrolling down
//        let newScroll = min(scroll + steps, max(viewHeight - terminalHeight, 0))
//        if newScroll != scroll + steps {
//            // We have reached the bottom, start moving cursor instead
//            let (movedModel, movedCmd) = move(model, scroll + steps - newScroll, viewHeight, current, terminalHeight, view)
//            return (movedModel.replace(buffer: view.with(viewModel: UIModel(scroll: newScroll))), movedCmd)
//        } else {
//            return (model.replace(buffer: view.with(viewModel: UIModel(scroll: newScroll))), Cmd.none())
//        }
//    }
//}
