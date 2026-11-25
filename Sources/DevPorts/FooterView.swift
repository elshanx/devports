import SwiftUI

struct FooterView: View {
    let store: Store
    let loginItem: LoginItem

    var body: some View {
        HStack(spacing: 8) {
            TintedButton(title: store.showAll ? "Show dev ports" : "Show all ports",
                         symbol: store.showAll ? "hammer" : "list.bullet", tint: .accentColor,
                         help: "Switch between dev servers and every port") { store.showAll.toggle() }
            if !store.devServers.isEmpty {
                StopAllButton(count: store.devServers.count) { store.stopAllDevServers() }
            }
            Spacer()
            TintedButton(symbol: "doc.text", tint: .blue, help: "Open restart logs") {
                let logs = URL(fileURLWithPath: Project.home).appendingPathComponent("Library/Logs/DevPorts")
                try? FileManager.default.createDirectory(at: logs, withIntermediateDirectories: true)
                NSWorkspace.shared.open(logs)
            }
            TintedButton(symbol: "arrow.clockwise", tint: .green, help: "Refresh (⌘R)") { store.refresh() }
                .keyboardShortcut("r")
            TintedButton(symbol: loginItem.isEnabled ? "sunrise.fill" : "sunrise",
                         tint: loginItem.isEnabled ? .purple : .gray,
                         help: loginItem.isEnabled ? "Open at login: on (click to turn off)"
                             : "Open at login: off (click to turn on)") {
                loginItem.toggle()
            }
            TintedButton(symbol: "power", tint: .orange, help: "Quit DevPorts (⌘Q)") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
