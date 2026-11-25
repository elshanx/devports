import SwiftUI

struct ContentView: View {
    let store: Store
    let loginItem: LoginItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header.padding(14)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if store.visible.isEmpty {
                        emptyState
                    } else {
                        sections
                    }
                    if !store.recentlyStopped.isEmpty {
                        RecentlyStoppedView(store: store)
                    }
                }
                .padding(12)
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
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("DevPorts").font(.system(size: 15, weight: .bold))
                Text(summary).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
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
                        RowView(listener: listener, stopping: store.stopping.contains(listener.id)) {
                            store.stop(listener)
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "moon.zzz.fill").font(.system(size: 22)).foregroundStyle(.tertiary)
            Text(store.showAll ? "No ports in use" : "No dev servers running")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
    }
}
