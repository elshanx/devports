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
                ErrorBanner(message: message, actionTitle: store.adminCommand.map { _ in "Copy command" },
                            action: copyAdminCommand, dismiss: store.dismissMessage,
                            actionHelp: store.adminCommand.map { "Copies \u{201C}\($0)\u{201D}. Paste it in Terminal." })
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
            } else if let error = loginItem.error {
                ErrorBanner(message: error, actionTitle: "Open Settings", action: loginItem.openSettings,
                            dismiss: loginItem.dismissError, symbol: "gear", doneTitle: nil)
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
            if press.modifiers.contains(.command) { return act { store.stop($0) } }
            guard !store.query.isEmpty else { return .ignored }
            filter(String(store.query.dropLast()))
            return .handled
        }
        .onKeyPress(characters: Self.filterCharacters, phases: .down) { press in
            guard press.modifiers.subtracting(.shift).isEmpty else { return .ignored }
            filter(store.query + press.characters)
            return .handled
        }
        .onKeyPress(.escape) {
            if store.query.isEmpty { close() } else { filter("") }
            return .handled
        }
        .onReceive(NotificationCenter.default.publisher(for: Self.didOpen)) { _ in
            selection = nil
            store.query = ""
            listFocused = true
        }
    }

    private static let filterCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_."))

    private func filter(_ query: String) {
        store.query = query
        selection = query.isEmpty ? nil : store.ordered.first?.id
    }

    private func copyAdminCommand() {
        guard let command = store.adminCommand else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(command, forType: .string)
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
            if store.query.isEmpty && store.showAll {
                Label("Type to filter", systemImage: "magnifyingglass")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if store.query.isEmpty {
                Text(summary).font(.caption).foregroundStyle(.secondary)
            } else {
                Label(store.query, systemImage: "magnifyingglass")
                    .font(.caption.monospaced())
                    .foregroundStyle(Color.accentColor)
                    .accessibilityLabel("Filter: " + store.query)
                    .help("Filter. Press Esc to clear.")
            }
        }
    }

    private var summary: String {
        switch store.devServers.count {
        case 0: "No dev servers running"
        case 1: "1 dev server running"
        case let count: "\(count) dev servers running"
        }
    }

    private var emptyText: String {
        if !store.query.isEmpty { return "Nothing matches \u{201C}" + store.query + "\u{201D}" }
        return store.showAll ? "No ports in use" : "Dev servers you start show here"
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "moon.zzz.fill").font(.system(size: 22)).foregroundStyle(.tertiary)
            Text(emptyText)
                .font(.callout)
                .foregroundStyle(.secondary)
            if store.query.isEmpty && !store.showAll {
                Text("A dev server listens on a port and runs in a folder with "
                    + Project.markers.dropLast().joined(separator: ", ") + " or " + Project.markers.last! + ".")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
    }
}
