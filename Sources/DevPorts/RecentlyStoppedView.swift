import SwiftUI

struct RecentlyStoppedView: View {
    let store: Store

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionTitle(text: "Recently stopped")
            ForEach(store.recentlyStopped) { server in
                StoppedRow(server: server, store: store)
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

private struct StoppedRow: View {
    let server: StoppedServer
    let store: Store

    var body: some View {
        HStack(spacing: 8) {
            statusIcon.frame(width: 16)
            VStack(alignment: .leading, spacing: 1) {
                Text(server.name).font(.system(size: 12, weight: .medium)).lineLimit(1)
                Text(detail)
                    .font(.system(size: 10, design: server.state == .stopped ? .monospaced : .default))
                    .foregroundStyle(detailColor)
                    .lineLimit(1)
                    .help(detail)
            }
            Spacer(minLength: 0)
            actions
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
        .animation(.easeOut(duration: 0.2), value: server.state)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch server.state {
        case .stopped: Image(systemName: "pause.circle.fill").foregroundStyle(.orange)
        case .starting: ProgressView().controlSize(.small)
        case .running: Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case .failed: Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
        }
    }

    private var detail: String {
        switch server.state {
        case .stopped: server.ports.map { ":" + String($0) }.joined(separator: " ")
        case .starting: "Starting…"
        case .running(let port): port.map { "Running on :" + String($0) } ?? "Running"
        case .failed(let reason): "Did not start. " + reason
        }
    }

    private var detailColor: Color {
        switch server.state {
        case .running: .green
        case .failed: .red
        default: .secondary
        }
    }

    private var tint: Color {
        switch server.state {
        case .stopped: .orange
        case .starting: .gray
        case .running: .green
        case .failed: .red
        }
    }

    @ViewBuilder
    private var actions: some View {
        switch server.state {
        case .stopped:
            restartButton
            forgetButton
        case .failed:
            TintedButton(title: "Open log", symbol: "doc.text", tint: .blue, help: "Open \(server.log.lastPathComponent)") {
                NSWorkspace.shared.open(server.log)
            }
            restartButton
            forgetButton
        case .starting, .running:
            EmptyView()
        }
    }

    private var restartButton: some View {
        TintedButton(title: server.state == .stopped ? "Restart" : "Retry", symbol: "arrow.counterclockwise",
                     tint: .green, help: "Run in \(server.spec.folder):\n\(server.spec.commandLine)") {
            store.restart(server)
        }
    }

    private var forgetButton: some View {
        TintedButton(symbol: "xmark", tint: .gray, help: "Remove \(server.name) from this list") { store.forget(server) }
    }
}
