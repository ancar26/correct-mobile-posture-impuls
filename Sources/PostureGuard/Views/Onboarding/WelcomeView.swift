import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(white: 0.06), Color(white: 0.12)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // App icon area
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 120, height: 120)
                    Image(systemName: "person.fill.checkmark")
                        .font(.system(size: 52))
                        .foregroundStyle(.green)
                }
                .padding(.bottom, 32)

                Text("PostureGuard")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("Protect your neck and cervical spine\nby correcting how you hold your phone.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.top, 12)
                    .padding(.horizontal, 32)

                Spacer()

                VStack(spacing: 12) {
                    FeatureRow(icon: "bell.badge", text: "Notifies you when your posture slips")
                    FeatureRow(icon: "iphone.radiowaves.left.and.right", text: "Works while you use other apps")
                    FeatureRow(icon: "moon.zzz", text: "Pauses automatically when phone is down")
                }
                .padding(.horizontal, 32)

                Spacer()

                Button(action: onContinue) {
                    Text("Get started")
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
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.green)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
        }
    }
}
