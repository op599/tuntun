# Tuntun (囤囤)

English · [简体中文](./README.zh-CN.md)

> Stash macOS menu-bar icons. Pure Swift + SwiftUI. ~700 KB binary.

Sister project: clipboard manager [Tietie (贴贴)](https://github.com/op599/tietie).

## What it does

On notched MacBook Pros the menu bar is cramped; third-party app icons get pushed off-screen.

Tuntun adds **one** `NSStatusItem` to your menu bar showing a small `▸` button.

```
[ other apps ... ]  ▸   Wi-Fi  Battery  Time
```

- **Left-click** `▸` — collapse (item's length stretches to 10000 pt, pushing the icons on its left out of view, anchoring the `▾` glyph to the right edge of its slot via `NSTextAlignment.right`)
- **Left-click** `▾` — expand (length back to 28 pt, icons return)
- **Right-click** (or `⌃`+click) `▸` — open the settings window
- **`⌃⌥H`** — global hotkey toggle from anywhere

No private APIs, no Accessibility, zero system modifications.
The status item uses `autosaveName` so once you `⌘`-drag it to your preferred spot (e.g. flush right against Wi-Fi), macOS remembers across launches.

## Download

[Releases](https://github.com/op599/tuntun/releases) — universal binary (Apple Silicon + Intel).

| Format | Notes |
|---|---|
| `Tuntun_x.y.z.dmg` | drag to Applications |
| `Tuntun_x.y.z.app.tar.gz` | tarred app for scripted installs |

macOS 12 (Monterey) and newer. App is unsigned; first launch needs *System Settings → Privacy & Security → Open Anyway*.

## Local development

```bash
make build          # swift build -c release
make bundle         # universal .app
make install        # → /Applications/Tuntun.app
make dmg            # produce a DMG
```

Requires Xcode command-line tools (`swift` 5.9+).

## Architecture

```
tuntun/
├── Package.swift
├── Sources/Tuntun/
│   ├── main.swift              # NSApplication entry
│   ├── AppDelegate.swift       # window/hotkey lifecycle
│   ├── StatusBarController.swift # 1 NSStatusItem, the whole act
│   ├── SettingsView.swift      # SwiftUI settings window
│   ├── GlobalHotkey.swift      # Carbon RegisterEventHotKey wrapper
│   └── Config.swift            # UserDefaults wrapper
├── Resources/{Info.plist, AppIcon.icns}
└── Makefile                    # swift build → .app bundling
```

`LSUIElement = true` in Info.plist — no Dock icon, no app menu, pure menu-bar utility.

The earlier Rust/Tauri prototype lives at [op599/tuntun-rust](https://github.com/op599/tuntun-rust) (archived). Swift is the right tool for a single-platform menu-bar app: tighter AppKit integration, no FFI bridge, ~6× smaller binary, ~10× faster startup.

## Roadmap

- [x] **v0.1** — single NSStatusItem, autosaveName, right-click settings, global hotkey
- [ ] **v0.2** — Launch at Login (SMAppService)
- [ ] **v0.3** — multi-screen support (separate stash state per screen)
- [ ] **v0.4** — visual alignment guides while dragging

## Credits

Approach informed by [HiddenBar](https://github.com/dwarvesf/hidden), [Ice](https://github.com/jordanbaird/Ice), [Dozer](https://github.com/Mortennn/Dozer) — all Swift.

## License

MIT
