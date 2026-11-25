import SwiftUI

struct PortChips: View {
    let ports: [Int]
    let internalPorts: [Int]
    let tint: Color

    var body: some View {
        FlowLayout(spacing: 4) {
            ForEach(ports, id: \.self) { port in
                PortChip(port: port, tint: tint)
            }
            if !internalPorts.isEmpty {
                Text("+\(internalPorts.count) internal")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 3)
                    .help("Internal ports (debugger or random ports from the tool): "
                        + internalPorts.map { ":" + String($0) }.joined(separator: " "))
            }
        }
    }
}

private struct PortChip: View {
    let port: Int
    let tint: Color
    @State private var hovering = false

    var body: some View {
        Button { Localhost.open(port) } label: {
            Text(":" + String(port))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .foregroundStyle(tint)
                .background(tint.opacity(hovering ? 0.25 : 0.12), in: Capsule())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help("Open " + Localhost.url(port))
        .accessibilityLabel("Open port " + String(port))
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(subviews, width: proposal.width ?? .infinity)
        return CGSize(width: rows.map(\.width).max() ?? 0, height: rows.last.map { $0.y + $0.height } ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for row in arrange(subviews, width: bounds.width) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: bounds.minY + row.y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
        var y: CGFloat = 0
    }

    private func arrange(_ subviews: Subviews, width: CGFloat) -> [Row] {
        var rows = [Row()]
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let extra = rows[rows.count - 1].indices.isEmpty ? size.width : rows[rows.count - 1].width + spacing + size.width
            if extra > width, !rows[rows.count - 1].indices.isEmpty {
                let last = rows[rows.count - 1]
                rows.append(Row(y: last.y + last.height + spacing))
            }
            let current = rows.count - 1
            rows[current].width += (rows[current].indices.isEmpty ? 0 : spacing) + size.width
            rows[current].height = max(rows[current].height, size.height)
            rows[current].indices.append(index)
        }
        return rows
    }
}

enum Localhost {
    static func url(_ port: Int) -> String { "http://localhost:" + String(port) }

    static func open(_ port: Int) {
        NSWorkspace.shared.open(URL(string: url(port))!)
    }
}
