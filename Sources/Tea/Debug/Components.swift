import Foundation

public func htmlDocument(@HTMLBuilder content: () -> HTML) -> String {
    Document {
        html {
            head {
                title("TEA Debugger")
                meta("charset", "UTF-8")
                style("""
                      body, html { padding: 0; margin: 0; }
                      body { font-family: monospace; font-size: 12px; }
                      :root { --multiplier: 10px; }
                      .nav { width: 100%; height: 30px; background: white; color: black; display: flex; justify-content: center; padding-top: 15px; }
                      .menu { list-style: none; padding: 0; margin: 0; }
                      .menu-item { display: inline-block; }
                      .terminal { transform: rotate(0deg); background-color: #333; color: #eee; overflow: hidden; font-size: 8px; }
                      .container { border: 1px dashed blue; position: fixed; overflow: hidden; }
                      .content { border: 1px dashed red; position: fixed; }
                      .td { padding: 10px; }
                      .collapsed { height: 16px; overflow: hidden; }
                      """)
            }
            body {
                navigation()
                content()
            }
        }
    }.render()
}

public func navigation() -> HTML {
    nav("nav") {
        ul("menu") {
            li("menu-item") {
                a(href: "/") {
                    "View"
                }
            }
            li("menu-item") {
                a(href: "/model") {
                    "Model"
                }
            }
            li("menu-item") {
                a(href: "/log") {
                    "Log"
                }
            }
        }
    }
}