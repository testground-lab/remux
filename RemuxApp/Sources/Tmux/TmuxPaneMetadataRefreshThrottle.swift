import Foundation

/// Spaces pane metadata refreshes per window. Taps and automatic window
/// renames can ask for one many times a second, and each costs a list-panes
/// round trip. A request inside the interval is deferred to its end rather
/// than dropped, so the last change is still picked up.
struct TmuxPaneMetadataRefreshThrottle {
    enum Decision: Equatable {
        case send
        case sendAfter(TimeInterval)
        case coalesced
    }

    static let interval: TimeInterval = 1

    private var lastSentAt: [TmuxWindowID: TimeInterval] = [:]
    private var deferredWindowIDs: Set<TmuxWindowID> = []

    mutating func request(_ windowID: TmuxWindowID, now: TimeInterval) -> Decision {
        guard !deferredWindowIDs.contains(windowID) else { return .coalesced }
        if let lastSentAt = lastSentAt[windowID], now - lastSentAt < Self.interval {
            deferredWindowIDs.insert(windowID)
            return .sendAfter(lastSentAt + Self.interval - now)
        }
        lastSentAt[windowID] = now
        return .send
    }

    mutating func sendDeferred(_ windowID: TmuxWindowID, now: TimeInterval) {
        deferredWindowIDs.remove(windowID)
        lastSentAt[windowID] = now
    }
}

/// The monotonic clock and deferral behind pane metadata refreshes, injected
/// so tests can drive the throttle without waiting.
struct TmuxPaneMetadataRefreshTiming: Sendable {
    var now: @Sendable () -> TimeInterval
    var schedule: @Sendable (TimeInterval, @escaping @Sendable () -> Void) -> Void

    static let live = TmuxPaneMetadataRefreshTiming(
        now: { ProcessInfo.processInfo.systemUptime },
        schedule: { delay, work in
            DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: work)
        }
    )
}
