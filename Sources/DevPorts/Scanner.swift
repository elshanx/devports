import Foundation

struct Listener: Identifiable, Hashable {
    enum Kind { case dev, docker, other }

    let pid: Int32
    let pgid: Int32
    let name: String
    let command: String
    let folder: String?
    let ports: [Int]
    let kind: Kind
    let container: String?

    var id: String { container.map { "docker:\($0)" } ?? "pid:\(pid)" }

    var mainPorts: [Int] {
        let chosen = ports.filter { !Self.isInternal($0) }
        return chosen.isEmpty ? ports : chosen
    }

    var internalPorts: [Int] { ports.filter { !mainPorts.contains($0) } }

    private static func isInternal(_ port: Int) -> Bool {
        port >= 49152 || [9229, 9230].contains(port)
    }
}

enum Scanner {
    private struct RawProcess {
        var name = ""
        var ports = Set<Int>()
    }

    static func scan() -> [Listener] {
        let raw = listeningProcesses()
        guard !raw.isEmpty else { return [] }
        let pids = raw.keys.map(String.init).joined(separator: ",")
        let info = ProcessInfoReader.groupsAndCommands(pids: pids)
        let folders = ProcessInfoReader.workingFolders(pids: pids)
        let containers = DockerReader.containersByPort()

        var result: [Listener] = []
        for (pid, process) in raw {
            let (pgid, command) = info[pid] ?? (0, process.name)
            let dockerPorts = process.ports.filter { containers[$0] != nil }
            for (container, ports) in Dictionary(grouping: dockerPorts, by: { containers[$0]! }) {
                result.append(Listener(pid: pid, pgid: pgid, name: container, command: command, folder: nil,
                                       ports: ports.sorted(), kind: .docker, container: container))
            }
            let ports = process.ports.subtracting(dockerPorts).sorted()
            guard !ports.isEmpty else { continue }
            let folder = folders[pid]
            let project = Project.find(from: folder, command: command)
            result.append(Listener(pid: pid, pgid: pgid, name: project?.name ?? process.name, command: command,
                                   folder: project?.root ?? folder, ports: ports,
                                   kind: project == nil ? .other : .dev, container: nil))
        }
        return mergeDevGroups(result).sorted { ($0.ports.first ?? 0) < ($1.ports.first ?? 0) }
    }

    private static func mergeDevGroups(_ listeners: [Listener]) -> [Listener] {
        let dev = Dictionary(grouping: listeners.filter { $0.kind == .dev }) { "\($0.pgid)|\($0.folder ?? "")" }
        let merged = dev.values.map { group in
            let main = group.min { ($0.ports.first ?? 0) < ($1.ports.first ?? 0) }!
            return Listener(pid: main.pid, pgid: main.pgid, name: main.name, command: main.command,
                            folder: main.folder, ports: group.flatMap(\.ports).sorted(), kind: .dev, container: nil)
        }
        return listeners.filter { $0.kind != .dev } + merged
    }

    static func isListening(pid: Int32) -> Bool {
        !Shell.run("/usr/sbin/lsof", ["-a", "-p", "\(pid)", "-iTCP", "-sTCP:LISTEN", "-t"]).isEmpty
    }

    private static func listeningProcesses() -> [Int32: RawProcess] {
        let output = Shell.run("/usr/sbin/lsof", ["-iTCP", "-sTCP:LISTEN", "-P", "-n", "-F", "pcn"])
        var result: [Int32: RawProcess] = [:]
        var current: Int32?
        for line in output.split(separator: "\n") {
            let value = String(line.dropFirst())
            switch line.first {
            case "p": current = Int32(value)
            case "c": if let pid = current { result[pid, default: RawProcess()].name = value }
            case "n":
                if let pid = current, let port = value.split(separator: ":").last.flatMap({ Int($0) }) {
                    result[pid, default: RawProcess()].ports.insert(port)
                }
            default: break
            }
        }
        return result
    }
}
