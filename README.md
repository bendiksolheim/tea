# Tea

Framework for building terminal applications in Swift, modelled after The Elm Architecture. Probably not something you want to use, as I don’t really know what I’m doing.

## Usage

```Swift
// Define your model. Must be both Equatable and Encodable
struct Model: Equatable, Encodable {
    let count: Int
}

// Define the actions your app should react to
enum Message {
    case Inc
    case Dec
}

// Subscribe to events
let subscriptions: [Sub<Message>] = [
  .Keyboard { event in
    switch event {
    case .k:
      return Cmd.message(.Inc)
    case .j:
      return Cmd.message(.Dec)
    default:
      return Cmd.none()
    }
  }
]

// Your "main loop". Receives a message, and reacts to it, in effect updating your apps state
func update(message: Message, model: Model) -> (Model, Cmd<Message>) {
    switch message {
    case .Inc:
      return (Model(count: model.count + 1), Cmd.none())
    case .Dec:
      return (Model(count: model.count - 1), Cmd.none())
    }
}

// Renders you app every time your model changes
func render(model: Model) -> Node {
    Vertical(.Auto, .Auto) {
        Text("Your count is:")
        Text("\(model.count)")
    }
}

// Create your app
let app = App(initialize: initialize, render: render, update: update, subscriptions: subscriptions)

// Run it!
application(app)

```
