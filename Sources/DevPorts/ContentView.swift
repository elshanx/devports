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
                        if store.visible.isEmpty {
                            emptyState
                        } else {
                            sections
                        }
                        if store.showAll, !store.randomPortApps.isEmpty {
                            randomPortsToggle
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
            if let message = store.message ?? loginItem.error {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 14)
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
        .onKeyPress(.return) { act { $0.mainPorts.first.map(Localhost.open) } }
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

    private var ordered: [Listener] {
        [Listener.Kind.dev, .docker, .other].flatMap { kind in store.visible.filter { $0.kind == kind } }
    }

    private func moveSelection(by step: Int) -> KeyPress.Result {
        let ids = ordered.map(\.id)
        guard !ids.isEmpty else { return .ignored }
        let current = selection.flatMap { ids.firstIndex(of: $0) } ?? (step > 0 ? -1 : ids.count)
        selection = ids[min(max(current + step, 0), ids.count - 1)]
        return .handled
    }

    private func act(_ action: (Listener) -> Void) -> KeyPress.Result {
        guard let listener = ordered.first(where: { $0.id == selection }) else { return .ignored }
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

    private var sections: some View {
        ForEach([Listener.Kind.dev, .docker, .other], id: \.self) { kind in
            let listeners = store.visible.filter { $0.kind == kind }
            if !listeners.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    if store.showAll { SectionTitle(text: kind.title) }
                    ForEach(listeners) { listener in
                        RowView(listener: listener, stopping: store.stopping.contains(listener.id),
                                selected: selection == listener.id) {
                            store.stop(listener)
                        }
                        .id(listener.id)
                    }
                }
            }
        }
    }

    private var randomPortsToggle: some View {
        let count = store.randomPortApps.count
        let apps = count == 1 ? "1 app on a random port" : "\(count) apps on random ports"
        return TintedButton(title: (store.showRandomPorts ? "Hide " : "Show ") + apps,
                            symbol: store.showRandomPorts ? "chevron.up" : "chevron.down", tint: .secondary, quiet: true,
                            help: "Apps that listen only on ports above 49152, picked at random by the system") {
            store.showRandomPorts.toggle()
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
