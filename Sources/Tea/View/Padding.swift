import Foundation

public struct Padding {
    public let top: Int
    public let right: Int
    public let bottom: Int
    public let left: Int

    public init(top: Int = 0, right: Int = 0, bottom: Int = 0, left: Int = 0) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }
}