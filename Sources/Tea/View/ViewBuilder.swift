import Foundation

@resultBuilder
public struct NodeBuilder {
    public static func buildBlock() -> [Node] {
        []
    }

    public static func buildBlock(_ components: Node...) -> [Node] {
        components
    }

    public static func buildBlock(_ components: [Node]) -> [Node] {
        components
    }

    public static func buildBlock(_ components: [Node]...) -> [Node] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [Node]?) -> [Node] {
        component ?? []
    }

    public static func buildEither(first components: [Node]) -> [Node] {
        components
    }

    public static func buildEither(first components: Node...) -> [Node] {
        components
    }

    public static func buildEither(second components: [Node]) -> [Node] {
        components
    }

    public static func buildEither(second components: Node...) -> [Node] {
        components
    }
}
