import AppKit
import Foundation
import Slowbox

struct LogItem {
    let timestamp: Date
    let file: String
    let content: String
}

private var log: [LogItem] = []

func debug_log(_ message: String, _ file: String = #file) {
    log.append(LogItem(timestamp: Date(), file: file, content: message))
}

func viewRepresentation(_ view: Node, _ terminal: Slowbox) -> String {
    let rect = Rectangle(x: 0, y: 0, width: terminal.terminalSize().width, height: terminal.terminalSize().height)
    let style = "width:\(cssPx(terminal.terminalSize().width)); height:\(cssPx(terminal.terminalSize().height));"
    return htmlDocument {
        div("terminal", ["data-rect": rect.description, "style": style]) {
            view.htmlRepresentation()
        }
    }
}

func modelRepresentation<T: Encodable>(_ model: T) -> String {
    let encoder = JSONEncoder()
    let data = try! encoder.encode(model)
    let json = String(data: data, encoding: .utf8)!
    let fixedJson = json.replacingOccurrences(of: "$", with: "_").replacingOccurrences(of: "\\", with: "\\\\")
    let jsonRenderer = """
                              const data = JSON.parse(`\(fixedJson)`);
                              const plugins = [SonjReview.plugins.autoExpand(1)]
                              const viewer = new SonjReview.JsonViewer(data, "Model", plugins);
                              viewer.render("model");

                       """
    return htmlDocument {
        scriptSrc("https://cdn.jsdelivr.net/npm/sonj-review/dist/sonj-review.min.js")
        div("model", ["id": "model"]) {
        }
        script(jsonRenderer)
    }
}

func logRepresentation() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSSZ"
    return htmlDocument {
        table {
            tr {
                th("td") {
                    "Timestamp"
                }
                th("td") {
                    "File"
                }
                th("td") {
                    "Message"
                }
            }
            for l in log.reversed() {
                tr {
                    td("td", ["valign": "top"]) {
                        formatter.string(from: l.timestamp)
                    }
                    td("td", ["valign": "top"]) {
                        l.file.split(regex: "/").last ?? l.file
                    }
                    td("td", ["valign": "top"]) {
                        div("collapse collapsed") {
                            l.content.replacingOccurrences(of: "\n", with: "<br />")
                        }
                    }
                }
            }
        }
        script("""
               document.querySelectorAll(".collapse").forEach(item => item.addEventListener("click", i => item.classList.toggle("collapsed")));
               """)
    }
}

func cssPx(_ value: Int) -> String {
    "calc(var(--multiplier) * \(value))"
}
