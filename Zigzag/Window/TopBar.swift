import AppKit

/// The bar above the page, as in Arc: the sidebar button, back, forward and reload at the leading end, the address in the middle, and the
/// address's own buttons (Reader, camera, extensions) in a row at the trailing end. It holds the sidebar's own controls, moved here (`SidebarView.moveControls(to:)`), so they act
/// and anchor popovers exactly as they do in the sidebar. On the window's frame, like the sidebar: it moves the window.
final class TopBarView: NSView {
    /// Slim, as in Arc: the traffic lights and the sidebar's top row move up to its middle line while it shows.
    static let height: CGFloat = 36
    /// The address never gets wider than this: a long one is cut, a short one sits centered.
    static let addressWidth: CGFloat = 560
    weak var sidebar: SidebarView?
    /// A second sidebar button, shown while the sidebar is hidden; the sidebar keeps its own, to pin it open while
    /// it's slid out over this one.
    let sidebarButton = SidebarView.chromeButton("sidebar.left", toolTip: "")

    override init(frame: NSRect) {
        super.init(frame: frame)
        addSubview(sidebarButton)
    }

    required init?(coder: NSCoder) { fatalError() }

    /// Its layout is the same either way up; unflipped, its layer's top corners are at max Y.
    override var isFlipped: Bool { false }

    /// In the page's own color, as in Arc, so the bar and the page read as one card: its background (a site's theme
    /// color can be its header's, and stay light on a page that turned dark), else its theme color. Icons and text
    /// turn light or dark to match.
    func paint(for tab: Tab?) {
        let color = tab?.webView?.underPageBackgroundColor ?? tab?.themeColor
        wantsLayer = true
        layer?.backgroundColor = color.map { cgColor($0) }
        layer?.cornerCurve = .continuous
        layer?.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        appearance = color.map { NSAppearance(named: Tokens.Color.luminance(of: $0) < 0.5 ? .darkAqua : .aqua) } ?? nil
    }
    override var mouseDownCanMoveWindow: Bool { true }
    override func mouseDown(with event: NSEvent) { SidebarView.titleBarClick(event, in: window) }

    override func layout() {
        super.layout()
        guard let sidebar, sidebar.address.superview === self else { return }
        let b = SidebarView.toolbarButton
        let y = round((bounds.height - b) / 2)
        var x = Tokens.Sidebar.edge
        // The sidebar button first, always there, whether the sidebar shows or not.
        for button in [sidebarButton, sidebar.backButton, sidebar.forwardButton, sidebar.reloadButton] where !button.isHidden {
            button.frame = NSRect(x: x, y: y, width: b, height: b)
            x += b
        }
        var right = bounds.maxX - Tokens.Sidebar.edge
        for button in sidebar.address.trailingButtons.reversed() {
            button.frame = NSRect(x: right - b, y: y, width: b, height: b)
            button.radius = Tokens.Radius.control
            button.pressOutset = NSEdgeInsets()
            right -= b
        }
        for button in [sidebar.address.readerButton, sidebar.address.captureButton] where button.isHidden { button.frame = .zero }
        // Centered on the bar, clear of the buttons on either side.
        let h = Tokens.Pane.height - 2
        let room = max(0, min(bounds.midX - x, right - bounds.midX) - Tokens.Space.x2) * 2
        let width = min(room, Self.addressWidth)
        sidebar.address.frame = NSRect(x: round(bounds.midX - width / 2), y: round((bounds.height - h) / 2), width: width, height: h)
    }
}
