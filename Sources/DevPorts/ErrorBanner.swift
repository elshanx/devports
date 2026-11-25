import SwiftUI

struct ErrorBanner: View {
    let message: String
    let retryTitle: String?
    let retry: () -> Void
    let dismiss: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
            Text(message)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            if let retryTitle {
                TintedButton(title: retryTitle, symbol: "arrow.clockwise", tint: .red, help: retryTitle, action: retry)
            }
            TintedButton(symbol: "xmark", tint: .gray, help: "Dismiss this message", action: dismiss)
        }
        .padding(8)
        .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .contain)
    }
}
