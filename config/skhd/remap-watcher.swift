// Re-applies skhd's per-device .remap rules whenever a keyboard is plugged in.
// skhd only applies them at startup/reload, so a keyboard attached later
// (e.g. via a dock after boot) never gets remapped.
import Foundation
import IOKit
import IOKit.hid
import os

let skhd = "/opt/homebrew/bin/skhd"
let log = Logger(subsystem: "com.user.skhd-remap-watcher", category: "main")
var pending: DispatchWorkItem?

func scheduleReload() {
    pending?.cancel()
    let work = DispatchWorkItem {
        log.notice("keyboard attached, reloading skhd")
        let p = Process()
        p.executableURL = URL(fileURLWithPath: skhd)
        p.arguments = ["--reload"]
        do { try p.run(); p.waitUntilExit() } catch { log.error("skhd --reload failed: \(error.localizedDescription, privacy: .public)") }
    }
    pending = work
    // Debounce: one keyboard shows up as several HID interfaces.
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
}

func drain(_ it: io_iterator_t) -> Int {
    var n = 0
    while case let s = IOIteratorNext(it), s != 0 { IOObjectRelease(s); n += 1 }
    return n
}

let port = IONotificationPortCreate(kIOMainPortDefault)!
CFRunLoopAddSource(CFRunLoopGetMain(), IONotificationPortGetRunLoopSource(port).takeUnretainedValue(), .defaultMode)

let match = IOServiceMatching(kIOHIDDeviceKey) as NSMutableDictionary
match[kIOHIDPrimaryUsagePageKey] = kHIDPage_GenericDesktop
match[kIOHIDPrimaryUsageKey] = kHIDUsage_GD_Keyboard

var iter: io_iterator_t = 0
IOServiceAddMatchingNotification(port, kIOFirstMatchNotification, match, { _, it in
    if drain(it) > 0 { scheduleReload() }
}, nil, &iter)
// Arm the notification. Keyboards present at launch are already handled by skhd's own startup.
_ = drain(iter)
log.notice("watching for keyboards")
CFRunLoopRun()
