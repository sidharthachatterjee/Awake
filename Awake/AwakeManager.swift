import Foundation
import IOKit.pwr_mgt

/// Manages system sleep prevention using IOKit power assertions
class AwakeManager {
    
    enum Mode {
        case preventDisplaySleep
        case preventSystemSleep
        
        var assertionType: String {
            switch self {
            case .preventDisplaySleep:
                return kIOPMAssertionTypePreventUserIdleDisplaySleep as String
            case .preventSystemSleep:
                return kIOPMAssertionTypePreventUserIdleSystemSleep as String
            }
        }
    }
    
    private(set) var isActive: Bool = false
    var currentMode: Mode = .preventDisplaySleep
    var duration: TimeInterval? = nil
    
    private var assertionID: IOPMAssertionID = 0
    private var durationTimer: Timer?
    private var startTime: Date?
    
    var remainingTime: TimeInterval? {
        guard let duration = duration, let startTime = startTime else { return nil }
        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = duration - elapsed
        return remaining > 0 ? remaining : 0
    }
    
    func start() {
        guard !isActive else { return }
        
        let result = IOPMAssertionCreateWithName(
            currentMode.assertionType as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Awake - Keeping your Mac awake" as CFString,
            &assertionID
        )
        
        if result == kIOReturnSuccess {
            isActive = true
            startTime = Date()
            
            if let duration = duration {
                durationTimer?.invalidate()
                durationTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                    self?.stop()
                }
            }
        }
    }
    
    func stop() {
        guard isActive else { return }
        
        IOPMAssertionRelease(assertionID)
        assertionID = 0
        isActive = false
        durationTimer?.invalidate()
        durationTimer = nil
        startTime = nil
    }
    
    func restart() {
        stop()
        start()
    }
    
    deinit {
        stop()
    }
}
