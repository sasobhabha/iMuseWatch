import SwiftUI

public struct AvatarView: View {
    @ObservedObject var runtime: MuseRuntime
    @State private var isBlinking = false
    @State private var bobPhase = false
    @State private var pulseRing = false

    public init(runtime: MuseRuntime) {
        self.runtime = runtime
    }

    public var body: some View {
        ZStack {
            // Audio Listening Pulse Ring
            if runtime.isRecording {
                Circle()
                    .stroke(runtime.mood.glowColor.opacity(0.45), lineWidth: 3)
                    .scaleEffect(pulseRing ? 1.25 : 0.95)
                    .opacity(pulseRing ? 0.2 : 0.8)
                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulseRing)
                    .onAppear { pulseRing = true }
                    .onDisappear { pulseRing = false }
            }

            // Glow backing
            Circle()
                .fill(
                    RadialGradient(
                        colors: [runtime.mood.glowColor.opacity(0.35), Color.clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 75
                    )
                )
                .scaleEffect(runtime.isRecording ? 1.15 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: runtime.isRecording)

            // Companion Face
            Group {
                if runtime.avatarStyle == .jolly {
                    Image("jolly_avatar", bundle: .main)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                } else {
                    VectorCompanionBody(
                        mood: runtime.mood,
                        isBlinking: isBlinking,
                        isSpeaking: runtime.isSpeaking,
                        isListening: runtime.isRecording
                    )
                    .frame(width: 118, height: 118)
                }
            }
            .offset(y: bobPhase ? -3.5 : 2.5)
            .animation(
                .easeInOut(duration: runtime.isSpeaking ? 0.35 : 1.8)
                .repeatForever(autoreverses: true),
                value: bobPhase
            )
        }
        .contentShape(Circle())
        .onTapGesture {
            runtime.toggleVoice()
        }
        .onLongPressGesture(minimumDuration: 0.25, pressing: { pressing in
            if pressing && !runtime.isRecording {
                runtime.startVoice()
            } else if !pressing && runtime.isRecording {
                runtime.endVoice()
            }
        }, perform: {})
        .onAppear {
            bobPhase = true
            startBlinkLoop()
        }
    }

    private func startBlinkLoop() {
        Timer.scheduledTimer(withTimeInterval: 3.8, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.12)) {
                isBlinking = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeInOut(duration: 0.12)) {
                    isBlinking = false
                }
            }
        }
    }
}

// MARK: - Vector Companion Face & Body

private struct VectorCompanionBody: View {
    let mood: CompanionMood
    let isBlinking: Bool
    let isSpeaking: Bool
    let isListening: Bool

    var body: some View {
        Canvas { context, size in
            let scale = min(size.width, size.height) / 128.0
            context.scaleBy(x: scale, y: scale)

            // Ground / Shadow (#233A36)
            let shadowRect = CGRect(x: 31, y: 108, width: 66, height: 9)
            context.fill(Path(ellipseIn: shadowRect), with: .color(Color(hex: 0x233A36)))

            // Antenna Base & Tip (#ABD9C0)
            let antennaStem = Path(roundedRect: CGRect(x: 58, y: 18, width: 12, height: 22), cornerRadius: 6)
            context.fill(antennaStem, with: .color(Color(hex: 0xABD9C0)))
            let antennaBall = Path(ellipseIn: CGRect(x: 57, y: 10, width: 14, height: 14))
            context.fill(antennaBall, with: .color(Color(hex: 0xABD9C0)))

            // Main Head Body (#F2D4A9)
            let headRect = CGRect(x: 22, y: 35, width: 84, height: 71)
            let headPath = Path(roundedRect: headRect, cornerRadius: 28)
            context.fill(headPath, with: .color(Color(hex: 0xF2D4A9)))

            // Left Ear (#DBB88C)
            let leftEar = Path(roundedRect: CGRect(x: 13, y: 66, width: 13, height: 19), cornerRadius: 6)
            context.fill(leftEar, with: .color(Color(hex: 0xDBB88C)))

            // Right Ear (#DBB88C)
            let rightEar = Path(roundedRect: CGRect(x: 102, y: 66, width: 13, height: 19), cornerRadius: 6)
            context.fill(rightEar, with: .color(Color(hex: 0xDBB88C)))

            // Eyes (#142923)
            let eyeHeight: CGFloat = isBlinking ? 2.0 : 10.0
            let eyeY: CGFloat = isBlinking ? 66.0 : 62.0
            let leftEye = Path(roundedRect: CGRect(x: 43, y: eyeY, width: 7, height: eyeHeight), cornerRadius: 3.5)
            let rightEye = Path(roundedRect: CGRect(x: 78, y: eyeY, width: 7, height: eyeHeight), cornerRadius: 3.5)
            context.fill(leftEye, with: .color(Color(hex: 0x142923)))
            context.fill(rightEye, with: .color(Color(hex: 0x142923)))

            // Mouth
            if isListening || isSpeaking {
                let mouthCircle = Path(ellipseIn: CGRect(x: 60, y: 80, width: 8, height: 8))
                context.fill(mouthCircle, with: .color(Color(hex: 0x142923)))
            } else {
                // Happy Arc Smile
                var smile = Path()
                smile.addArc(
                    center: CGPoint(x: 64, y: 78),
                    radius: 7,
                    startAngle: .degrees(25),
                    endAngle: .degrees(155),
                    clockwise: false
                )
                context.stroke(smile, with: .color(Color(hex: 0x142923)), lineWidth: 2.8)
            }

            // Cheeks Blushing (#EDB39C)
            let leftCheek = Path(ellipseIn: CGRect(x: 33, y: 76, width: 11, height: 6))
            let rightCheek = Path(ellipseIn: CGRect(x: 84, y: 76, width: 11, height: 6))
            context.fill(leftCheek, with: .color(Color(hex: 0xEDB39C)))
            context.fill(rightCheek, with: .color(Color(hex: 0xEDB39C)))
        }
    }
}

// Color Hex Extension
private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
