import SwiftUI
import AVFoundation

struct OnboardingView: View {
    let detector: PostureDetectionManager
    let onComplete: () -> Void
    let onCalibrate: () -> Void

    @State private var step: Step = .welcome

    enum Step {
        case welcome, instructions, calibration, done
    }

    var body: some View {
        ZStack {
            switch step {
            case .welcome:
                WelcomeView {
                    withAnimation(.easeInOut(duration: 0.35)) { step = .instructions }
                }
            case .instructions:
                PostureInstructionsView {
                    withAnimation(.easeInOut(duration: 0.35)) { step = .calibration }
                }
            case .calibration:
                CalibrationView(
                    session: detector.camera.captureSession,
                    motion: detector.motion,
                    camera: detector.camera
                ) {
                    onCalibrate()
                    withAnimation(.easeInOut(duration: 0.35)) { step = .done }
                }
            case .done:
                CalibrationDoneView {
                    onComplete()
                }
            }
        }
        .transition(.opacity)
    }
}
