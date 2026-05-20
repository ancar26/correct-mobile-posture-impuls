import SwiftUI

struct PostureAlertOverlay: View {
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.85

    var body: some View {
        ZStack {
            Color.black.opacity(0.78)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.yellow)
                    .symbolEffect(.pulse)

                VStack(spacing: 10) {
                    Text("Lift your phone")
                        .font(.title.bold())
                        .foregroundStyle(.white)

                    Text("Hold the phone closer to eye level.\nRelax your neck and uncurl your chin.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.8))
                }

                Button(action: onDismiss) {
                    Text("Got it — I'll fix it")
                        .font(.headline)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 14)
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            }
            .padding(32)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    scale = 1.0
                }
            }
        }
    }
}
