import Foundation

struct StoppedServer: Identifiable {
    enum State: Equatable {
        case stopped
        case starting(since: Date)
        case running(port: Int?)
        case failed(reason: String)
    }

    static let startTimeout: TimeInterval = 30

    let id = UUID()
    let name: String
    let kind: Listener.Kind
    let ports: [Int]
    let spec: LaunchSpec
    var state = State.stopped

    var log: URL {
        URL(fileURLWithPath: Project.home).appendingPathComponent("Library/Logs/DevPorts/\(name).log")
    }

    var isStarting: Bool {
        if case .starting = state { return true }
        return false
    }

    func runningListener(in listeners: [Listener]) -> Listener? {
        listeners.first { listener in
            listener.kind == kind && listener.name == name
                && (!Set(listener.mainPorts).isDisjoint(with: ports) || listener.folder == spec.folder)
        }
    }
}
