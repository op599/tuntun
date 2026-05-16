import SwiftUI

struct SettingsView: View {
    let controller: AppDelegate

    @State private var collapsed: Bool = false
    @State private var rightDist: CGFloat = -1
    @State private var timer: Timer?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                hero
                if rightDist > 150 {
                    notVisibleHint
                }
                statusCard
                preferencesCard
                aboutCard
            }
            .padding(28)
        }
        .frame(width: 480, height: 540)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            refresh()
            timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                Task { @MainActor in refresh() }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    // MARK: - sections

    private var hero: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(colors: [Color(red: 0.96, green: 0.66, blue: 0.43),
                                                  Color(red: 0.92, green: 0.40, blue: 0.30)],
                                         startPoint: .top, endPoint: .bottom))
                Text("囤")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text("囤囤").font(.title2).bold()
                Text("把 macOS 菜单栏图标囤起来，按需取用。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.bottom, 6)
    }

    private var notVisibleHint: some View {
        card(tint: .orange.opacity(0.15), borderTint: .orange.opacity(0.4)) {
            VStack(alignment: .leading, spacing: 6) {
                Text("把按钮拖到菜单栏最右").font(.headline).foregroundColor(.orange)
                Text("按住 ⌘ 把菜单栏里的 \(collapsed ? "▾" : "▸") 按钮拖到最右边 (紧挨 Wi-Fi/电池/时钟左侧)，macOS 会记住位置。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("当前距右边缘 ≈ \(Int(rightDist)) pt，目标 ≤ 150 pt。")
                    .font(.caption.monospaced())
                    .foregroundColor(.secondary)
            }
        }
    }

    private var statusCard: some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("当前状态")
                Text("囤囤在菜单栏放 1 个 \(collapsed ? "▾" : "▸") 按钮。左键 = 囤进去/吐出来，右键 (或 ⌃+点击) = 打开本窗。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack {
                    Text(collapsed ? "已囤起 · 图标藏在腮帮子里" : "已吐出 · 图标可见")
                        .font(.callout)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(collapsed ? Color.accentColor.opacity(0.15) : Color.green.opacity(0.18))
                        .foregroundColor(collapsed ? Color.accentColor : .green)
                        .clipShape(Capsule())
                    Spacer()
                    Button(collapsed ? "吐出来" : "囤进去") {
                        controller.toggleCollapsed()
                        refresh()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }

    private var preferencesCard: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("偏好")
                row(label: "全局快捷键",
                    hint: "在任意 app 里按 = 囤进去/吐出来") {
                    Text("⌃⌥H").font(.callout.monospaced())
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.secondary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                Divider()
                row(label: "右键 ▸ 按钮",
                    hint: "在菜单栏右键 ▸ 即可打开这个窗口") {
                    Text("已启用").foregroundColor(.secondary).font(.caption)
                }
            }
        }
    }

    private var aboutCard: some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("关于")
                Text("囤囤采用 HiddenBar / Ice / Dozer 风格的 NSStatusItem 方案，不使用 macOS 私有 API，对系统无修改。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("囤囤 v0.1.0 · macOS · Swift + SwiftUI")
                    .font(.caption2.monospaced())
                    .foregroundColor(Color.secondary.opacity(0.7))
                HStack {
                    Spacer()
                    Button("退出囤囤") { controller.quit() }
                        .foregroundColor(.red)
                }
            }
        }
    }

    // MARK: - helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption2.bold())
            .tracking(0.8)
            .foregroundColor(Color.secondary.opacity(0.7))
    }

    private func row<Content: View>(label: String, hint: String,
                                    @ViewBuilder trailing: () -> Content) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.callout)
                Text(hint).font(.caption2).foregroundColor(.secondary)
            }
            Spacer()
            trailing()
        }
    }

    private func card<Content: View>(tint: Color? = nil,
                                     borderTint: Color? = nil,
                                     @ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint ?? Color(NSColor.controlBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderTint ?? Color.secondary.opacity(0.15), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func refresh() {
        collapsed = controller.currentCollapsed()
        rightDist = controller.distanceFromRightEdge()
    }
}
