import Foundation

func adjustSize(_ size: ViewSize, _ currentSize: Int, _ maxSize: Int) -> Int {
    switch size {
    case .Auto:
        return min(currentSize, maxSize)
    case let .Percentage(pct):
        return Int(round((Float(pct) / 100.0) * Float(maxSize)))
    case let .Exact(exact):
        return min(exact, maxSize)
    case .Fill:
        return max(currentSize, maxSize)
    }
}

func move(_ steps: Int, _ view: Node, _ cursor: Cursor) -> Cursor {
    debug_log("MOVE")
    let current = cursor.y
    if steps < 0 {
        // scrolling up
        if current <= view.rect.y {
            // already at top of view, scroll view instead
            let newScroll = max(cursor.scroll + steps, 0)
            return cursor.with(scroll: newScroll)
//            return view.scroll(amount: newScroll)
        } else {
            // move cursor up
            let cappedSteps = current + steps < 0 ? 0 - current : steps
//            terminal.moveCursor(0, terminal.cursor.y + cappedSteps)
            return cursor.with(y: current + cappedSteps)
        }
    } else {
        // scrolling down
        debug_log("HMM: \(current), \(view.rect.height - 1)")
        if current >= view.rect.height - 1 {
            debug_log("LETS SCROLL")
            let newScroll = min(cursor.scroll + steps, view.actualSize().height - view.rect.height)
//            return view.scroll(amount: newScroll)
            return cursor.with(scroll: newScroll)
        } else {
            debug_log("LETS MOVE")
            let cappedSteps = current + steps > view.actualSize().height ? (view.actualSize().height - current - 1) : min(steps, view.actualSize().height - current - 1)
//            terminal.moveCursor(0, terminal.cursor.y + cappedSteps)
            return cursor.with(y: current + cappedSteps)
//            return view
        }
    }
}
