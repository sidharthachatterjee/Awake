# Awake

<p align="center">
  <img src="Awake/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" alt="Awake Icon" width="128" height="128">
</p>

A lightweight macOS menu bar app that keeps your Mac awake. Similar to Amphetamine, but simpler.

## Features

- **Menu bar app** - Lives in your menu bar, no dock icon
- **Global hotkey** - Toggle with **⌘⇧A** from anywhere
- **Two modes**:
  - Prevent Display Sleep - keeps screen on
  - Prevent System Sleep Only - screen can sleep, Mac stays awake
- **Timed sessions** - 15 min, 30 min, 1 hour, 2 hours, 4 hours, or indefinite
- **Visual feedback** - Icon changes: ☕ (active) / 😴 (inactive)

## Installation

### Build from source

Requires Xcode.

```bash
git clone <repo-url>
cd Awake
xcodebuild -scheme Awake -configuration Release build
```

Then copy to Applications:

```bash
cp -r ~/Library/Developer/Xcode/DerivedData/Awake-*/Build/Products/Release/Awake.app /Applications/
```

### Run directly

```bash
open ~/Library/Developer/Xcode/DerivedData/Awake-*/Build/Products/Release/Awake.app
```

Or open `Awake.xcodeproj` in Xcode and press ⌘R.

## Usage

1. Launch the app - look for ☕ or 😴 in your menu bar
2. Click the icon to access the menu
3. Click **Enable** to keep your Mac awake
4. Use **⌘⇧A** to quickly toggle from any app

### Menu Options

| Option | Description |
|--------|-------------|
| Enable/Disable | Toggle sleep prevention |
| Mode | Choose what to keep awake |
| Duration | Set auto-disable timer |
| Quit Awake | Exit the app |

## Requirements

- macOS 13.0 or later

## How It Works

Awake uses macOS IOKit power assertions (`IOPMAssertionCreateWithName`) to prevent sleep. This is the same API used by system utilities and is fully supported by Apple.

## License

MIT
