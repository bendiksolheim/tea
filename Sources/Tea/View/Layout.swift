struct Layout {
    /**
     Prepare view for rendering in container of given width and height.
     - Parameters:
       - view: view to render
       - maxWidth: maximum allowed width
       - maxHeight: maximum allowed height
     - Returns: measured and constrained view, ready for rendering
     */

    static func calculateLayout(_ view: Node, maxWidth: Int, maxHeight: Int) -> Node {
        view
                .measureContent()
                .adjustTo(maxWidth: maxWidth, maxHeight: maxHeight)
                .placeAt(x: 0, y: 0)
    }
}
