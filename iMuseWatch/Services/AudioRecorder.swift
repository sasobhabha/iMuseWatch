import Foundation
import AVFoundation

public final class AudioRecorder: NSObject, AVAudioRecorderDelegate, @unchecked Sendable {
    public static let shared = AudioRecorder()

    private var audioRecorder: AVAudioRecorder?
    private var currentRecordingURL: URL?

    private override init() {
        super.init()
    }

    public func requestPermissions(completion: @escaping @Sendable (Bool) -> Void) {
        if #available(watchOS 10.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                completion(granted)
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                completion(granted)
            }
        }
    }

    public func startRecording() throws {
        stopRecording()

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.duckOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("muse_voice_\(UUID().uuidString).wav")
        currentRecordingURL = fileURL

        // 16kHz 16-bit mono PCM matching Muse Gadget WAV specification
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]

        audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.record()
    }

    @discardableResult
    public func stopRecording() -> URL? {
        audioRecorder?.stop()
        audioRecorder = nil
        return currentRecordingURL
    }

    public var isRecording: Bool {
        return audioRecorder?.isRecording == true
    }

    public func audioMeterLevel() -> Float {
        guard let recorder = audioRecorder, recorder.isRecording else { return 0.0 }
        recorder.updateMeters()
        let average = recorder.averagePower(forChannel: 0)
        return max(0.0, min(1.0, (average + 60.0) / 60.0))
    }
}
