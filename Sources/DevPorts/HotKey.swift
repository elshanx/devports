import Carbon.HIToolbox

@MainActor
final class HotKey {
    static let title = "⌥⌘P"

    private let action: () -> Void
    private var reference: EventHotKeyRef?
    private(set) var isRegistered = false

    init(action: @escaping () -> Void) {
        self.action = action
        var pressed = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, _, context in
            guard let context else { return noErr }
            let hotKey = Unmanaged<HotKey>.fromOpaque(context).takeUnretainedValue()
            MainActor.assumeIsolated { hotKey.action() }
            return noErr
        }, 1, &pressed, Unmanaged.passUnretained(self).toOpaque(), nil)
        isRegistered = RegisterEventHotKey(UInt32(kVK_ANSI_P), UInt32(cmdKey | optionKey),
                            EventHotKeyID(signature: OSType(0x4450_5254), id: 1),
                            GetApplicationEventTarget(), 0, &reference) == noErr
    }
}
