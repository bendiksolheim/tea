import Foundation

struct Document {
    let content: HTML

    init(@HTMLBuilder content: () -> HTML) {
        self.content = content()
    }

    func render() -> String {
        """
        <!DOCTYPE html>
        \(content.render())
        """
    }
}

public protocol HTML {
    func render() -> String
}

@resultBuilder
public struct HTMLBuilder {
    public static func buildBlock() -> HTML {
        MultiNode(children: [])
    }

    public static func buildBlock(_ content: HTML) -> HTML {
        content
    }

    public static func buildBlock(_ content: HTML...) -> HTML {
        MultiNode(children: content)
    }

    public static func buildArray(_ components: [HTML]) -> HTML {
        MultiNode(children: components)
    }
}

struct HTMLNode: HTML {
    let tag: String
    let child: HTML?
    let inline: Bool
    var attributes: [String: String] = [:]

    init(tag: String, child: HTML?, attributes: [String: String] = [:]) {
        self.tag = tag
        self.child = child
        inline = false
        self.attributes = attributes
    }

    init(tag: String, child: HTML?, inline: Bool, attributes: [String: String] = [:]) {
        self.tag = tag
        self.child = child
        self.inline = inline
        self.attributes = attributes
    }

    func render() -> String {
        var html = "<\(tag)"

        attributes.forEach { (key, value) in
            html += " \(key)=\"\(value)\""
        }

        html += ">"

        if inline {
            return html
        } else {
            html += child?.render() ?? ""
            html += "</\(tag)>"
            return html
        }
    }
}

struct MultiNode: HTML {
    let children: [HTML]

    func render() -> String {
        children.map { $0.render() }.joined()
    }
}

extension String: HTML {
    public func render() -> String {
        self
    }


}