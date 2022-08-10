import Foundation

public enum ViewSize: Equatable {
    case Auto             // Calculate size based on measured size
    case Percentage(Int)  // Calculate size based on parent size
    case Exact(Int)       // Set size exactly to a value
    case Fill             // Fill available space in parent
}