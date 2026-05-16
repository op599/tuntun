import AppKit

/// 双 NSStatusItem 架构 (HiddenBar / Ice 通用方案):
///   - button:    可见的 click 按钮, length = variable (≈28pt), 位置固定
///   - separator: 隐形分隔符, length 在 1pt ↔ 10000pt 切换实现"折叠/展开"
///                折叠时 separator 撑大 → 把它左侧 (= button 左侧) 的其它 app 图标挤出可见区
///   - 两个 item 都设 autosaveName, ⌘+drag 拖到的位置永久保存
///   - macOS 会把 length=10000 clamp 到约 5000, 但够把屏幕宽度都吃掉
@MainActor
final class StatusBarController {
    private let button: NSStatusItem
    private let separator: NSStatusItem
    private(set) var isCollapsed = false

    private let onToggle: (Bool) -> Void
    private let onRightClick: () -> Void

    private static let separatorExpanded: CGFloat = 1
    private static let separatorCollapsed: CGFloat = 10_000

    init(initialCollapsed: Bool,
         onToggle: @escaping (Bool) -> Void,
         onRightClick: @escaping () -> Void) {
        self.onToggle = onToggle
        self.onRightClick = onRightClick

        let bar = NSStatusBar.system

        // 1) 按钮先创建 (=> 在菜单栏的最右端, 离系统区最近)
        button = bar.statusItem(withLength: NSStatusItem.variableLength)
        button.autosaveName = "com.op599.tuntun.button"
        button.button?.title = initialCollapsed ? "▾" : "▸"
        button.button?.font = NSFont.systemFont(ofSize: 14, weight: .medium)

        // 2) 分隔符后创建 (=> 在按钮的左侧). 它撑大时把更左侧的图标挤出
        separator = bar.statusItem(withLength: initialCollapsed ? Self.separatorCollapsed : Self.separatorExpanded)
        separator.autosaveName = "com.op599.tuntun.separator"
        separator.button?.title = ""

        isCollapsed = initialCollapsed

        // 所有 stored property 都初始化后, 再 wire 按钮 target/action (Swift 规定)
        if let btn = button.button {
            btn.target = self
            btn.action = #selector(handleClick(_:))
            btn.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc private func handleClick(_ sender: Any?) {
        let evt = NSApp.currentEvent
        let isRight = evt?.type == .rightMouseUp || evt?.type == .rightMouseDown
        let isCtrl = (evt?.modifierFlags.contains(.control) ?? false)
            && (evt?.type == .leftMouseUp || evt?.type == .leftMouseDown)
        if isRight || isCtrl {
            onRightClick()
        } else {
            toggleCollapsed()
        }
    }

    func toggleCollapsed() {
        apply(collapsed: !isCollapsed, fire: true)
    }

    private func apply(collapsed: Bool, fire: Bool) {
        isCollapsed = collapsed
        separator.length = collapsed ? Self.separatorCollapsed : Self.separatorExpanded
        button.button?.title = collapsed ? "▾" : "▸"
        if fire { onToggle(collapsed) }
    }

    /// pt from the right edge of the main screen to the right edge of our button.
    /// Returns -1 if not available.
    func distanceFromRightEdge() -> CGFloat {
        guard let window = button.button?.window else { return -1 }
        guard let screen = NSScreen.main else { return -1 }
        let buttonRightX = window.frame.maxX
        let screenRightX = screen.frame.maxX
        return screenRightX - buttonRightX
    }
}
