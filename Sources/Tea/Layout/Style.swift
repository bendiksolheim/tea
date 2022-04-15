public struct FlexStyle: CustomStringConvertible {
    let direction: FlexDirection
    let grow: Float
    let shrink: Float
    
    public init(direction: FlexDirection = .Row, grow: Float = 0.0, shrink: Float = 1.0) {
        self.direction = direction
        self.grow = grow
        self.shrink = shrink
    }

    public var description: String {
        return "{ direction: \(direction), grow: \(grow), shrink: \(shrink) }"
    }
}
