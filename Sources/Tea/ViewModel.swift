import Foundation
import Slowbox
import os.log

public struct ViewModel<Message, Data> {
    let view: Node
    public let data: Data
    
    public init(_ view: Node, _ data: Data) {
        self.view = view
        self.data = data
    }
    
    func layout(_ terminal: Slowbox) -> ViewModel<Message, Data> {
        let size = terminal.terminalSize()
        os_log("%{public}@", "Calculated size for terminal: \(size)")
        return ViewModel(Layout.calculate(node: view, width: size.width, height: size.height), data)
    }
}
