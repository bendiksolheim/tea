import Foundation

func html(_ cls: String = "", @HTMLBuilder child: () -> HTML) -> HTML {
    HTMLNode(tag: "html", child: child(), attributes: ["class": cls])
}

func head(_ cls: String = "", @HTMLBuilder child: () -> HTML) -> HTML {
    HTMLNode(tag: "head", child: child(), attributes: ["class": cls])
}

func title(_ title: String) -> HTML {
    HTMLNode(tag: "title", child: title)
}

func meta(_ key: String, _ value: String) -> HTML {
    HTMLNode(tag: "meta", child: nil, inline: true, attributes: [key: value])
}

func style(_ styles: String) -> HTML {
    HTMLNode(tag: "style", child: styles)
}

func body(_ cls: String = "", @HTMLBuilder child: () -> HTML) -> HTML {
    HTMLNode(tag: "body", child: child(), attributes: ["class": cls])
}

func div(_ cls: String = "", _ attributes: [String:String] = [:], @HTMLBuilder child: () -> HTML) -> HTML {
    HTMLNode(tag: "div", child: child(), attributes: ["class": cls].combine(attributes))
}

func nav(_ cls: String = "", @HTMLBuilder child: () -> HTML) -> HTML {
    HTMLNode(tag: "nav", child: child(), attributes: ["class": cls])
}

func ul(_ cls: String = "", @HTMLBuilder child: () -> HTML) -> HTML {
    HTMLNode(tag: "ul", child: child(), attributes: ["class": cls])
}

func li(_ cls: String = "", @HTMLBuilder child: () -> HTML) -> HTML {
    HTMLNode(tag: "li", child: child(), attributes: ["class": cls])
}

func a(href: String, _ cls: String = "", @HTMLBuilder child: () -> HTML) -> HTML {
    HTMLNode(tag: "a", child: child(), attributes: ["href": href, "class": cls])
}

func table(_ cls: String = "", @HTMLBuilder child: () -> HTML) -> HTML {
    HTMLNode(tag: "table", child: child(), attributes: ["class": cls])
}

func tr(_ cls: String = "", @HTMLBuilder child: () -> HTML) -> HTML {
    HTMLNode(tag: "tr", child: child(), attributes: ["class": cls])
}

func th(_ cls: String = "", @HTMLBuilder child: () -> HTML) -> HTML {
    HTMLNode(tag: "th", child: child(), attributes: ["class": cls])
}

func td(_ cls: String = "", _ attributes: [String:String] = [:], @HTMLBuilder child: () -> HTML) -> HTML {
    HTMLNode(tag: "td", child: child(), attributes: ["class": cls].combine(attributes))
}

func script(_ script: String) -> HTML {
    HTMLNode(tag: "script", child: script)
}

func scriptSrc(_ src: String) -> HTML {
    HTMLNode(tag: "script", child: nil, attributes: ["src": src])
}
