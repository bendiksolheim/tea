import Darwin
import Foundation
import os.log
import ReactiveSwift
import Slowbox

let termQueue = DispatchQueue(label: "term.queue", qos: .background)
let taskQueue = DispatchQueue(label: "task.queue", qos: .userInitiated)

public enum Sub<Message> {
    case Keyboard((KeyEvent) -> Message)
    case Cursor((Cursor) -> Message)
    case TerminalSize((Size) -> Message)
    case None
}

public struct App<Model: Equatable, Message, Meta> {
    public let initialize: () -> (Model, Cmd<Message>)
    public let render: (Model, Size) -> ViewModel<Message, Meta>
    public let update: (Message, Model) -> (Model, Cmd<Message>)
    public let subscriptions: [Sub<Message>]

    public init(initialize: @escaping () -> (Model, Cmd<Message>),
                render: @escaping (Model, Size) -> ViewModel<Message, Meta>,
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

public func application<Model: Equatable, Message, Meta>(
        _ app: App<Model, Message, Meta>
) -> QuitResult {
    let runLoop = CFRunLoopGetCurrent()
    let terminal = Slowbox(io: TTY(), screen: .Alternate)
    var exitMessage: QuitResult = .Success(nil)

    let (initialModel, initialCommand) = app.initialize()
    var model = initialModel
    var view = measure("Initial render") {
        app.render(model, terminal.terminalSize()).layout(terminal)
    }
    render(view, terminal)

    let keyboardSubscription = getKeyboardSubscription(subscriptions: app.subscriptions)
    let terminalSizeSubscription = getTerminalResizeSubscription(subscriptions: app.subscriptions)
    let cursorSubscription = getCursorSubscription(subscriptions: app.subscriptions)

    let (messageOutput, messageInput) = Signal<Message, Never>.pipe()

    messageOutput.observeValues { message in
        let (updatedModel, command) = app.update(message, model)
        let modelChanged = !(updatedModel == model)
        model = updatedModel
        process(command: command, messageInput, terminal)

        if modelChanged {
            view = measure("Msg render") {
                app.render(model, terminal.terminalSize()).layout(terminal)
            }
            async {
                render(view, terminal)
            }
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
        os_log("%{public}@", "New event: \(event)")
        switch event {
        case let .Key(key):
            if let node = view.view.contentAt(y: terminal.cursor.y) {
                // Send key event to node under cursor
                var swallowed = false
                if let content = node as? Content<Message> {
                    content.events.forEach { evChar, message in
                        if evChar == key {
                            swallowed = true
                            async {
                                messageInput.send(value: message)
                            }
                        }
                    }
                }
                if !swallowed {
                    if let msg = keyboardSubscription?(key) {
                        async {
                            messageInput.send(value: msg)
                        }
                    }
                }
            } else {
                if let msg = keyboardSubscription?(key) {
                    async {
                        messageInput.send(value: msg)
                    }
                }
            }
        case let .Resize(size):
            view = measure("Resize render") {
                app.render(model, terminal.terminalSize()).layout(terminal)
            }
            async {
                render(view, terminal)
                if let msg = terminalSizeSubscription?(size) {
                    messageInput.send(value: msg)
                }
            }
        }
    }

    let completedHandler = {
        os_log("Quitting")
        CFRunLoopStop(runLoop)
        os_log("After CFRunLoopStop")
    }

    process(command: initialCommand, messageInput, terminal)

    let eventConsumer = Signal<Event, Never>.Observer(value: eventHandler, completed: completedHandler)

    messageOutput.observeCompleted {
        eventConsumer.sendCompleted()
    }

    // Run on separate thread, as .start blocks the thread it runs on, which in turn will block rendering
    termQueue.async {
        eventProducer.start(eventConsumer)
    }

    CFRunLoopRun()

    terminal.restore()
    return exitMessage
}

func render<Message, Data>(_ view: ViewModel<Message, Data>, _ terminal: Slowbox) {
    view.view.renderTo(terminal: terminal)
    terminal.present()
    terminal.clearBuffer()
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

func async(_ fn: @escaping () -> Void) {
    DispatchQueue.main.async(qos: .userInteractive) {
        fn()
    }
}

func process<Msg>(command: Cmd<Msg>, _ messageProducer: Signal<Msg, Never>.Observer, _ terminal: Slowbox) {
    os_log("%{public}@", "Processing command: \(command)")
    switch command.cmd {
    case .None:
        break

    case let .Command(message):
        async {
            messageProducer.send(value: message)
        }

    case let .Commands(commands):
        for command in commands {
            process(command: command, messageProducer, terminal)
        }

    case let .Task(delay, task):
        taskQueue.asyncAfter(deadline: .now() + delay) {
            let value = task()
            messageProducer.send(value: value)
        }

    case .Quit:
        // Exit strategy: first complete the message thread, as that is what we have access to from here. Then, from the
        // message thread completion callback, complete the polling thread.
        messageProducer.sendCompleted()

    case let .Terminal(terminalCommand):
        switch terminalCommand {
        case let .MoveCursor(xDelta, yDelta):
            let currentCursor = terminal.cursor
            terminal.moveCursor(currentCursor.x + xDelta, currentCursor.y + yDelta)
        case let .PutCursor(x, y):
            terminal.moveCursor(x, y)

        case let .Scroll(amount):
            break // TODO: implement me
        }

    case .Debug:
        break
//        renderDebug(viewModel, terminal)
    }
}
