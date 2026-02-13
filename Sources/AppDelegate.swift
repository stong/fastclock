import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var timer: Timer?
    var menu: NSMenu?
    var actualTimeItem: NSMenuItem?

    let lockFilePath = NSTemporaryDirectory() + "com.fastclock.app.lock"
    let minutesAhead: Int = {
        if let envValue = ProcessInfo.processInfo.environment["FASTCLOCK_MINUTES"],
           let minutes = Int(envValue) {
            return minutes
        }
        return 7
    }()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check for existing instance
        if !acquireLock() {
            NSApplication.shared.terminate(nil)
            return
        }
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Create the menu
        menu = NSMenu()

        actualTimeItem = NSMenuItem(title: "Actual time: \(actualTimeString())", action: nil, keyEquivalent: "")
        actualTimeItem?.isEnabled = false
        menu?.addItem(actualTimeItem!)

        menu?.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu?.addItem(quitItem)

        statusItem?.menu = menu

        // Initial time update
        updateTime()

        // Update every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTime()
        }

        // Ensure timer fires during event tracking (like when menu is open)
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func updateTime() {
        guard let button = statusItem?.button else { return }

        // Get current date and add configured minutes
        let now = Date()
        let adjustedTime = now.addingTimeInterval(TimeInterval(minutesAhead * 60))

        // Format: "Thu Feb 12 23:04"
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d  HH:mm"

        let timeString = formatter.string(from: adjustedTime)

        // Use system font with adjusted letter spacing
        let font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
        ]
        button.attributedTitle = NSAttributedString(string: timeString, attributes: attributes)

        // Update the actual time in menu (updates in real-time)
        actualTimeItem?.title = "Actual time: \(actualTimeString())"
    }

    func actualTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }

    func isProcessAlive(_ pid: pid_t) -> Bool {
        return kill(pid, 0) == 0
    }

    func acquireLock() -> Bool {
        let fileManager = FileManager.default
        let currentPID = ProcessInfo.processInfo.processIdentifier

        // Check if lock file exists
        if fileManager.fileExists(atPath: lockFilePath) {
            // Read the existing PID
            if let pidString = try? String(contentsOfFile: lockFilePath, encoding: .utf8),
               let existingPID = pid_t(pidString.trimmingCharacters(in: .whitespacesAndNewlines)) {
                // Check if that process is still running
                if isProcessAlive(existingPID) {
                    print("FastClock is already running (PID: \(existingPID))")

                    // Show alert to user
                    let alert = NSAlert()
                    alert.messageText = "FastClock is already running"
                    alert.informativeText = "Only one instance of FastClock can run at a time."
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "OK")
                    alert.runModal()

                    return false
                }
                // Process is dead, we can take over the lock
                print("Previous instance (PID: \(existingPID)) crashed, acquiring lock")
            }
        }

        // Write our PID to the lock file
        do {
            try "\(currentPID)".write(toFile: lockFilePath, atomically: true, encoding: .utf8)
            return true
        } catch {
            print("Failed to write lock file: \(error)")
            return false
        }
    }

    func releaseLock() {
        let fileManager = FileManager.default
        try? fileManager.removeItem(atPath: lockFilePath)
    }

    @objc func quit() {
        releaseLock()
        NSApplication.shared.terminate(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        releaseLock()
    }
}
