import Foundation
import Observation

struct StoppedServer: Identifiable {
    let id = UUID()
    let name: String
    let ports: [Int]
    let spec: LaunchSpec

    var log: URL {
        URL(fileURLWithPath: Project.home).appendingPathComponent("Library/Logs/DevPorts/\(name).log")
    }
}

@MainActor
@Observable
final class Store {
    var listeners: [Listener] = []
    var recentlyStopped: [StoppedServer] = []
    var showAll = false
    var stopping = Set<String>()
    var message: String?
    private var timer: Timer?

    var visible: [Listener] { showAll ? listeners : devServers }
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
        }
    }

    func stop(_ listener: Listener) {
        stopAll([listener])
    }

    func stopAllDevServers() {
        stopAll(devServers)
    }

    func restart(_ server: StoppedServer) {
        recentlyStopped.removeAll { $0.id == server.id }
        do {
            _ = try server.spec.launch(logTo: server.log)
            message = nil
        } catch {
            message = "Could not restart \(server.name): \(error.localizedDescription)"
        }
        refresh()
    }

    func forget(_ server: StoppedServer) {
        recentlyStopped.removeAll { $0.id == server.id }
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
        recentlyStopped.insert(StoppedServer(name: listener.name, ports: listener.mainPorts, spec: spec), at: 0)
        recentlyStopped = Array(recentlyStopped.prefix(5))
    }
}
