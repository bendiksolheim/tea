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
