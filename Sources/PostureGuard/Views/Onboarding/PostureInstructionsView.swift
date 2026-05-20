import SwiftUI

struct PostureInstructionsView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("How to hold your phone")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text("This is the position we'll use as your baseline.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 52)
                .padding(.horizontal, 24)

                Spacer()

                // Illustration: side-by-side correct vs wrong
                HStack(spacing: 20) {
                    PostureCard(
                        isCorrect: false,
                        personIcon: "figure.stand",
                        phoneOffset: CGSize(width: 0, height: 60),
                        phoneRotation: -40,
                        label: "Wrong",
                        description: "Phone at waist,\nhead bent down",
                        color: .red
                    )

                    PostureCard(
                        isCorrect: true,
                        personIcon: "figure.stand",
                        phoneOffset: CGSize(width: 28, height: -10),
                        phoneRotation: 0,
                        label: "Correct",
                        description: "Phone near eye level,\nhead upright",
                        color: .green
                    )
                }
                .padding(.horizontal, 24)

                Spacer()

                // Tips
                VStack(alignment: .leading, spacing: 14) {
                    TipRow(number: "1", text: "Hold your phone about arm's length away")
                    TipRow(number: "2", text: "Raise it toward eye or chest level — not the waist")
                    TipRow(number: "3", text: "Keep your chin parallel to the floor, not tucked")
                    TipRow(number: "4", text: "Relax your shoulders — don't hunch")
                }
                .padding(.horizontal, 28)

                Spacer()

                Button(action: onContinue) {
                    Text("I'm ready — set my baseline")
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

// MARK: - Posture card illustration

private struct PostureCard: View {
    let isCorrect: Bool
    let personIcon: String
    let phoneOffset: CGSize
    let phoneRotation: Double
    let label: String
    let description: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(color.opacity(0.3), lineWidth: 1)
                    )
                    .frame(height: 160)

                ZStack(alignment: .center) {
                    // Person
                    Image(systemName: personIcon)
                        .font(.system(size: 64))
                        .foregroundStyle(.white.opacity(0.85))

                    // Phone overlay
                    Image(systemName: "iphone")
                        .font(.system(size: 22))
                        .foregroundStyle(color)
                        .rotationEffect(.degrees(phoneRotation))
                        .offset(phoneOffset)
                }
            }

            HStack(spacing: 4) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(color)
                Text(label)
                    .font(.subheadline.bold())
                    .foregroundStyle(color)
            }

            Text(description)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.55))
        }
    }
}

private struct TipRow: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption.bold())
                .foregroundStyle(.green)
                .frame(width: 20, height: 20)
                .background(Color.green.opacity(0.15), in: Circle())
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
            Spacer()
        }
    }
}
