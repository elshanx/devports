import Foundation
import XCTest
@testable import DevPorts

final class DevPortsTests: XCTestCase {
    func testFindsAndStopsDevServer() async throws {
        let folder = URL(fileURLWithPath: Project.home).appendingPathComponent(".ports-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        try Data(#"{"name":"ports-test"}"#.utf8).write(to: folder.appendingPathComponent("package.json"))

        let server = Process()
        server.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        server.arguments = ["-m", "http.server", "47123", "--bind", "127.0.0.1"]
        server.currentDirectoryURL = folder
        server.standardOutput = FileHandle.nullDevice
        server.standardError = FileHandle.nullDevice
        try server.run()
        defer { if server.isRunning { server.terminate() } }

        var found: Listener?
        for _ in 0..<50 where found == nil {
            try await Task.sleep(for: .milliseconds(200))
            found = Scanner.scan().first { $0.ports.contains(47123) }
        }
        let listener = try XCTUnwrap(found)
        XCTAssertEqual(listener.kind, .dev)
        XCTAssertEqual(listener.name, "ports-test")
        XCTAssertEqual(listener.folder.map { URL(fileURLWithPath: $0).resolvingSymlinksInPath().path },
                       folder.resolvingSymlinksInPath().path)

        let result = await Killer.stop(listener)
        XCTAssertNil(result.error)
        XCTAssertFalse(Scanner.isListening(pid: listener.pid))
        XCTAssertFalse(server.isRunning && Scanner.isListening(pid: server.processIdentifier))
    }

    func testStopsWholeProcessGroup() async throws {
        let folder = URL(fileURLWithPath: Project.home).appendingPathComponent(".ports-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }

        let wrapper = Process()
        wrapper.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        wrapper.arguments = ["-c", "import os; os.setpgid(0, 0); os.execvp('sh', ['sh', '-c', "
            + "'/usr/bin/python3 -m http.server 47125 --bind 127.0.0.1; true'])"]
        wrapper.currentDirectoryURL = folder
        wrapper.standardOutput = FileHandle.nullDevice
        wrapper.standardError = FileHandle.nullDevice
        try wrapper.run()
        defer { if wrapper.isRunning { kill(-wrapper.processIdentifier, SIGKILL) } }

        var found: Listener?
        for _ in 0..<50 where found == nil {
            try await Task.sleep(for: .milliseconds(200))
            found = Scanner.scan().first { $0.ports.contains(47125) }
        }
        let listener = try XCTUnwrap(found)
        XCTAssertEqual(listener.pgid, wrapper.processIdentifier)
        XCTAssertNotEqual(listener.pid, wrapper.processIdentifier)

        let result = await Killer.stop(listener)
        XCTAssertNil(result.error)
        try await Task.sleep(for: .milliseconds(300))
        XCTAssertFalse(wrapper.isRunning)
    }

    func testRestartsStoppedDevServer() async throws {
        let folder = URL(fileURLWithPath: Project.home).appendingPathComponent(".ports-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let wrapper = Process()
        wrapper.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        wrapper.arguments = ["-c", "import os; os.setpgid(0, 0); os.execvp('sh', ['sh', '-c', "
            + "'/usr/bin/python3 -m http.server 47126 --bind 127.0.0.1; true'])"]
        wrapper.currentDirectoryURL = folder
        try wrapper.run()

        let first = try await waitForListener(port: 47126)
        let result = await Killer.stop(first)
        XCTAssertNil(result.error)
        let spec = try XCTUnwrap(result.restart)
        XCTAssertEqual(spec.arguments.first, "sh")
        XCTAssertEqual(spec.arguments.count, 3)
        XCTAssertEqual(URL(fileURLWithPath: spec.folder).standardizedFileURL.path, folder.standardizedFileURL.path)

        let log = folder.appendingPathComponent("server.log")
        let pid = try spec.launch(logTo: log)
        defer { kill(-pid, SIGKILL) }
        let header = try String(contentsOf: log, encoding: .utf8)
        XCTAssertTrue(header.contains("Folder:  \(spec.folder)"), header)
        XCTAssertTrue(header.contains("Command: sh -c "), header)
        let second = try await waitForListener(port: 47126)
        XCTAssertEqual(second.kind, .dev)
        XCTAssertEqual(second.pgid, pid)
    }

    @MainActor
    func testRestartReportsRunning() async throws {
        let folder = URL(fileURLWithPath: Project.home).appendingPathComponent(".ports-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let wrapper = Process()
        wrapper.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        wrapper.arguments = ["-c", "import os; os.setpgid(0, 0); os.execvp('sh', ['sh', '-c', "
            + "'/usr/bin/python3 -m http.server 47127 --bind 127.0.0.1; true'])"]
        wrapper.currentDirectoryURL = folder
        try wrapper.run()

        let store = Store()
        store.stop(try await waitForListener(port: 47127))
        let stopped = try await waitFor { store.recentlyStopped.first }
        XCTAssertEqual(stopped.state, .stopped)

        store.restart(stopped)
        XCTAssertTrue(store.recentlyStopped.first?.isStarting ?? false)
        let running = try await waitFor { store.recentlyStopped.first { $0.state == .running(port: 47127) } }
        XCTAssertEqual(running.id, stopped.id)
        if let listener = Scanner.scan().first(where: { $0.ports.contains(47127) }) { kill(-listener.pgid, SIGKILL) }
    }

    @MainActor
    private func waitFor<T>(_ check: () -> T?) async throws -> T {
        for _ in 0..<100 {
            if let value = check() { return value }
            try await Task.sleep(for: .milliseconds(200))
        }
        throw XCTSkip("Timed out")
    }

    private func waitForListener(port: Int) async throws -> Listener {
        for _ in 0..<50 {
            if let found = Scanner.scan().first(where: { $0.ports.contains(port) }) { return found }
            try await Task.sleep(for: .milliseconds(200))
        }
        throw XCTSkip("No listener on port \(port)")
    }

    func testHidesDebuggerAndRandomPorts() {
        let astro = Listener(pid: 1, pgid: 1, name: "a", command: "node", folder: nil,
                             ports: [4321, 9229, 62830, 63380], kind: .dev, container: nil)
        XCTAssertEqual(astro.mainPorts, [4321])
        XCTAssertEqual(astro.internalPorts, [9229, 62830, 63380])
        let onlyRandom = Listener(pid: 1, pgid: 1, name: "b", command: "x", folder: nil,
                                  ports: [61541], kind: .other, container: nil)
        XCTAssertEqual(onlyRandom.mainPorts, [61541])
        XCTAssertEqual(onlyRandom.internalPorts, [])
    }

    func testSystemListenersAreNotDevServers() {
        for listener in Scanner.scan() where Project.isProtected(command: listener.command) {
            XCTAssertNotEqual(listener.kind, .dev, listener.command)
        }
    }
}
