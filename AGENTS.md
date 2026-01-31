# Agents

Guidelines for AI coding agents working on this project.

## Project Overview

Awake is a macOS menu bar app that prevents the system from sleeping. It uses IOKit power assertions to keep the Mac awake and Carbon APIs for global keyboard shortcuts.

## Architecture

```
Awake/
├── main.swift           # App entry point (pure AppKit, no SwiftUI @main)
├── AppDelegate.swift    # Menu bar UI and app lifecycle
├── AwakeManager.swift   # IOKit power assertion management
├── HotKeyManager.swift  # Global hotkey registration (Carbon)
└── Assets.xcassets/     # App icons
```

## Key Technical Details

- **No SwiftUI @main**: The app uses `main.swift` with manual `NSApplication` setup. SwiftUI's `@main` with `NSApplicationDelegateAdaptor` doesn't reliably initialize menu bar items.
- **Menu bar only**: `NSApp.setActivationPolicy(.accessory)` hides the dock icon.
- **IOKit for sleep prevention**: Uses `IOPMAssertionCreateWithName` and `IOPMAssertionRelease`.
- **Carbon for global hotkeys**: Uses `RegisterEventHotKey` since `NSEvent.addGlobalMonitorForEvents` requires accessibility permissions.

## Building

```bash
cd /Users/sid/Projects/Awake
xcodebuild -scheme Awake -configuration Release build
```

The built app will be in `~/Library/Developer/Xcode/DerivedData/Awake-*/Build/Products/Release/Awake.app`.

## Common Tasks

### Adding a new menu item
Edit `setupMenu()` in `AppDelegate.swift`. Create an `NSMenuItem`, set its `target` to `self`, and add an `@objc` handler method.

### Changing the global hotkey
Edit `HotKeyManager.swift`. Modify `keyCode` and `modifiers`. Key codes are defined in Carbon's `Events.h`. Current shortcut is Cmd+Shift+A.

### Adding a new sleep prevention mode
Edit `AwakeManager.swift`. Add a new case to the `Mode` enum with the appropriate `kIOPMAssertionType*` constant.

## Dependencies

- **IOKit.framework**: Sleep prevention APIs
- **Carbon.framework**: Global hotkey APIs
- **Cocoa.framework**: UI (implicit)

## Testing

Manual testing only. Key scenarios:
1. Toggle via menu and verify icon changes
2. Toggle via global hotkey (⌘⇧A) from another app
3. Set a duration and verify auto-disable
4. Switch modes and verify behavior
5. Quit app and verify sleep prevention stops
