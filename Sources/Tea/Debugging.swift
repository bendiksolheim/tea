import Foundation
import Slowbox

func renderDebug<Message, Data>(_ view: ViewModel<Message, Data>, _ terminal: Slowbox) {
    view.view.terminalDescription(0).split(regex: "\n").enumerated().forEach { e in
        let y = e.offset
        let line: String = e.element
        line.enumerated().forEach { c in
            let x = c.offset
            let char: Character = c.element
            terminal.put(x: x, y: y, cell: Cell(char))
        }
    }

    terminal.present()
    terminal.clearBuffer()
}
