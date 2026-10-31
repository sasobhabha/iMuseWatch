import Foundation
import SwiftUI
import Combine

public enum AvatarStyle: String, CaseIterable, Codable, Sendable {
    case vector = "Vector Pet"
    case jolly = "Jolly Avatar"
}

@MainActor
public final class MuseRuntime: ObservableObject {
    public static let shared = MuseRuntime()

    @Published public var status: ApplianceStatus = .ready
    @Published public var connection: ConnectionStatus = .connected
    @Published public var mood: CompanionMood = .idle
    @Published public var messages: [MuseMessage] = []
    @Published public var notifications: [GlanceableNotification] = []
    @Published public var currentCaption: String? = nil
    @Published public var isSpeaking: Bool = false
    @Published public var isRecording: Bool = false
    @Published public var pendingRequest: WorkspaceRequest? = nil

    // User Preferences (saved in UserDefaults)
    @AppStorage("show_captions") public var showCaptions: Bool = true
    @AppStorage("show_notifications") public var showNotifications: Bool = true
    @AppStorage("auto_read") public var autoRead: Bool = true
    @AppStorage("avatar_style") public var avatarStyle: AvatarStyle = .vector
    @AppStorage("speech_rate") public var speechRate: Double = 0.5
    @AppStorage("speech_pitch") public var speechPitch: Double = 1.05
    @AppStorage("onboarding_done") public var onboardingDone: Bool = false

    private let vault = KeychainVault.shared
    private let speech = SpeechManager.shared
    private let recorder = AudioRecorder.shared
    private let haptics = HapticManager.shared
    private let client = MuseClient.shared

    public init() {
        setupSpeechObservation()
        loadInitialMessages()
    }

    private func setupSpeechObservation() {
        speech.onSpeakingChanged = { [weak self] speaking in
            Task { @MainActor in
                self?.isSpeaking = speaking
                if speaking {
                    self?.status = .speaking
                } else if self?.status == .speaking {
                    self?.status = .ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        if self?.isSpeaking == false {
                            self?.currentCaption = nil
                        }
                    }
                }
            }
        }
    }

    private func loadInitialMessages() {
        if messages.isEmpty {
            messages.append(MuseMessage(
                text: "Hello! Tap or hold my face to talk to me. I'm right here on your Apple Watch.",
                isUser: false,
                mood: .cheerful
            ))
        }
    }

    // MARK: - Voice Interaction

    public func toggleVoice() {
        if isRecording {
            endVoice()
        } else {
            startVoice()
        }
    }

    public func startVoice() {
        guard !isRecording else { return }
        speech.stop()
        isRecording = true
        status = .listening
        mood = .listening
        currentCaption = "Listening..."
        haptics.playStartRecording()

        recorder.requestPermissions { [weak self] granted in
            guard granted else {
                Task { @MainActor in
                    self?.status = .error
                    self?.currentCaption = "Microphone permission required."
                    self?.isRecording = false
                    self?.haptics.playFailure()
                }
                return
            }

            do {
                try self?.recorder.startRecording()
            } catch {
                Task { @MainActor in
                    self?.status = .error
                    self?.currentCaption = "Could not record audio."
                    self?.isRecording = false
                    self?.haptics.playFailure()
                }
            }
        }
    }

    public func endVoice() {
        guard isRecording else { return }
        isRecording = false
        haptics.playStopRecording()

        let url = recorder.stopRecording()
        status = .thinking
        mood = .thoughtful
        currentCaption = "Sending audio to Muse..."

        var audioData: Data? = nil
        if let fileURL = url, let data = try? Data(contentsOf: fileURL) {
            audioData = data
            try? FileManager.default.removeItem(at: fileURL)
        }

        Task {
            await sendMessage(text: "Voice message", audioData: audioData)
        }
    }

    public func cancelVoice() {
        guard isRecording else { return }
        isRecording = false
        _ = recorder.stopRecording()
        status = .ready
        mood = .idle
        currentCaption = nil
        haptics.playTap()
    }

    // MARK: - Message Dispatch

    public func sendMessage(text: String, audioData: Data? = nil) async {
        let userMessage = MuseMessage(text: text, isUser: true, mood: .idle)
        messages.append(userMessage)

        status = .thinking
        mood = .thoughtful
        currentCaption = "Thinking..."

        let sdkToken = vault.readString(for: "sdk_token")
        let response = await client.sendTurn(message: text, sdkToken: sdkToken, audioData: audioData)

        haptics.playReplyReceived()
        status = .replying
        mood = response.mood
        currentCaption = response.text

        let museMessage = MuseMessage(text: response.text, isUser: false, mood: response.mood)
        messages.append(museMessage)

        if let req = response.workspaceRequest {
            pendingRequest = req
        }

        if autoRead {
            speech.speak(text: response.text, rate: Float(speechRate), pitch: Float(speechPitch))
        } else {
            status = .ready
        }
    }

    // MARK: - Notifications

    public func pushNotification(title: String, text: String, mood: CompanionMood = .cheerful) {
        let note = GlanceableNotification(title: title, text: text, mood: mood)
        notifications.insert(note, at: 0)
        haptics.playReplyReceived()
    }

    public func dismissNotification(id: String) {
        notifications.removeAll { $0.id == id }
        haptics.playTap()
    }

    // MARK: - Settings & Pairing

    public func saveSdkToken(_ token: String) -> Bool {
        let clean = token.trimmingCharacters(in: .whitespacesAndNewlines)
        vault.save(string: clean, for: "sdk_token")
        onboardingDone = true
        connection = .connected
        haptics.playSuccess()
        return true
    }

    public func getSdkToken() -> String? {
        return vault.readString(for: "sdk_token")
    }

    public func clearCredentials() {
        vault.remove(key: "sdk_token")
        vault.remove(key: "access_token")
        vault.remove(key: "refresh_token")
        connection = .disconnected
        haptics.playTap()
    }
}
