import SwiftUI

struct ErrorBanner: View {
    let message: String
    let actionTitle: String?
    let action: () -> Void
    let dismiss: () -> Void
    var actionHelp: String?
    var symbol = "doc.on.doc"
    var doneTitle: String? = "Copied"
    @State private var done = false

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
            Text(message)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            if let actionTitle {
                let showsDone = done && doneTitle != nil
                TintedButton(title: showsDone ? doneTitle : actionTitle, symbol: showsDone ? "checkmark" : symbol,
                             tint: .red, help: actionHelp ?? actionTitle) {
                    action()
                    done = true
                }
            }
            TintedButton(symbol: "xmark", tint: .gray, help: "Dismiss this message", action: dismiss)
        }
        .padding(8)
        .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .contain)
        .onChange(of: message) { done = false }
    }
}
