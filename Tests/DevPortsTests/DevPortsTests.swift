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

    func testHidesDebuggerAndRandomPorts() {
        let astro = Listener(pid: 1, pgid: 1, name: "a", command: "node", folder: nil,
                             ports: [4321, 9229, 62830, 63380], kind: .dev, container: nil)
        XCTAssertEqual(astro.mainPorts, [4321])
        XCTAssertEqual(astro.internalPorts, [9229, 62830, 63380])
        let onlyRandom = Listener(pid: 1, pgid: 1, name: "b", command: "x", folder: nil,
                                  ports: [61541], kind: .other, container: nil)
        XCTAssertEqual(onlyRandom.mainPorts, [61541])
        XCTAssertEqual(onlyRandom.internalPorts, [])
        XCTAssertTrue(onlyRandom.onRandomPortsOnly)
        XCTAssertFalse(astro.onRandomPortsOnly)
    }

    func testToolOnRandomPortInProjectIsNotDevServer() {
        let helper = Listener(pid: 1, pgid: 1, name: "agent-kanban", command: "/bin/agent-browser --daemon",
                              folder: "/Users/x/dev/agent-kanban", ports: [65204], kind: .dev, container: nil)
        let demoted = Scanner.demoteHelper(helper)
        XCTAssertEqual(demoted.kind, .other)
        XCTAssertEqual(demoted.name, "agent-browser")
        let server = Listener(pid: 2, pgid: 2, name: "shop", command: "node", folder: nil, ports: [3000, 65000],
                              kind: .dev, container: nil)
        XCTAssertEqual(Scanner.demoteHelper(server).kind, .dev)
    }

    @MainActor
    func testRegistersGlobalHotKey() {
        XCTAssertTrue(HotKey {}.isRegistered)
    }

    func testShellStopsCommandsThatHang() {
        let start = Date()
        XCTAssertEqual(Shell.run("/bin/sleep", ["10"], timeout: 0.5), "")
        XCTAssertLessThan(Date().timeIntervalSince(start), 3)
    }

    func testFilterMatchesNameFolderAndPort() {
        let app = Listener(pid: 1, pgid: 1, name: "storefront", command: "node", folder: "/Users/x/dev/shop",
                           ports: [4321], kind: .dev, container: nil)
        XCTAssertTrue(app.matches(""))
        XCTAssertTrue(app.matches("STORE"))
        XCTAssertTrue(app.matches("shop"))
        XCTAssertTrue(app.matches("43"))
        XCTAssertFalse(app.matches("321"))
        XCTAssertFalse(app.matches("vite"))
    }

    func testSystemListenersAreNotDevServers() {
        for listener in Scanner.scan() where Project.isProtected(command: listener.command) {
            XCTAssertNotEqual(listener.kind, .dev, listener.command)
        }
    }
}
