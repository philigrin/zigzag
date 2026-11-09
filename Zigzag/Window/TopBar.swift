import AppKit

/// The bar above the page, as in Arc: back, forward and reload at the leading end, the address in the middle with its
/// extension buttons. It holds the sidebar's own controls, moved here (`SidebarView.moveControls(to:)`), so they act
/// and anchor popovers exactly as they do in the sidebar. On the window's frame, like the sidebar: it moves the window.
final class TopBarView: NSView {
    /// Its buttons on the traffic lights' line, the same as the sidebar's top row.
    static let height = Tokens.Sidebar.lightsCenter * 2
    /// The address never gets wider than this: a long one is cut, a short one sits centered.
    static let addressWidth: CGFloat = 560
    /// Room kept at the leading end, for the traffic lights while the sidebar is hidden.
    var leadingRoom: CGFloat = 0 { didSet { if oldValue != leadingRoom { needsLayout = true } } }
    weak var sidebar: SidebarView?

    override var isFlipped: Bool { true }
    override var mouseDownCanMoveWindow: Bool { true }
    override func mouseDown(with event: NSEvent) { SidebarView.titleBarClick(event, in: window) }

    override func layout() {
        super.layout()
        guard let sidebar, sidebar.address.superview === self else { return }
        let b = SidebarView.toolbarButton
        let y = round((bounds.height - b) / 2)
        var x = max(leadingRoom, Tokens.Sidebar.edge)
        for button in [sidebar.backButton, sidebar.forwardButton, sidebar.reloadButton] {
            button.frame = NSRect(x: x, y: y, width: b, height: b)
            x += b
        }
        // Centered on the bar, clear of the buttons on either side.
        let h = Tokens.Sidebar.addressHeight
        let room = max(0, min(bounds.midX - x, bounds.maxX - Tokens.Sidebar.edge - bounds.midX) - Tokens.Space.x2) * 2
        let width = min(room, Self.addressWidth)
        sidebar.address.frame = NSRect(x: round(bounds.midX - width / 2), y: round((bounds.height - h) / 2), width: width, height: h)
    }
}
