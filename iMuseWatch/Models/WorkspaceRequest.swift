import Foundation

public enum DeviceActionType: String, Codable, Sendable {
    case dial
    case message
    case navigate
    case calendar
    case camera
    case openApp
}

public struct DeviceAction: Codable, Sendable, Equatable {
    public let type: DeviceActionType
    public let target: String?
    public let details: String?

    public init(type: DeviceActionType, target: String? = nil, details: String? = nil) {
        self.type = type
        self.target = target
        self.details = details
    }

    public var summary: String {
        switch type {
        case .dial:
            return target != nil ? "Call \(target!)" : "Open phone dialer"
        case .message:
            return target != nil ? "Text \(target!): \"\(details ?? "")\"" : "Compose message"
        case .navigate:
            return "Directions to \(target ?? "destination")"
        case .calendar:
            return "Event: \(details ?? target ?? "New Event")"
        case .camera:
            return "Take photo"
        case .openApp:
            return "Open \(target ?? "App")"
        }
    }
}

public enum WorkspaceRequest: Identifiable, Sendable, Equatable {
    case contentCard(id: String, title: String, text: String)
    case confirmation(id: String, action: DeviceAction, prompt: String)
    case question(id: String, prompt: String)
    case taskStatus(id: String, text: String)

    public var id: String {
        switch self {
        case .contentCard(let id, _, _): return id
        case .confirmation(let id, _, _): return id
        case .question(let id, _): return id
        case .taskStatus(let id, _): return id
        }
    }

    public var readableText: String {
        switch self {
        case .contentCard(_, _, let text): return text
        case .confirmation(_, let action, let prompt): return "\(prompt)\n\(action.summary)"
        case .question(_, let prompt): return prompt
        case .taskStatus(_, let text): return text
        }
    }
}
