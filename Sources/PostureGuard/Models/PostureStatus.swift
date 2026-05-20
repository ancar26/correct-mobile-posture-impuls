import Foundation

enum PostureStatus: Equatable {
    case uncalibrated
    case calibrating
    case good
    case warning
    case bad
    case idle        // phone not being held (on table, in pocket, lying flat)
    case justPickedUp // brief grace period after phone is picked up
}

struct PostureBaseline: Codable {
    let phonePitch: Double
    let facePitch: Double?

    private static let defaultsKey = "postureguard.baseline"

    static func load() -> PostureBaseline? {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let saved = try? JSONDecoder().decode(PostureBaseline.self, from: data) else { return nil }
        return saved
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.defaultsKey)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }
}

struct PostureReading {
    let phonePitchDegrees: Double
    let facePitch: Double?
    let faceYaw: Double?
    let shoulderSlope: Double?
    let timestamp: Date

    // Wider range: exclude only when truly flat (on table ~-90°) or face-down (~+90°)
    // Grace for upright holding (close to 0°) and steep tilt (up to -82°)
    var phoneIsBeingHeld: Bool {
        phonePitchDegrees > -82 && phonePitchDegrees < 15
    }

    func isBadPosture(relativeTo baseline: PostureBaseline) -> Bool {
        guard phoneIsBeingHeld else { return false }

        var score = 0

        let phoneDev = baseline.phonePitch - phonePitchDegrees
        if phoneDev > 25 { score += 2 }
        else if phoneDev > 12 { score += 1 }

        if let pitch = facePitch, let yaw = faceYaw, abs(yaw) < 0.7 {
            let baselinePitch = baseline.facePitch ?? 0.0
            let pitchDrop = baselinePitch - pitch
            if pitchDrop > 0.25 { score += 2 }
            else if pitchDrop > 0.12 { score += 1 }
        }

        if let slope = shoulderSlope, slope > 0.08 { score += 1 }

        return score >= 2
    }
}
