import Foundation

enum ProcessInfoReader {
    static func groupsAndCommands(pids: String) -> [Int32: (Int32, String)] {
        var result: [Int32: (Int32, String)] = [:]
        for line in Shell.run("/bin/ps", ["-o", "pid=,pgid=,command=", "-p", pids]).split(separator: "\n") {
            let parts = line.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
            guard parts.count == 3, let pid = Int32(parts[0]), let pgid = Int32(parts[1]) else { continue }
            result[pid] = (pgid, String(parts[2]))
        }
        return result
    }

    static func groupCommands(pgid: Int32) -> [String] {
        Shell.run("/bin/ps", ["-A", "-o", "pgid=,command="]).split(separator: "\n").compactMap { line in
            let parts = line.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            guard parts.count == 2, Int32(parts[0]) == pgid else { return nil }
            return String(parts[1])
        }
    }

    static func workingFolders(pids: String) -> [Int32: String] {
        var result: [Int32: String] = [:]
        var current: Int32?
        for line in Shell.run("/usr/sbin/lsof", ["-a", "-p", pids, "-d", "cwd", "-F", "pn"]).split(separator: "\n") {
            let value = String(line.dropFirst())
            if line.first == "p" { current = Int32(value) }
            if line.first == "n", let pid = current { result[pid] = value }
        }
        return result
    }
}

enum DockerReader {
    static let path = ["/usr/local/bin/docker", "/opt/homebrew/bin/docker"]
        .first { FileManager.default.isExecutableFile(atPath: $0) }

    static func containersByPort() -> [Int: String] {
        guard let path else { return [:] }
        var result: [Int: String] = [:]
        let output = Shell.run(path, ["ps", "--format", "{{.Names}}\t{{.Ports}}"])
        let regex = try! Regex(#":(\d+)->"#, as: (Substring, Substring).self)
        for line in output.split(separator: "\n") {
            let parts = line.split(separator: "\t", maxSplits: 1)
            guard parts.count == 2 else { continue }
            for match in parts[1].matches(of: regex) {
                if let port = Int(match.1) { result[port] = String(parts[0]) }
            }
        }
        return result
    }
}

enum Project {
    static let home = FileManager.default.homeDirectoryForCurrentUser.path
    static let protectedPrefixes = ["/System", "/usr/libexec", "/usr/sbin", "/sbin", "/Applications", home + "/Library/Application Support"]
    static let markers = ["package.json", ".git", "Cargo.toml", "go.mod", "pyproject.toml", "Gemfile"]

    static func isProtected(command: String) -> Bool {
        !command.hasPrefix("/Applications/Xcode.app/Contents/Developer/")
            && protectedPrefixes.contains { command.hasPrefix($0) }
    }

    static func find(from folder: String?, command: String) -> (name: String, root: String)? {
        guard let folder, folder.hasPrefix(home + "/"), !folder.hasPrefix(home + "/Library"),
              !isProtected(command: command) else { return nil }
        var url = URL(fileURLWithPath: folder)
        while url.path.hasPrefix(home + "/") {
            if markers.contains(where: { FileManager.default.fileExists(atPath: url.appendingPathComponent($0).path) }) {
                return (packageName(in: url) ?? url.lastPathComponent, url.path)
            }
            url.deleteLastPathComponent()
        }
        return (URL(fileURLWithPath: folder).lastPathComponent, folder)
    }

    private static func packageName(in url: URL) -> String? {
        guard let data = try? Data(contentsOf: url.appendingPathComponent("package.json")),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return json["name"] as? String
    }
}
