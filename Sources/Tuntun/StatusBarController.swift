import AppKit

/// 单 NSStatusItem 设计:
///   - 展开态: length = 28pt, button 显示 "▸"
///   - 折叠态: length = 10000pt, button 显示 "▾", alignment=.right 让 ▾ 贴右边
///     macOS 会把我左边的其它 status item 挤出可见区域 (经典 HiddenBar/Ice/Dozer 方案)
///   - autosaveName: 用户 ⌘+drag 拖到的位置永久保存
@MainActor
final class StatusBarController {
    private let item: NSStatusItem
    private(set) var isCollapsed: Bool = false

    private let onToggle: (Bool) -> Void
    private let onRightClick: () -> Void

    private static let lenExpanded: CGFloat = 28
    private static let lenCollapsed: CGFloat = 10_000

    init(initialCollapsed: Bool,
         onToggle: @escaping (Bool) -> Void,
         onRightClick: @escaping () -> Void) {
        self.onToggle = onToggle
        self.onRightClick = onRightClick

        let bar = NSStatusBar.system
        let item = bar.statusItem(withLength: Self.lenExpanded)
        item.autosaveName = "com.op599.tuntun.toggle"
        self.item = item

        if let button = item.button {
            button.title = initialCollapsed ? "▾" : "▸"
            button.alignment = .right
            button.font = NSFont.systemFont(ofSize: 14, weight: .medium)
            button.target = self
            button.action = #selector(handleClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        if initialCollapsed {
            apply(collapsed: true, fireCallback: false)
        }
    }

    @objc private func handleClick(_ sender: Any?) {
        let evt = NSApp.currentEvent
        let isRight = evt?.type == .rightMouseUp || evt?.type == .rightMouseDown
        let isCtrlClick = (evt?.modifierFlags.contains(.control) ?? false)
            && (evt?.type == .leftMouseUp || evt?.type == .leftMouseDown)
        if isRight || isCtrlClick {
            onRightClick()
        } else {
            toggleCollapsed()
        }
    }

    func toggleCollapsed() {
        apply(collapsed: !isCollapsed, fireCallback: true)
    }

    private func apply(collapsed: Bool, fireCallback: Bool) {
        isCollapsed = collapsed
        item.length = collapsed ? Self.lenCollapsed : Self.lenExpanded
        item.button?.title = collapsed ? "▾" : "▸"
        if fireCallback { onToggle(collapsed) }
    }

    /// pt from the right edge of the main screen to the right edge of our button.
    /// Returns -1 if not available.
    func distanceFromRightEdge() -> CGFloat {
        guard let window = item.button?.window else { return -1 }
        guard let screen = NSScreen.main else { return -1 }
        let buttonRightX = window.frame.maxX
        let screenRightX = screen.frame.maxX
        return screenRightX - buttonRightX
    }
}
