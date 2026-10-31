import SwiftUI

public struct CaptionsOverlayView: View {
    let text: String
    let isSpeaking: Bool
    let onTap: () -> Void

    public init(text: String, isSpeaking: Bool = false, onTap: @escaping () -> Void = {}) {
        self.text = text
        self.isSpeaking = isSpeaking
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if isSpeaking {
                    Image(systemName: "waveform")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(red: 0.74, green: 0.88, blue: 0.77))
                }

                Text(text)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(Color(white: 0.12, opacity: 0.88))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
