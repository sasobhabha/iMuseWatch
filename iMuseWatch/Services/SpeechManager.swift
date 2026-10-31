import Foundation
import AVFoundation

public final class SpeechManager: NSObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    public static let shared = SpeechManager()

    private let synthesizer = AVSpeechSynthesizer()
    public var onSpeakingChanged: (@Sendable (Bool) -> Void)?

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    public func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("Audio session configuration error: \(error)")
        }
    }

    public func speak(text: String, rate: Float = AVSpeechUtteranceDefaultSpeechRate, pitch: Float = 1.05) {
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

        configureAudioSession()
        synthesizer.speak(utterance)
    }

    public func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    public var isSpeaking: Bool {
        return synthesizer.isSpeaking
    }

    // MARK: - AVSpeechSynthesizerDelegate

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.onSpeakingChanged?(true)
        }
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.onSpeakingChanged?(false)
        }
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.onSpeakingChanged?(false)
        }
    }
}
