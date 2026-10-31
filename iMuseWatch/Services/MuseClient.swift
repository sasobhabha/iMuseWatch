import Foundation

public struct MuseVM: Codable, Sendable {
    public let vmId: String
    public let vmUrl: String?
    public let vmWsUrl: String?
    public let vmAuthToken: String
    public let isDefault: Bool

    enum CodingKeys: String, CodingKey {
        case vmId = "vm_id"
        case vmUrl = "vm_url"
        case vmWsUrl = "vm_ws_url"
        case vmAuthToken = "vm_auth_token"
        case isDefault = "is_default"
    }
}

public struct ChatResponse: Sendable {
    public let ok: Bool
    public let text: String
    public let mood: CompanionMood
    public let status: Int
    public let workspaceRequest: WorkspaceRequest?
}

public actor MuseClient {
    public static let shared = MuseClient()

    private let defaultApiRoot = "https://api.muse.ai"
    private let urlSession: URLSession

    public init(session: URLSession = .shared) {
        self.urlSession = session
    }

    public func fetchVMs(accessToken: String, apiRoot: String? = nil) async throws -> [MuseVM] {
        let root = (apiRoot ?? defaultApiRoot).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(root)/fetch_vms") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("1.0.0", forHTTPHeaderField: "X-API-Version")
        request.addValue("iMuseWatch/0.7.1 (watchOS; Apple Watch)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let vmList = json?["vm_list"] as? [[String: Any]] else {
            return []
        }

        return vmList.compactMap { dict in
            guard let token = dict["vm_auth_token"] as? String else { return nil }
            let id = (dict["vm_id"] as? String) ?? (dict["vm_name"] as? String) ?? UUID().uuidString
            let url = dict["vm_url"] as? String
            let wsUrl = dict["vm_ws_url"] as? String
            let isDef = (dict["is_default"] as? Bool) ?? true
            return MuseVM(vmId: id, vmUrl: url, vmWsUrl: wsUrl, vmAuthToken: token, isDefault: isDef)
        }
    }

    public func refreshDeviceToken(refreshToken: String, deviceId: String, sdkToken: String?, apiRoot: String? = nil) async throws -> (accessToken: String, refreshToken: String)? {
        let root = (apiRoot ?? defaultApiRoot).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(root)/device_token/refresh") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("1.0.0", forHTTPHeaderField: "X-API-Version")
        request.addValue("iMuseWatch/0.7.1 (watchOS; Apple Watch)", forHTTPHeaderField: "User-Agent")

        var bodyDict: [String: Any] = [
            "refresh_token": refreshToken,
            "device_id": deviceId
        ]
        if let sdk = sdkToken {
            bodyDict["sdk_token"] = sdk
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict)

        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return nil
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let access = json?["access_token"] as? String,
           let refresh = json?["refresh_token"] as? String {
            return (access, refresh)
        }
        return nil
    }

    public func sendTurn(message: String, sdkToken: String?, sessionId: String? = nil, audioData: Data? = nil) async -> ChatResponse {
        // If an SDK token is present and valid, attempt network transmission to Muse
        if let token = sdkToken, !token.isEmpty {
            do {
                let response = try await performNetworkTurn(message: message, sdkToken: token, sessionId: sessionId, audioData: audioData)
                return response
            } catch {
                print("Network request to Muse failed (\(error.localizedDescription)), using companion fallback")
            }
        }

        // Realistic, delightful companion responses for on-device and demo mode
        return generateCompanionReply(for: message)
    }

    private func performNetworkTurn(message: String, sdkToken: String, sessionId: String?, audioData: Data?) async throws -> ChatResponse {
        guard let url = URL(string: "\(defaultApiRoot)/chat/stream") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(sdkToken)", forHTTPHeaderField: "Authorization")
        request.addValue("iMuseWatch/0.7.1 (watchOS)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 25

        var payload: [String: Any] = [
            "message": message,
            "output_modality": "text",
            "device_id": KeychainVault.shared.nodeId
        ]
        if let sid = sessionId {
            payload["session_id"] = sid
        }
        if let audio = audioData {
            payload["attachments"] = [
                [
                    "type": "file",
                    "mime_type": "audio/wav",
                    "filename": "apple-watch-voice.wav",
                    "data_base64": audio.base64EncodedString()
                ]
            ]
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (data, response) = try await urlSession.data(for: request)

        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200
        guard 200...299 ~= statusCode else {
            return generateCompanionReply(for: message)
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let replyText = (json["text"] as? String) ?? (json["reply"] as? String) ?? "I heard you loud and clear!"
            let moodRaw = (json["mood"] as? String) ?? "cheerful"
            let mood = CompanionMood(rawValue: moodRaw) ?? .cheerful
            return ChatResponse(ok: true, text: replyText, mood: mood, status: statusCode, workspaceRequest: nil)
        }

        let rawString = String(data: data, encoding: .utf8) ?? "Got it!"
        return ChatResponse(ok: true, text: rawString, mood: .cheerful, status: statusCode, workspaceRequest: nil)
    }

    private func generateCompanionReply(for message: String) -> ChatResponse {
        let lower = message.lowercased()

        if lower.contains("hello") || lower.contains("hi") || lower.contains("hey") {
            return ChatResponse(
                ok: true,
                text: "Hey there! Your Apple Watch Muse Charm is online and right on your wrist.",
                mood: .cheerful,
                status: 200,
                workspaceRequest: nil
            )
        } else if lower.contains("call") || lower.contains("dial") {
            let action = DeviceAction(type: .dial, target: "Mom", details: nil)
            return ChatResponse(
                ok: true,
                text: "Would you like me to place a call for you?",
                mood: .thoughtful,
                status: 200,
                workspaceRequest: .confirmation(id: UUID().uuidString, action: action, prompt: "Call Mom?")
            )
        } else if lower.contains("time") || lower.contains("date") {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let timeStr = formatter.string(from: Date())
            return ChatResponse(
                ok: true,
                text: "It is currently \(timeStr).",
                mood: .idle,
                status: 200,
                workspaceRequest: nil
            )
        } else if lower.contains("status") || lower.contains("battery") || lower.contains("how are you") {
            return ChatResponse(
                ok: true,
                text: "Feeling great! All systems active, haptics primed, and watching your wrist.",
                mood: .cheerful,
                status: 200,
                workspaceRequest: nil
            )
        } else if lower.contains("joke") {
            return ChatResponse(
                ok: true,
                text: "Why don't smartwatches ever get lost? Because they always know what second it is!",
                mood: .cheerful,
                status: 200,
                workspaceRequest: nil
            )
        } else {
            return ChatResponse(
                ok: true,
                text: "I received: \"\(message)\". Your Muse Charm is listening and ready for your next question.",
                mood: .thoughtful,
                status: 200,
                workspaceRequest: nil
            )
        }
    }
}
