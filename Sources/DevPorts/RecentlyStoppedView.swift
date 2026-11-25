import SwiftUI

struct RecentlyStoppedView: View {
    let store: Store

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionTitle(text: "Recently stopped")
            ForEach(store.recentlyStopped) { server in
                HStack(spacing: 8) {
                    Image(systemName: "pause.circle.fill").foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(server.name).font(.system(size: 12, weight: .medium)).lineLimit(1)
                        Text(server.ports.map { ":" + String($0) }.joined(separator: " "))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    TintedButton(title: "Restart", symbol: "arrow.counterclockwise", tint: .green,
                                 help: "Run in \(server.spec.folder):\n\(server.spec.commandLine)") {
                        store.restart(server)
                    }
                    TintedButton(symbol: "xmark", tint: .gray, help: "Forget") { store.forget(server) }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

struct SectionTitle: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.leading, 2)
    }
}
