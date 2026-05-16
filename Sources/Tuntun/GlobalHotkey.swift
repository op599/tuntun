import Carbon.HIToolbox
import Foundation

/// Minimal global hotkey via Carbon RegisterEventHotKey.
@MainActor
final class GlobalHotkey {
    private var hotKeyRef: EventHotKeyRef?
    private var handler: (() -> Void)?
    private static var nextID: UInt32 = 1

    struct Modifiers: OptionSet {
        let rawValue: UInt32
        static let command = Modifiers(rawValue: UInt32(cmdKey))
        static let option  = Modifiers(rawValue: UInt32(optionKey))
        static let control = Modifiers(rawValue: UInt32(controlKey))
        static let shift   = Modifiers(rawValue: UInt32(shiftKey))
    }

    init?(keyCode: UInt32, modifiers: Modifiers, handler: @escaping () -> Void) {
        self.handler = handler
        let id = Self.nextID
        Self.nextID += 1

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: OSType(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { (_, evt, ctx) -> OSStatus in
            guard let ctx else { return noErr }
            let me = Unmanaged<GlobalHotkey>.fromOpaque(ctx).takeUnretainedValue()
            DispatchQueue.main.async { me.handler?() }
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), nil)

        let hkID = EventHotKeyID(signature: OSType(0x54545454) /* 'TTTT' */, id: id)
        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(keyCode, modifiers.rawValue,
                                         hkID, GetApplicationEventTarget(),
                                         0, &ref)
        if status != noErr {
            return nil
        }
        self.hotKeyRef = ref
    }

    deinit {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
        }
    }
}
