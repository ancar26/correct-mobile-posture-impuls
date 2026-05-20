import SwiftUI
import AVFoundation

struct CalibrationView: View {
    let session: AVCaptureSession
    let motion: MotionManager
    let camera: CameraManager
    let onCalibrate: () -> Void

    @State private var countdown: Int? = nil
    @State private var countdownTimer: Timer? = nil

    private var validation: CalibrationValidation {
        CalibrationValidation(
            phonePitch: motion.phonePitchDegrees,
            facePitch: camera.facePitch,
            faceYaw: camera.faceYaw
        )
    }

    var body: some View {
        ZStack {
            CameraPreviewView(session: session)
                .ignoresSafeArea()

            Color.black.opacity(0.5).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Live validation feedback — updates in real time
                ValidationFeedbackCard(validation: validation)
                    .padding(.horizontal, 28)
                    .animation(.easeInOut(duration: 0.3), value: validation.status)

                Spacer().frame(height: 32)

                // Countdown or button
                if let countdown {
                    ZStack {
                        Circle()
                            .strokeBorder(.green, lineWidth: 3)
                            .frame(width: 80, height: 80)
                        Text("\(countdown)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(.green)
                    }
                    .frame(height: 90)
                } else {
                    Button(action: startCountdown) {
                        HStack(spacing: 10) {
                            Image(systemName: validation.isReady ? "checkmark.circle.fill" : "lock.fill")
                            Text(validation.isReady ? "Save baseline" : "Fix position first")
                        }
                        .font(.headline)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 16)
                        .background(validation.isReady ? Color.green : Color.gray.opacity(0.4))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                    .disabled(!validation.isReady)
                    .frame(height: 90)
                }

                Spacer().frame(height: 56)
            }
        }
    }

    private func startCountdown() {
        guard validation.isReady else { return }
        countdown = 3
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            // Cancel if user moves to a bad position during countdown
            guard validation.isReady else {
                t.invalidate()
                countdown = nil
                return
            }
            guard let c = countdown else { return }
            if c <= 1 {
                t.invalidate()
                countdown = nil
                onCalibrate()
            } else {
                countdown = c - 1
            }
        }
    }
}

// MARK: - Validation logic

struct CalibrationValidation: Equatable {
    let phonePitch: Double
    let facePitch: Double?
    let faceYaw: Double?

    enum Status: Equatable {
        case ready
        case phoneTooLow
        case headTiltedDown
        case noFaceDetected
    }

    var status: Status {
        // Block only clearly bad positions: phone nearly horizontal (on table / at waist)
        // Accept everything from slightly forward tilt (+20°) down to -60°
        if phonePitch < -60 {
            return .phoneTooLow
        }
        // If face is detected and clearly looking down, block it
        if let pitch = facePitch, let yaw = faceYaw, abs(yaw) < 0.8 {
            if pitch < -0.28 {
                return .headTiltedDown
            }
        }
        return .ready
    }

    var isReady: Bool { status == .ready }

    var icon: String {
        switch status {
        case .ready:          return "checkmark.circle.fill"
        case .phoneTooLow:    return "arrow.up.circle.fill"
        case .headTiltedDown: return "arrow.up.circle.fill"
        case .noFaceDetected: return "person.fill.questionmark"
        }
    }

    var color: Color {
        status == .ready ? .green : .orange
    }

    var title: String {
        switch status {
        case .ready:          return "Great position!"
        case .phoneTooLow:    return "Phone is too low"
        case .headTiltedDown: return "Raise your chin"
        case .noFaceDetected: return "Hold still — looking for your face"
        }
    }

    var hint: String {
        switch status {
        case .ready:          return "Hold still — tap the button to save."
        case .phoneTooLow:    return "Raise the phone to chest or eye level."
        case .headTiltedDown: return "Look straight ahead, chin parallel to the floor."
        case .noFaceDetected: return "Make sure your face is visible in the camera."
        }
    }
}

// MARK: - UI card

private struct ValidationFeedbackCard: View {
    let validation: CalibrationValidation

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: validation.icon)
                .font(.system(size: 40))
                .foregroundStyle(validation.color)

            Text(validation.title)
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text(validation.hint)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
