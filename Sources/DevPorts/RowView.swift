import SwiftUI

struct RowView: View {
    let listener: Listener
    let stopping: Bool
    let onStop: () -> Void
    @State private var hovering = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            KindTile(kind: listener.kind)
            VStack(alignment: .leading, spacing: 4) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(listener.name).font(.system(size: 13, weight: .semibold)).lineLimit(1)
                    if let folder = listener.folder {
                        Button(abbreviated(folder)) { NSWorkspace.shared.open(URL(fileURLWithPath: folder)) }
                            .buttonStyle(.plain)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .help("Show in Finder")
                    }
                }
                Text(listener.command)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                PortChips(ports: listener.mainPorts, internalPorts: listener.internalPorts, tint: listener.kind.tint)
            }
            Spacer(minLength: 0)
            stopButton
        }
        .padding(10)
        .background(.primary.opacity(hovering ? 0.08 : 0.04), in: RoundedRectangle(cornerRadius: 10))
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onHover { hovering = $0 }
        .onTapGesture { listener.mainPorts.first.map(Localhost.open) }
        .help(listener.mainPorts.first.map { "Click to open " + Localhost.url($0) } ?? "")
    }

    @ViewBuilder
    private var stopButton: some View {
        if stopping {
            ProgressView().controlSize(.small).frame(width: 24, height: 24)
        } else if !Project.isProtected(command: listener.command) || listener.container != nil {
            TintedButton(symbol: "stop.fill", tint: .red, help: "Stop \(listener.name)", action: onStop)
        }
    }

    private func abbreviated(_ path: String) -> String {
        path.hasPrefix(Project.home) ? "~" + path.dropFirst(Project.home.count) : path
    }
}

struct KindTile: View {
    let kind: Listener.Kind

    var body: some View {
        Image(systemName: kind.symbol)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(kind.tint)
            .frame(width: 26, height: 26)
            .background(kind.tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 7))
    }
}

extension Listener.Kind {
    var symbol: String {
        switch self {
        case .dev: "hammer.fill"
        case .docker: "shippingbox.fill"
        case .other: "gearshape.fill"
        }
    }

    var tint: Color {
        switch self {
        case .dev: .green
        case .docker: .blue
        case .other: .gray
        }
    }

    var title: String {
        switch self {
        case .dev: "Dev servers"
        case .docker: "Docker"
        case .other: "Other"
        }
    }
}
