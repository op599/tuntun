import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBar: StatusBarController?
    private var settingsWindow: NSWindow?
    private var hotkey: GlobalHotkey?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBar = StatusBarController(
            initialCollapsed: Config.shared.collapsed,
            onToggle: { [weak self] collapsed in
                Config.shared.collapsed = collapsed
                self?.refreshSettingsWindow()
            },
            onRightClick: { [weak self] in
                self?.showSettings()
            }
        )

        hotkey = GlobalHotkey(keyCode: 4 /* H */, modifiers: [.control, .option]) { [weak self] in
            self?.statusBar?.toggleCollapsed()
        }
    }

    func showSettings() {
        if settingsWindow == nil {
            let hosting = NSHostingController(rootView: SettingsView(controller: self))
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 540),
                styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                backing: .buffered, defer: false
            )
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.isReleasedWhenClosed = false
            window.contentViewController = hosting
            window.center()
            window.title = "囤囤"
            settingsWindow = window
        }
        NSApp.setActivationPolicy(.regular)
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func refreshSettingsWindow() {
        if let hosting = settingsWindow?.contentViewController as? NSHostingController<SettingsView> {
            hosting.rootView = SettingsView(controller: self)
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag { showSettings() }
        return true
    }

    func toggleCollapsed() {
        statusBar?.toggleCollapsed()
    }

    func quit() {
        NSApp.terminate(nil)
    }

    func currentCollapsed() -> Bool {
        statusBar?.isCollapsed ?? false
    }

    func distanceFromRightEdge() -> CGFloat {
        statusBar?.distanceFromRightEdge() ?? -1
    }
}

extension NSWindow {
    static func makeSettings(delegate: AppDelegate) -> NSWindow {
        let hosting = NSHostingController(rootView: SettingsView(controller: delegate))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 540),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered, defer: false
        )
        window.contentViewController = hosting
        window.center()
        window.title = "囤囤"
        return window
    }
}
