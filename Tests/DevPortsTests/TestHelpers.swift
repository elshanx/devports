import Foundation
import XCTest
@testable import DevPorts

extension XCTestCase {
    @MainActor
    func waitFor<T>(_ check: () -> T?) async throws -> T {
        for _ in 0..<100 {
            if let value = check() { return value }
            try await Task.sleep(for: .milliseconds(200))
        }
        throw XCTSkip("Timed out")
    }

    func waitForListener(port: Int) async throws -> Listener {
        for _ in 0..<50 {
            if let found = Scanner.scan().first(where: { $0.ports.contains(port) }) { return found }
            try await Task.sleep(for: .milliseconds(200))
        }
        throw XCTSkip("No listener on port \(port)")
    }
}
