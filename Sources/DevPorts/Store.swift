import Foundation
import Observation

@MainActor
@Observable
final class Store {
    var listeners: [Listener] = []
    var recentlyStopped: [StoppedServer] = []
    var showAll = false
    var showRandomPorts = false
    var stopping = Set<String>()
    var message: String?
    private var timer: Timer?

    var query = ""

    var ordered: [Listener] {
        [Listener.Kind.dev, .docker, .other].flatMap(group) + (showRandomPorts ? randomRows : [])
    }
    var randomRows: [Listener] { showAll ? shown.filter(\.onRandomPortsOnly) : [] }
    private var shown: [Listener] { (showAll ? listeners : devServers).filter { $0.matches(query) } }

    func group(_ kind: Listener.Kind) -> [Listener] {
        shown.filter { $0.kind == kind && !$0.onRandomPortsOnly }
    }
    var devServers: [Listener] { listeners.filter { $0.kind == .dev } }

    init() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func refresh() {
        Task {
            let result = await Task.detached { Scanner.scan() }.value
            listeners = result
            trackRestarts()
        }
    }

    func stop(_ listener: Listener) {
        stopAll([listener])
    }

    func stopAllDevServers() {
        stopAll(devServers)
    }

    func restart(_ server: StoppedServer) {
        do {
            _ = try server.spec.launch(logTo: server.log)
            setState(.starting(since: Date()), for: server.id)
        } catch {
            setState(.failed(reason: error.localizedDescription), for: server.id)
        }
        Task {
            while recentlyStopped.contains(where: { $0.id == server.id && $0.isStarting }) {
                try? await Task.sleep(for: .seconds(1))
                refresh()
            }
        }
    }

    func forget(_ server: StoppedServer) {
        recentlyStopped.removeAll { $0.id == server.id }
    }

    private func trackRestarts() {
        for server in recentlyStopped {
            guard case .starting(let since) = server.state else { continue }
            if let listener = server.runningListener(in: listeners) {
                setState(.running(port: listener.mainPorts.first), for: server.id)
                Task {
                    try? await Task.sleep(for: .seconds(4))
                    forget(server)
                }
            } else if Date().timeIntervalSince(since) > StoppedServer.startTimeout {
                setState(.failed(reason: "No port opened in \(Int(StoppedServer.startTimeout)) seconds"), for: server.id)
            }
        }
    }

    private func setState(_ state: StoppedServer.State, for id: UUID) {
        guard let index = recentlyStopped.firstIndex(where: { $0.id == id }) else { return }
        recentlyStopped[index].state = state
    }

    private func stopAll(_ targets: [Listener]) {
        stopping.formUnion(targets.map(\.id))
        Task {
            var errors: [String] = []
            await withTaskGroup(of: (Listener, StopResult).self) { group in
                for target in targets { group.addTask { (target, await Killer.stop(target)) } }
                for await (target, result) in group {
                    if let error = result.error { errors.append(error) }
                    if let spec = result.restart { remember(target, spec) }
                }
            }
            stopping.subtract(targets.map(\.id))
            message = errors.isEmpty ? nil : errors.joined(separator: "\n")
            refresh()
        }
    }

    private func remember(_ listener: Listener, _ spec: LaunchSpec) {
        recentlyStopped.removeAll { $0.spec == spec }
        recentlyStopped.insert(StoppedServer(name: listener.name, kind: listener.kind, ports: listener.mainPorts, spec: spec), at: 0)
        recentlyStopped = Array(recentlyStopped.prefix(5))
    }
}
