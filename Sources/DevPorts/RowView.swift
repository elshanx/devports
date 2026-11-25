import SwiftUI

struct RowView: View {
    let listener: Listener
    let stopping: Bool
    let selected: Bool
    let onStop: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            if listener.kind != .other { KindTile(kind: listener.kind) }
            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(listener.name)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                        .help(listener.name + "\n" + listener.command)
                    if let folder = listener.folder, folder != "/", folder != Project.home {
                        Button(abbreviated(folder)) { NSWorkspace.shared.open(URL(fileURLWithPath: folder)) }
                            .buttonStyle(.plain)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .help("Show in Finder")
                    }
                }
                PortChips(ports: listener.mainPorts, internalPorts: listener.internalPorts, tint: listener.kind.tint)
            }
            Spacer(minLength: 0)
            stopButton
        }
        .padding(10)
        .background(selected ? Color.accentColor.opacity(0.18) : Color.primary.opacity(0.05),
                    in: RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    @ViewBuilder
    private var stopButton: some View {
        if stopping {
            ProgressView().controlSize(.small).frame(width: 24, height: 24)
        } else if !Project.isProtected(command: listener.command) || listener.container != nil {
            TintedButton(symbol: "stop.fill", tint: .red, help: "Stop \(listener.name) (⌘⌫ when selected)",
                         action: onStop)
        } else {
            Image(systemName: "lock.fill")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .frame(width: 24, height: 24)
                .help("System process. DevPorts does not stop it.")
                .accessibilityLabel("System process. DevPorts does not stop it.")
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
            .accessibilityLabel(kind.title)
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
        case .other: .secondary
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
