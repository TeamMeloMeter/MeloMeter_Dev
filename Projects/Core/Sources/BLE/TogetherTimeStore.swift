import Foundation

public final class TogetherTimeStore {
    public static let shared = TogetherTimeStore()
    public static let didUpdateNotification = Notification.Name("TogetherTimeStoreDidUpdate")

    public struct State: Codable {
        public var sessionStart: Date?
        public var lastSeen: Date?
        public var accumulatedSeconds: TimeInterval
        public var lastEndedAt: Date?
    }

    private let stateKey = "togetherTimeState"

    private init() {}

    public func recordHeartbeat(at date: Date,
                                coupleId: String?,
                                missingThreshold: TimeInterval) {
        var state = loadState(coupleId: coupleId)
        if let lastSeen = state.lastSeen,
           date.timeIntervalSince(lastSeen) >= missingThreshold {
            state = closeSession(state, endedAt: lastSeen)
        }
        if state.sessionStart == nil {
            state.sessionStart = date
        }
        state.lastSeen = date
        saveState(state, coupleId: coupleId)
    }

    public func refreshState(now: Date,
                             coupleId: String?,
                             missingThreshold: TimeInterval) {
        var state = loadState(coupleId: coupleId)
        guard let lastSeen = state.lastSeen else { return }
        guard now.timeIntervalSince(lastSeen) >= missingThreshold else { return }
        state = closeSession(state, endedAt: lastSeen)
        saveState(state, coupleId: coupleId)
    }

    public func currentState(coupleId: String?) -> State {
        loadState(coupleId: coupleId)
    }

    public func currentDurationSeconds(now: Date,
                                       coupleId: String?,
                                       missingThreshold: TimeInterval) -> TimeInterval {
        var state = loadState(coupleId: coupleId)
        if let lastSeen = state.lastSeen,
           now.timeIntervalSince(lastSeen) >= missingThreshold {
            state = closeSession(state, endedAt: lastSeen)
            saveState(state, coupleId: coupleId)
        }
        if let sessionStart = state.sessionStart {
            return state.accumulatedSeconds + now.timeIntervalSince(sessionStart)
        }
        return state.accumulatedSeconds
    }

    public func clear(coupleId: String?) {
        UserDefaults.standard.removeObject(forKey: key(base: stateKey, coupleId: coupleId))
    }

    private func closeSession(_ state: State, endedAt: Date) -> State {
        var updated = state
        if let start = updated.sessionStart {
            updated.accumulatedSeconds += max(0, endedAt.timeIntervalSince(start))
        }
        updated.sessionStart = nil
        updated.lastSeen = nil
        updated.lastEndedAt = endedAt
        NotificationCenter.default.post(name: Self.didUpdateNotification, object: nil)
        return updated
    }

    private func loadState(coupleId: String?) -> State {
        let key = key(base: stateKey, coupleId: coupleId)
        guard let data = UserDefaults.standard.data(forKey: key),
              let state = try? JSONDecoder().decode(State.self, from: data) else {
            return State(sessionStart: nil, lastSeen: nil, accumulatedSeconds: 0, lastEndedAt: nil)
        }
        return state
    }

    private func saveState(_ state: State, coupleId: String?) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        let key = key(base: stateKey, coupleId: coupleId)
        UserDefaults.standard.set(data, forKey: key)
        NotificationCenter.default.post(name: Self.didUpdateNotification, object: nil)
    }

    private func key(base: String, coupleId: String?) -> String {
        guard let coupleId, coupleId.isEmpty == false else { return base }
        return "\(base)-\(coupleId)"
    }
}
