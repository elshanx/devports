import SwiftUI

struct ListenerList: View {
    let store: Store
    @Binding var selection: String?
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach([Listener.Kind.dev, .docker, .other], id: \.self) { kind in
                let listeners = store.group(kind)
                let showsToggle = kind == .other && !store.randomRows.isEmpty
                if !listeners.isEmpty || showsToggle {
                    VStack(alignment: .leading, spacing: 6) {
                        if store.showAll { SectionTitle(text: kind.title) }
                        rows(listeners)
                        if showsToggle {
                            randomPortsToggle
                            if store.showRandomPorts { rows(store.randomRows) }
                        }
                    }
                }
            }
        }
    }

    private func rows(_ listeners: [Listener]) -> some View {
        ForEach(listeners) { listener in
            RowView(listener: listener, stopping: store.stopping.contains(listener.id),
                    selected: selection == listener.id) {
                store.stop(listener)
            }
            .id(listener.id)
            .contentShape(Rectangle())
            .onTapGesture(count: 2) { listener.openInBrowser() }
            .simultaneousGesture(TapGesture().onEnded {
                selection = listener.id
                onSelect()
            })
        }
    }

    private var randomPortsToggle: some View {
        let count = store.randomRows.count
        let apps = count == 1 ? "1 app on a random port" : "\(count) apps on random ports"
        return TintedButton(title: (store.showRandomPorts ? "Hide " : "Show ") + apps,
                            symbol: store.showRandomPorts ? "chevron.up" : "chevron.down", tint: .secondary, quiet: true,
                            help: "Apps that listen only on ports above 49152, picked at random by the system") {
            store.showRandomPorts.toggle()
        }
    }
}
