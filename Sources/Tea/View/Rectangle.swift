public struct Rectangle: Equatable, CustomStringConvertible {
    let x: Int
    let y: Int
    let width: Int
    let height: Int
    
    public static func empty() -> Rectangle {
        Rectangle(x: 0, y: 0, width: 0, height: 0)
    }

    public func with(x: Int? = nil, y: Int? = nil, width: Int? = nil, height: Int? = nil) -> Rectangle {
        Self(x: x ?? self.x, y: y ?? self.y, width: width ?? self.width, height: height ?? self.height)
    }
    
    public func withX(_ x: Int) -> Rectangle {
        Rectangle(x: x, y: y, width: width, height: height)
    }
    
    public func withY(_ y: Int) -> Rectangle {
        Rectangle(x: x, y: y, width: width, height: height)
    }
    
    public func withWidth(_ width: Int) -> Rectangle {
        Rectangle(x: x, y: y, width: width, height: height)
    }
    
    public func withHeight(_ height: Int) -> Rectangle {
        Rectangle(x: x, y: y, width: width, height: height)
    }
    
    public func contains(y: Int) -> Bool {
        self.y <= y && y < (self.y + self.height)
    }

    public var description: String {
        "{x: \(x), y: \(y), width: \(width), height: \(height)}"
    }
}
