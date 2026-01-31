import Carbon
import Cocoa

class HotKeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let callback: () -> Void
    
    // Cmd+Shift+A
    private let keyCode: UInt32 = 0x00  // 'A' key
    private let modifiers: UInt32 = UInt32(cmdKey | shiftKey)
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
        register()
    }
    
    deinit {
        unregister()
    }
    
    private func register() {
        // Store self pointer for C callback
        let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        // Define the hotkey event type
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        // Install event handler
        let handlerCallback: EventHandlerUPP = { _, event, refcon -> OSStatus in
            guard let refcon = refcon else { return OSStatus(eventNotHandledErr) }
            let manager = Unmanaged<HotKeyManager>.fromOpaque(refcon).takeUnretainedValue()
            
            DispatchQueue.main.async {
                manager.callback()
            }
            
            return noErr
        }
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            handlerCallback,
            1,
            &eventType,
            refcon,
            &eventHandler
        )
        
        // Register the hotkey
        var hotKeyID = EventHotKeyID(signature: OSType(0x4157414B), id: 1)  // "AWAK"
        
        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }
    
    private func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
}
