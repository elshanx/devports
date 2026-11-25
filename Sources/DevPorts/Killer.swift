import Foundation

struct StopResult {
    var error: String?
    var restart: LaunchSpec?
    var needsAdmin = false
}

enum Killer {
    static func stop(_ listener: Listener) async -> StopResult {
        if let container = listener.container {
            guard let docker = DockerReader.path else { return StopResult(error: "Could not stop \(listener.name). The docker command is not installed.") }
            Shell.run(docker, ["stop", container], timeout: 30)
            return StopResult(restart: LaunchSpec(executable: docker, arguments: ["docker", "start", container],
                                                  folder: Project.home))
        }
        guard !Project.isProtected(command: listener.command) else {
            return StopResult(error: "\(listener.name) is protected")
        }
        guard Scanner.isListening(pid: listener.pid) else { return StopResult() }
        let killsGroup = canKillGroup(listener)
        let target = killsGroup ? -listener.pgid : listener.pid
        let restart = restartSpec(leader: killsGroup ? listener.pgid : listener.pid, fallbackFolder: listener.folder)
        if kill(target, SIGTERM) != 0 {
            guard errno == EPERM else { return StopResult() }
            return StopResult(error: "Could not stop \(listener.name). It needs administrator rights.", needsAdmin: true)
        }
        for _ in 0..<30 {
            try? await Task.sleep(for: .milliseconds(100))
            if kill(target, 0) != 0 { return StopResult(restart: restart) }
        }
        kill(target, SIGKILL)
        return StopResult(restart: restart)
    }

    private static func restartSpec(leader: Int32, fallbackFolder: String?) -> LaunchSpec? {
        guard let folder = ProcessInfoReader.workingFolders(pids: String(leader))[leader] ?? fallbackFolder else {
            return nil
        }
        return LaunchSpec.capture(pid: leader, folder: folder)
    }

    private static func canKillGroup(_ listener: Listener) -> Bool {
        let pgid = listener.pgid
        let session = getsid(listener.pid)
        guard pgid > 1, pgid != getpgrp(), session > 0, pgid != session else { return false }
        return !ProcessInfoReader.groupCommands(pgid: pgid).contains(where: Project.isProtected)
    }
}
