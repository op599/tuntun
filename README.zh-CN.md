# 囤囤 (Tuntun)

[English](./README.md) · 简体中文

> 把 macOS 菜单栏图标囤起来。纯 Swift + SwiftUI 重写, ~700 KB 二进制。

姊妹项目: 剪切板管理器 [贴贴 (tietie)](https://github.com/op599/tietie)。

## 是什么

带刘海的 MacBook Pro 菜单栏空间紧张, 第三方 app 的图标常常被挤到看不见。

囤囤在菜单栏加 **一个** `NSStatusItem`, 显示小按钮 `▸`。

```
[ 其它 app 图标 ... ]  ▸   Wi-Fi  电池  时钟
```

- **左键** `▸` — 囤进去 (item 长度撑到 10000pt, 把它左边的图标挤出屏幕; `▾` 字符靠 `NSTextAlignment.right` 锁在 slot 右沿)
- **左键** `▾` — 吐出来 (长度回 28pt, 图标回来)
- **右键** (或 `⌃`+点击) `▸` — 打开设置窗
- **`⌃⌥H`** — 任何 app 里全局快捷键 toggle

不使用 macOS 私有 API, 不需要辅助功能权限, 对系统零修改。
status item 用了 `autosaveName`, 你 `⌘`+拖到的位置 (比如紧贴 Wi-Fi 左侧) macOS 会永久记住。

## 下载

[Releases](https://github.com/op599/tuntun/releases) — universal binary (Apple Silicon + Intel)。

| 格式 | 说明 |
|---|---|
| `Tuntun_x.y.z.dmg` | 拖进 Applications |
| `Tuntun_x.y.z.app.tar.gz` | 给脚本化安装用 |

macOS 12 (Monterey) 及以上。应用未签名, 首次启动需 *系统设置 → 隐私与安全 → 仍要打开*。

## 本地开发

```bash
make build          # swift build -c release
make bundle         # 出 universal .app
make install        # → /Applications/Tuntun.app
make dmg            # 出 DMG
```

需要 Xcode 命令行工具 (`swift` 5.9+)。

## 架构

```
tuntun/
├── Package.swift
├── Sources/Tuntun/
│   ├── main.swift              # NSApplication 入口
│   ├── AppDelegate.swift       # 窗口/热键生命周期
│   ├── StatusBarController.swift  # 1 个 NSStatusItem, 全部演出
│   ├── SettingsView.swift      # SwiftUI 设置窗
│   ├── GlobalHotkey.swift      # Carbon RegisterEventHotKey 包装
│   └── Config.swift            # UserDefaults 包装
├── Resources/{Info.plist, AppIcon.icns}
└── Makefile                    # swift build → .app bundle
```

Info.plist 设了 `LSUIElement = true` — 无 Dock 图标, 无 app 菜单, 纯菜单栏小工具。

之前的 Rust/Tauri 原型在 [op599/tuntun-rust](https://github.com/op599/tuntun-rust) (已归档)。这种单平台菜单栏小工具 Swift 是正路: AppKit 集成更紧, 无 FFI 桥接, 二进制小 ~6 倍, 启动快 ~10 倍。

## 路线图

- [x] **v0.1** — 单 NSStatusItem, autosaveName, 右键设置, 全局快捷键
- [ ] **v0.2** — 开机自启 (SMAppService)
- [ ] **v0.3** — 多屏支持 (每屏独立的折叠状态)
- [ ] **v0.4** — 拖拽时的视觉对齐辅助线

## 致谢

技术方案参考 [HiddenBar](https://github.com/dwarvesf/hidden), [Ice](https://github.com/jordanbaird/Ice), [Dozer](https://github.com/Mortennn/Dozer) — 都是 Swift。

## License

MIT
