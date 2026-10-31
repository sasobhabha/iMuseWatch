import Foundation
import WatchKit

public final class HapticManager: @unchecked Sendable {
    public static let shared = HapticManager()

    public func playTap() {
        WKInterfaceDevice.current().play(.click)
    }

    public func playStartRecording() {
        WKInterfaceDevice.current().play(.start)
    }

    public func playStopRecording() {
        WKInterfaceDevice.current().play(.stop)
    }

    public func playReplyReceived() {
        WKInterfaceDevice.current().play(.notification)
    }

    public func playSuccess() {
        WKInterfaceDevice.current().play(.success)
    }

    public func playFailure() {
        WKInterfaceDevice.current().play(.failure)
    }
}
