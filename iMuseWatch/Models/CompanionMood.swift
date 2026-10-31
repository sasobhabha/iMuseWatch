import Foundation
import SwiftUI

public enum CompanionMood: String, CaseIterable, Codable, Sendable {
    case idle
    case thoughtful
    case cheerful
    case concerned
    case listening
    case speaking

    public var title: String {
        switch self {
        case .idle: return "Idle"
        case .thoughtful: return "Thoughtful"
        case .cheerful: return "Cheerful"
        case .concerned: return "Concerned"
        case .listening: return "Listening"
        case .speaking: return "Speaking"
        }
    }

    public var glowColor: Color {
        switch self {
        case .idle: return Color(red: 0.74, green: 0.88, blue: 0.77) // #ABD9C0
        case .thoughtful: return Color(red: 0.55, green: 0.75, blue: 0.95)
        case .cheerful: return Color(red: 0.95, green: 0.85, blue: 0.50)
        case .concerned: return Color(red: 0.95, green: 0.60, blue: 0.50)
        case .listening: return Color(red: 0.40, green: 0.85, blue: 0.75)
        case .speaking: return Color(red: 0.70, green: 0.90, blue: 0.70)
        }
    }
}
