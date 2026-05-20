import CoreMotion
import Combine

final class MotionManager: ObservableObject {
    @Published private(set) var phonePitchDegrees: Double = 0
    // True when the phone has had recent hand movement — false when lying still on a table/surface
    @Published private(set) var isActivelyHeld: Bool = false

    private let motionManager = CMMotionManager()
    // Rolling window of userAcceleration magnitudes (gravity removed by CoreMotion)
    private var accelHistory: [Double] = []
    private let windowSize = 8  // 4 seconds at 0.5s interval

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 0.5
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            phonePitchDegrees = motion.attitude.pitch * 180 / .pi

            // userAcceleration has gravity removed — pure hand movement signal
            let a = motion.userAcceleration
            let magnitude = sqrt(a.x*a.x + a.y*a.y + a.z*a.z)
            accelHistory.append(magnitude)
            if accelHistory.count > windowSize { accelHistory.removeFirst() }

            // Variance of recent acceleration: low = stationary, high = being moved
            if accelHistory.count == windowSize {
                let mean = accelHistory.reduce(0, +) / Double(windowSize)
                let variance = accelHistory.map { ($0 - mean) * ($0 - mean) }.reduce(0, +) / Double(windowSize)
                // Threshold tuned: hand holding tremor >> table stillness
                isActivelyHeld = variance > 0.00008
            }
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        accelHistory.removeAll()
        isActivelyHeld = false
    }
}
