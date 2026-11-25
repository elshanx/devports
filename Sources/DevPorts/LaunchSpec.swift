import Darwin
import Foundation

struct LaunchSpec: Hashable {
    let executable: String
    let arguments: [String]
    let folder: String

    static func capture(pid: Int32, folder: String) -> LaunchSpec? {
        var mib: [Int32] = [CTL_KERN, KERN_PROCARGS2, pid]
        var size = 0
        guard sysctl(&mib, 3, nil, &size, nil, 0) == 0, size > MemoryLayout<Int32>.size else { return nil }
        var buffer = [UInt8](repeating: 0, count: size)
        guard sysctl(&mib, 3, &buffer, &size, nil, 0) == 0 else { return nil }

        let argc = buffer.withUnsafeBytes { Int($0.load(as: Int32.self)) }
        var index = MemoryLayout<Int32>.size
        func nextString() -> String? {
            guard index < size, let end = buffer[index..<size].firstIndex(of: 0) else { return nil }
            defer { index = end + 1 }
            return String(decoding: buffer[index..<end], as: UTF8.self)
        }
        guard let executable = nextString() else { return nil }
        while index < size, buffer[index] == 0 { index += 1 }
        let arguments = (0..<argc).compactMap { _ in nextString() }
        guard arguments.count == argc else { return nil }
        return LaunchSpec(executable: executable, arguments: arguments, folder: folder)
    }

    func launch(logTo log: URL) throws -> Int32 {
        try FileManager.default.createDirectory(at: log.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(logHeader.utf8).write(to: log)
        var attributes: posix_spawnattr_t?
        var actions: posix_spawn_file_actions_t?
        posix_spawnattr_init(&attributes)
        posix_spawn_file_actions_init(&actions)
        defer {
            posix_spawnattr_destroy(&attributes)
            posix_spawn_file_actions_destroy(&actions)
        }
        posix_spawnattr_setflags(&attributes, Int16(POSIX_SPAWN_SETPGROUP))
        posix_spawnattr_setpgroup(&attributes, 0)
        posix_spawn_file_actions_addchdir_np(&actions, folder)
        posix_spawn_file_actions_addopen(&actions, 0, "/dev/null", O_RDONLY, 0)
        posix_spawn_file_actions_addopen(&actions, 1, log.path, O_WRONLY | O_APPEND, 0o644)
        posix_spawn_file_actions_adddup2(&actions, 1, 2)

        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        let shellArguments = [shell, "-lic", #"exec -a "$1" "$0" "${@[2,-1]}""#, executable] + arguments
        let argv = shellArguments.map { strdup($0) } + [nil]
        let envp = ProcessInfo.processInfo.environment.map { strdup("\($0.key)=\($0.value)") } + [nil]
        defer { (argv + envp).forEach { free($0) } }
        var pid: pid_t = 0
        let status = posix_spawn(&pid, shell, &actions, &attributes, argv, envp)
        guard status == 0 else { throw POSIXError(POSIXErrorCode(rawValue: status) ?? .EPERM) }
        return pid
    }

    var commandLine: String {
        arguments.map(Self.quoted).joined(separator: " ")
    }

    private var logHeader: String {
        """
        DevPorts restart \(Date().formatted(date: .abbreviated, time: .standard))
        Folder:  \(folder)
        Command: \(commandLine)
        \(String(repeating: "-", count: 60))

        """
    }

    private static func quoted(_ argument: String) -> String {
        guard argument.contains(where: { $0 == " " || $0 == "'" || $0 == "\"" }) else { return argument }
        return "'" + argument.replacingOccurrences(of: "'", with: #"'\''"#) + "'"
    }
}
