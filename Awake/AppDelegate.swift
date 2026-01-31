import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let awakeManager = AwakeManager()
    private var timer: Timer?
    private var hotKeyManager: HotKeyManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        NSApp.setActivationPolicy(.accessory)
        
        // Register global hotkey (Cmd+Shift+A)
        hotKeyManager = HotKeyManager { [weak self] in
            self?.toggleAwake()
        }
        
        // Update menu periodically when active (for remaining time display)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            if self?.awakeManager.isActive == true && self?.awakeManager.duration != nil {
                self?.setupMenu()
            }
        }
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem.button else {
            print("ERROR: Could not get status item button")
            return
        }
        
        // Use text title initially to ensure visibility
        button.title = "☕"
        
        updateMenuBarIcon()
        setupMenu()
    }
    
    private func updateMenuBarIcon() {
        guard let button = statusItem.button else { return }
        button.title = awakeManager.isActive ? "☕" : "😴"
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        // Status
        let statusTitle = awakeManager.isActive ? "Status: Awake" : "Status: Inactive"
        let statusMenuItem = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        
        // Remaining time (if applicable)
        if awakeManager.isActive, let remaining = awakeManager.remainingTime, remaining > 0 {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .abbreviated
            if let timeString = formatter.string(from: remaining) {
                let remainingItem = NSMenuItem(title: "Remaining: \(timeString)", action: nil, keyEquivalent: "")
                remainingItem.isEnabled = false
                menu.addItem(remainingItem)
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Toggle
        let toggleTitle = awakeManager.isActive ? "Disable" : "Enable"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggleAwake), keyEquivalent: "a")
        toggleItem.keyEquivalentModifierMask = [.command, .shift]
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Mode submenu
        let modeMenu = NSMenu()
        
        let displayItem = NSMenuItem(title: "Prevent Display Sleep", action: #selector(setDisplayMode), keyEquivalent: "")
        displayItem.target = self
        displayItem.state = awakeManager.currentMode == .preventDisplaySleep ? .on : .off
        modeMenu.addItem(displayItem)
        
        let systemItem = NSMenuItem(title: "Prevent System Sleep Only", action: #selector(setSystemMode), keyEquivalent: "")
        systemItem.target = self
        systemItem.state = awakeManager.currentMode == .preventSystemSleep ? .on : .off
        modeMenu.addItem(systemItem)
        
        let modeMenuItem = NSMenuItem(title: "Mode", action: nil, keyEquivalent: "")
        modeMenuItem.submenu = modeMenu
        menu.addItem(modeMenuItem)
        
        // Duration submenu
        let durationMenu = NSMenu()
        
        let indefiniteItem = NSMenuItem(title: "Indefinitely", action: #selector(setIndefinite), keyEquivalent: "")
        indefiniteItem.target = self
        indefiniteItem.state = awakeManager.duration == nil ? .on : .off
        durationMenu.addItem(indefiniteItem)
        
        durationMenu.addItem(NSMenuItem.separator())
        
        let durations: [(String, TimeInterval)] = [
            ("15 minutes", 15 * 60),
            ("30 minutes", 30 * 60),
            ("1 hour", 60 * 60),
            ("2 hours", 2 * 60 * 60),
            ("4 hours", 4 * 60 * 60),
        ]
        
        for (title, seconds) in durations {
            let item = NSMenuItem(title: title, action: #selector(setDuration(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = seconds
            item.state = awakeManager.duration == seconds ? .on : .off
            durationMenu.addItem(item)
        }
        
        let durationMenuItem = NSMenuItem(title: "Duration", action: nil, keyEquivalent: "")
        durationMenuItem.submenu = durationMenu
        menu.addItem(durationMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit Awake", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    @objc private func toggleAwake() {
        if awakeManager.isActive {
            awakeManager.stop()
        } else {
            awakeManager.start()
        }
        updateMenuBarIcon()
        setupMenu()
    }
    
    @objc private func setDisplayMode() {
        awakeManager.currentMode = .preventDisplaySleep
        if awakeManager.isActive { awakeManager.restart() }
        setupMenu()
    }
    
    @objc private func setSystemMode() {
        awakeManager.currentMode = .preventSystemSleep
        if awakeManager.isActive { awakeManager.restart() }
        setupMenu()
    }
    
    @objc private func setIndefinite() {
        awakeManager.duration = nil
        if awakeManager.isActive { awakeManager.restart() }
        setupMenu()
    }
    
    @objc private func setDuration(_ sender: NSMenuItem) {
        guard let duration = sender.representedObject as? TimeInterval else { return }
        awakeManager.duration = duration
        if awakeManager.isActive { awakeManager.restart() }
        setupMenu()
    }
    
    @objc private func quitApp() {
        awakeManager.stop()
        NSApp.terminate(nil)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        awakeManager.stop()
    }
}
