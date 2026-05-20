import Foundation
import Combine

final class PostureDetectionManager: ObservableObject {
    @Published private(set) var status: PostureStatus = .uncalibrated
    @Published private(set) var badPostureDuration: TimeInterval = 0
    @Published private(set) var baseline: PostureBaseline? = nil

    let camera = CameraManager()
    let motion = MotionManager()

    let alertThreshold: TimeInterval = 12
    private let pickUpGracePeriod: TimeInterval = 3

    private var badPostureStartTime: Date?
    private var wasActivelyHeld: Bool = false
    private var pickUpTime: Date? = nil
    private var ticker: Timer?

    func start() {
        if let saved = PostureBaseline.load() {
            baseline = saved
            status = .good
        }
        motion.start()
        camera.start()
        ticker = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.evaluate()
        }
    }

    func stop() {
        ticker?.invalidate()
        ticker = nil
        motion.stop()
        camera.stop()
    }

    func calibrate() {
        let b = PostureBaseline(
            phonePitch: motion.phonePitchDegrees,
            facePitch: camera.facePitch
        )
        baseline = b
        b.save()
        status = .good
        badPostureStartTime = nil
        badPostureDuration = 0
    }

    func resetCalibration() {
        baseline = nil
        PostureBaseline.clear()
        status = .uncalibrated
        badPostureStartTime = nil
        badPostureDuration = 0
        wasActivelyHeld = false
        pickUpTime = nil
    }

    func acknowledgeAlert() {
        badPostureStartTime = Date()
        status = .good
        badPostureDuration = 0
    }

    private func evaluate() {
        guard let baseline else {
            status = .uncalibrated
            return
        }

        let reading = PostureReading(
            phonePitchDegrees: motion.phonePitchDegrees,
            facePitch: camera.facePitch,
            faceYaw: camera.faceYaw,
            shoulderSlope: camera.shoulderSlope,
            timestamp: Date()
        )

        // Gate 1: phone must be physically moving (held in hand, not on table/pocket)
        let activelyHeld = motion.isActivelyHeld && reading.phoneIsBeingHeld

        // Detect pick-up moment: transition from still → held+moving
        if activelyHeld && !wasActivelyHeld {
            pickUpTime = Date()
        }
        wasActivelyHeld = activelyHeld

        guard activelyHeld else {
            // Phone is still (on table, pocket, etc.) — reset silently, no status noise
            badPostureStartTime = nil
            badPostureDuration = 0
            if status != .good && status != .uncalibrated {
                status = .good  // Return to good rather than showing "paused"
            }
            return
        }

        // Grace period right after picking up
        if let pickUp = pickUpTime,
           Date().timeIntervalSince(pickUp) < pickUpGracePeriod {
            status = .justPickedUp
            return
        }

        if reading.isBadPosture(relativeTo: baseline) {
            let start = badPostureStartTime ?? Date()
            if badPostureStartTime == nil { badPostureStartTime = start }
            badPostureDuration = Date().timeIntervalSince(start)
            status = badPostureDuration >= alertThreshold ? .bad : .warning
        } else {
            badPostureStartTime = nil
            badPostureDuration = 0
            if status != .bad {
                status = .good
            }
        }
    }
}
