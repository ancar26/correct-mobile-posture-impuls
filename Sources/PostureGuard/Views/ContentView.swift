import SwiftUI

struct ContentView: View {
    @StateObject private var detector = PostureDetectionManager()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("onboarding.completed") private var onboardingCompleted = false

    var body: some View {
        ZStack {
            MonitoringScreen(detector: detector)

            // Show onboarding only on first launch (or after reset)
            if !onboardingCompleted || detector.status == .uncalibrated {
                OnboardingView(
                    detector: detector,
                    onComplete: {
                        withAnimation { onboardingCompleted = true }
                    },
                    onCalibrate: {
                        detector.calibrate()
                    }
                )
                .transition(.opacity)
                .zIndex(2)
            }

            if detector.status == .bad {
                PostureAlertOverlay {
                    withAnimation(.easeOut(duration: 0.25)) {
                        detector.acknowledgeAlert()
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: detector.status)
        .animation(.easeInOut(duration: 0.35), value: onboardingCompleted)
        .onAppear {
            detector.start()
            NotificationManager.shared.requestPermission()
        }
        .onDisappear { detector.stop() }
        .onChange(of: detector.status) { _, newStatus in
            // Only send notification for bad posture while using another app
            // Never send when idle (phone on table)
            if newStatus == .bad, scenePhase == .background {
                NotificationManager.shared.sendPostureAlert()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Monitoring screen

private struct MonitoringScreen: View {
    @ObservedObject var detector: PostureDetectionManager

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("PostureGuard")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    Button(action: { detector.resetCalibration() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(statusColor.opacity(0.12))
                            .frame(width: 140, height: 140)
                        Circle()
                            .strokeBorder(statusColor.opacity(0.35), lineWidth: 2)
                            .frame(width: 140, height: 140)
                        Image(systemName: statusIcon)
                            .font(.system(size: 56))
                            .foregroundStyle(statusColor)
                    }
                    .animation(.easeInOut(duration: 0.4), value: detector.status)

                    Text(statusTitle)
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text(statusSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                if detector.status == .warning {
                    WarningBanner(secondsLeft: Int(detector.alertThreshold - detector.badPostureDuration))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 8)
                }

                // Only show camera note when actively monitoring
                if detector.status == .good || detector.status == .warning {
                    Text("Camera active for detection")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.2))
                        .padding(.bottom, 32)
                } else {
                    Spacer().frame(height: 32)
                }
            }
        }
    }

    private var statusColor: Color {
        switch detector.status {
        case .uncalibrated, .calibrating: .gray
        case .good:          .green
        case .warning:       .yellow
        case .bad:           .red
        case .idle:          .gray
        case .justPickedUp:  .blue
        }
    }

    private var statusIcon: String {
        switch detector.status {
        case .uncalibrated, .calibrating: "questionmark"
        case .good:          "checkmark"
        case .warning:       "exclamationmark"
        case .bad:           "xmark"
        case .idle:          "moon.zzz"
        case .justPickedUp:  "hand.raised"
        }
    }

    private var statusTitle: String {
        switch detector.status {
        case .uncalibrated, .calibrating: "Setting up…"
        case .good:          "Good posture"
        case .warning:       String(format: "Watch out — %.0fs", detector.badPostureDuration)
        case .bad:           "Fix your posture!"
        case .idle:          "Good posture"
        case .justPickedUp:  "Detecting…"
        }
    }

    private var statusSubtitle: String {
        switch detector.status {
        case .uncalibrated, .calibrating: ""
        case .good, .idle:   "Monitoring active.\nYou can switch to another app."
        case .warning:       "Raise your phone to eye level\nbefore the alert fires."
        case .bad:           "Lift the phone and relax your neck."
        case .justPickedUp:  "Detecting your position…"
        }
    }
}

private struct WarningBanner: View {
    let secondsLeft: Int

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.up.to.line")
                .font(.headline)
            Text("Raise your phone — alert in \(max(secondsLeft, 0))s")
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.yellow, in: Capsule())
    }
}
