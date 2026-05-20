import SwiftUI

struct CalibrationDoneView: View {
    let onDone: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 130, height: 130)
                        .scaleEffect(appeared ? 1 : 0.5)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.green)
                        .scaleEffect(appeared ? 1 : 0.3)
                }

                VStack(spacing: 10) {
                    Text("You're all set!")
                        .font(.title.bold())
                        .foregroundStyle(.white)

                    Text("Your baseline is saved. You can close\nthis app and use your phone normally —\nPostureGuard runs quietly in the background.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.65))
                }

                Spacer()

                VStack(spacing: 10) {
                    InfoRow(icon: "bell.badge.fill", text: "Notification sent after 12s of bad posture")
                    InfoRow(icon: "hand.raised.fill", text: "Only monitors when you're actively holding the phone")
                    InfoRow(icon: "arrow.counterclockwise", text: "Open the app and tap ↺ to recalibrate anytime")
                }
                .padding(.horizontal, 28)

                Spacer()

                Button(action: onDone) {
                    Text("Got it — close onboarding")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                appeared = true
            }
        }
    }
}

private struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(.green)
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
        }
    }
}
