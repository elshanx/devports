import SwiftUI

struct TintedButton: View {
    var title: String?
    let symbol: String
    let tint: Color
    var filled = false
    var quiet = false
    let help: String
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: symbol).font(.system(size: title == nil ? 11 : 10, weight: .bold))
                if let title { Text(title).font(.system(size: 11, weight: .semibold)) }
            }
            .foregroundStyle(filled || (hovering && title == nil) ? Color.white : tint)
            .frame(width: title == nil ? 24 : nil, height: 24)
            .padding(.horizontal, title == nil ? 0 : 10)
            .background(background, in: RoundedRectangle(cornerRadius: title == nil ? 12 : 7))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help(help)
        .accessibilityLabel(title ?? help)
        .animation(.easeOut(duration: 0.12), value: hovering)
        .animation(.easeOut(duration: 0.12), value: filled)
    }

    private var background: Color {
        if filled { return tint }
        if hovering { return title == nil ? tint : tint.opacity(0.25) }
        return quiet ? .clear : tint.opacity(0.14)
    }
}

struct StopAllButton: View {
    let count: Int
    let action: () -> Void
    @State private var confirming = false

    var body: some View {
        TintedButton(title: confirming ? "Stop \(count == 1 ? "1 server" : "\(count) servers")?" : "Stop all",
                     symbol: "stop.fill", tint: .red, filled: confirming, quiet: true,
                     help: confirming ? "Click again to stop every dev server" : "Stop every dev server") {
            if confirming {
                confirming = false
                action()
            } else {
                confirming = true
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    confirming = false
                }
            }
        }
    }
}
