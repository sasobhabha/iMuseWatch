import Foundation

public enum ApplianceStatus: String, CaseIterable, Codable, Sendable {
    case resting = "Resting"
    case ready = "Ready"
    case listening = "Listening"
    case uploading = "Uploading"
    case thinking = "Thinking"
    case replying = "Replying"
    case speaking = "Speaking"
    case blocked = "Blocked"
    case error = "Error"

    public var isBusy: BooleanLiteralType {
        switch self {
        case .listening, .uploading, .thinking, .replying, .speaking:
            return true
        default:
            return false
        }
    }

    public var displayLabel: String {
        switch self {
        case .resting: return "Resting"
        case .ready: return "Ready"
        case .listening: return "Listening..."
        case .uploading: return "Sending..."
        case .thinking: return "Thinking..."
        case .replying: return "Reply ready"
        case .speaking: return "Speaking"
        case .blocked: return "Offline"
        case .error: return "Failed"
        }
    }
}

public enum ConnectionStatus: String, Codable, Sendable {
    case disconnected = "Disconnected"
    case connecting = "Connecting"
    case connected = "Connected"
    case paired = "Paired"
    case blocked = "Blocked"

    public var isOnline: Bool {
        return self == .connected || self == .paired
    }
}
