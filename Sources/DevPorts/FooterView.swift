import SwiftUI

struct FooterView: View {
    let store: Store
    let loginItem: LoginItem

    var body: some View {
        HStack(spacing: 8) {
            TintedButton(title: store.showAll ? "Show dev servers" : "Show all ports",
                         symbol: store.showAll ? "hammer" : "list.bullet", tint: .accentColor, quiet: true,
                         help: "Switch between dev servers and every port") { store.showAll.toggle() }
            if !store.devServers.isEmpty {
                StopAllButton(count: store.devServers.count) { store.stopAllDevServers() }
            }
            Spacer()
            MoreMenu(store: store, loginItem: loginItem)
        }
    }
}

private struct MoreMenu: View {
    let store: Store
    let loginItem: LoginItem

    var body: some View {
        Menu {
            Button("Refresh") { store.refresh() }.keyboardShortcut("r")
            Button("Open Restart Logs") {
                let logs = URL(fileURLWithPath: Project.home).appendingPathComponent("Library/Logs/DevPorts")
                try? FileManager.default.createDirectory(at: logs, withIntermediateDirectories: true)
                NSWorkspace.shared.open(logs)
            }
            Toggle("Open at Login", isOn: Binding(get: { loginItem.isEnabled }, set: { _ in loginItem.toggle() }))
            Section("Keyboard") {
                Text(HotKey.title + "  Open DevPorts from any app")
                Text("↑ ↓  Select a server")
                Text("↩ or double-click  Open in browser")
                Text("⌘⌫  Stop selected server")
                Text("Type  Filter by name, folder or port")
                Text("Esc  Clear the filter or close")
            }
            Divider()
            Button("Quit DevPorts") { NSApplication.shared.terminate(nil) }.keyboardShortcut("q")
        } label: {
            Image(systemName: "ellipsis")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .frame(width: 24, height: 24)
        .help("More")
        .accessibilityLabel("More")
    }
}
