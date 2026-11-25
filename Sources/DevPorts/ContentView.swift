import SwiftUI

struct ContentView: View {
    static let didOpen = Notification.Name("DevPortsPopoverDidOpen")

    let store: Store
    let loginItem: LoginItem
    let close: () -> Void
    @State private var selection: String?
    @FocusState private var listFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header.padding(.horizontal, 14).padding(.vertical, 10)
            Divider()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if store.ordered.isEmpty && store.randomRows.isEmpty {
                            emptyState
                        } else {
                            ListenerList(store: store, selection: $selection) { listFocused = true }
                        }
                        if !store.recentlyStopped.isEmpty {
                            RecentlyStoppedView(store: store)
                        }
                    }
                    .padding(12)
                }
                .onChange(of: selection) { _, id in withAnimation { proxy.scrollTo(id) } }
            }
            .frame(maxHeight: 460)
            .fixedSize(horizontal: false, vertical: true)
            if let message = store.message {
                ErrorBanner(message: message, retryTitle: "Try again", retry: store.retryFailedStops,
                            dismiss: store.dismissMessage)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
            } else if let error = loginItem.error {
                ErrorBanner(message: error, retryTitle: "Open Settings", retry: loginItem.openSettings,
                            dismiss: loginItem.dismissError)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
            }
            Divider()
            FooterView(store: store, loginItem: loginItem).padding(.horizontal, 14).padding(.vertical, 10)
        }
        .frame(width: 400)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(nsColor: .windowBackgroundColor))
        .focusable()
        .focused($listFocused)
        .focusEffectDisabled()
        .onKeyPress(.downArrow) { moveSelection(by: 1) }
        .onKeyPress(.upArrow) { moveSelection(by: -1) }
        .onKeyPress(.return) { act { $0.openInBrowser() } }
        .onKeyPress(.delete, phases: .down) { press in
            press.modifiers.contains(.command) ? act { store.stop($0) } : .ignored
        }
        .onKeyPress(.escape) {
            close()
            return .handled
        }
        .onReceive(NotificationCenter.default.publisher(for: Self.didOpen)) { _ in
            selection = nil
            listFocused = true
        }
    }

    private func moveSelection(by step: Int) -> KeyPress.Result {
        let ids = store.ordered.map(\.id)
        guard !ids.isEmpty else { return .ignored }
        let current = selection.flatMap { ids.firstIndex(of: $0) } ?? (step > 0 ? -1 : ids.count)
        selection = ids[min(max(current + step, 0), ids.count - 1)]
        return .handled
    }

    private func act(_ action: (Listener) -> Void) -> KeyPress.Result {
        guard let listener = store.ordered.first(where: { $0.id == selection }) else { return .ignored }
        action(listener)
        return .handled
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("DevPorts").font(.system(size: 13, weight: .bold))
            Spacer()
            Text(summary).font(.caption).foregroundStyle(.secondary)
        }
    }

    private var summary: String {
        switch store.devServers.count {
        case 0: "No dev servers running"
        case 1: "1 dev server running"
        case let count: "\(count) dev servers running"
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "moon.zzz.fill").font(.system(size: 22)).foregroundStyle(.tertiary)
            Text(store.showAll ? "No ports in use" : "Dev servers you start show here")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
    }
}
