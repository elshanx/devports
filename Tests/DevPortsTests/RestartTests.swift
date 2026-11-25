import Foundation
import XCTest
@testable import DevPorts

final class RestartTests: XCTestCase {
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
    func testRestartsStoppedOtherProcess() async throws {
        let folder = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("plain-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let wrapper = Process()
        wrapper.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        wrapper.arguments = ["-c", "import os; os.setpgid(0, 0); os.execvp('python3', "
            + "['python3', '-m', 'http.server', '47131', '--bind', '127.0.0.1'])"]
        wrapper.currentDirectoryURL = folder
        try wrapper.run()

        let store = Store()
        let listener = try await waitForListener(port: 47131)
        XCTAssertEqual(listener.kind, .other)
        store.stop(listener)
        let stopped = try await waitFor { store.recentlyStopped.first }
        XCTAssertEqual(stopped.kind, .other)

        store.restartLatest()
        store.restartLatest()
        XCTAssertTrue(store.recentlyStopped.first?.isStarting ?? false)
        _ = try await waitFor { store.recentlyStopped.first { $0.state == .running(port: 47131) } }
        if let restarted = Scanner.scan().first(where: { $0.ports.contains(47131) }) { kill(-restarted.pgid, SIGKILL) }
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
}
