import SwiftUI

public struct ContentView: View {
    @StateObject private var runtime = MuseRuntime.shared
    @State private var showingSettings = false
    @State private var showingTranscript = false
    @State private var crownScale: Double = 1.0

    public init() {}

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if !runtime.onboardingDone {
                SetupView(runtime: runtime)
            } else {
                VStack(spacing: 0) {
                    // Top Bar
                    topBar

                    Spacer(minLength: 2)

                    // Notifications Card if any
                    if runtime.showNotifications, let firstNote = runtime.notifications.first, !runtime.isRecording {
                        NotificationsView(notification: firstNote) {
                            runtime.dismissNotification(id: firstNote.id)
                        }
                        .padding(.horizontal, 6)
                        .padding(.bottom, 2)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Main Avatar Centerpiece
                    ZStack {
                        AvatarView(runtime: runtime)
                            .scaleEffect(crownScale)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .focusable()
                    .digitalCrownRotation(
                        $crownScale,
                        from: 0.85,
                        through: 1.15,
                        by: 0.05,
                        sensitivity: .low,
                        isContinuous: false,
                        isHapticFeedbackEnabled: true
                    )

                    Spacer(minLength: 2)

                    // Caption Subtitle Pill
                    if (runtime.showCaptions || runtime.isRecording || runtime.isSpeaking),
                       let caption = runtime.currentCaption, !caption.isEmpty {
                        CaptionsOverlayView(text: caption, isSpeaking: runtime.isSpeaking) {
                            showingTranscript = true
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 4)
                        .transition(.opacity)
                    } else if runtime.status != .ready && runtime.status != .resting {
                        Text(runtime.status.displayLabel)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.45))
                            .padding(.bottom, 4)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(runtime: runtime)
        }
        .sheet(isPresented: $showingTranscript) {
            TranscriptView(runtime: runtime)
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.35))
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: {
                showingTranscript = true
            }) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(runtime.connection.isOnline ? Color.green.opacity(0.7) : Color.orange)
                        .frame(width: 5, height: 5)

                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.35))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.top, 2)
    }
}
