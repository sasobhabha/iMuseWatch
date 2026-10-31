import Foundation

public struct MuseMessage: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let text: String
    public let isUser: Bool
    public let timestamp: Date
    public let mood: CompanionMood

    public init(id: String = UUID().uuidString, text: String, isUser: Bool, timestamp: Date = Date(), mood: CompanionMood = .idle) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
        self.mood = mood
    }
}

public struct GlanceableNotification: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let text: String
    public let mood: CompanionMood
    public let timestamp: Date
    public var unread: Bool

    public init(id: String = UUID().uuidString, title: String, text: String, mood: CompanionMood = .cheerful, timestamp: Date = Date(), unread: Bool = true) {
        self.id = id
        self.title = title
        self.text = text
        self.mood = mood
        self.timestamp = timestamp
        self.unread = unread
    }
}
