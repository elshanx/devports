import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private let store = Store()
    private let loginItem = LoginItem()
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()
    private var hotKey: HotKey?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Refresh", action: #selector(refresh), keyEquivalent: "r").target = self
        appMenu.addItem(withTitle: "Quit DevPorts", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        NSApp.mainMenu = NSMenu()
        NSApp.mainMenu?.addItem(appMenuItem)
        let controller = NSHostingController(rootView: ContentView(store: store, loginItem: loginItem) { [weak self] in
            self?.popover.performClose(nil)
        })
        controller.sizingOptions = .preferredContentSize
        popover.contentViewController = controller
        popover.behavior = .transient
        popover.delegate = self
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "network", accessibilityDescription: "DevPorts")
            button.imagePosition = .imageLeading
            button.target = self
            button.action = #selector(togglePopover)
        }
        showDevServerCount()
        hotKey = HotKey { [weak self] in self?.togglePopover() }
        loginItem.enableOnFirstLaunch()
    }

    func popoverDidClose(_ notification: Notification) {
        NSApp.hide(nil)
    }

    @objc private func refresh() {
        store.refresh()
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            store.refresh()
            NSApp.activate()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            let window = popover.contentViewController?.view.window
            window?.makeKey()
            window?.makeFirstResponder(nil)
            NotificationCenter.default.post(name: ContentView.didOpen, object: nil)
        }
    }

    private func showDevServerCount() {
        withObservationTracking {
            let count = store.devServers.count
            statusItem.button?.title = count == 0 ? "" : String(count)
        } onChange: {
            Task { @MainActor in self.showDevServerCount() }
        }
    }
}
