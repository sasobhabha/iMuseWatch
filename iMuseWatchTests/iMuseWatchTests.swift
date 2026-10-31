import XCTest
@testable import iMuseWatch

final class iMuseWatchTests: XCTestCase {

    func testSdkTokenValidation() {
        // Must start with mgst_ followed by 42 chars [A-Za-z0-9_-] and end with [AEIMQUYcgkosw048] = 48 chars total
        let validToken = "mgst_123456789012345678901234567890123456789012A"
        XCTAssertTrue(KeychainVault.validateSdkToken(validToken))

        let invalidPrefix = "invalid_123456789012345678901234567890123456789012A"
        XCTAssertFalse(KeychainVault.validateSdkToken(invalidPrefix))

        let tooShort = "mgst_12345"
        XCTAssertFalse(KeychainVault.validateSdkToken(tooShort))

        let empty = ""
        XCTAssertFalse(KeychainVault.validateSdkToken(empty))
    }

    func testApplianceStatusIsBusy() {
        XCTAssertTrue(ApplianceStatus.listening.isBusy)
        XCTAssertTrue(ApplianceStatus.thinking.isBusy)
        XCTAssertTrue(ApplianceStatus.speaking.isBusy)
        XCTAssertFalse(ApplianceStatus.ready.isBusy)
        XCTAssertFalse(ApplianceStatus.resting.isBusy)
    }

    func testDeviceActionSummary() {
        let dialAction = DeviceAction(type: .dial, target: "Alice")
        XCTAssertEqual(dialAction.summary, "Call Alice")

        let messageAction = DeviceAction(type: .message, target: "Bob", details: "Running late")
        XCTAssertEqual(messageAction.summary, "Text Bob: \"Running late\"")

        let navAction = DeviceAction(type: .navigate, target: "Coffee Shop")
        XCTAssertEqual(navAction.summary, "Directions to Coffee Shop")
    }

    func testCompanionReplyGeneration() async {
        let client = MuseClient()

        let helloReply = await client.sendTurn(message: "Hello there!", sdkToken: nil)
        XCTAssertTrue(helloReply.ok)
        XCTAssertEqual(helloReply.mood, .cheerful)
        XCTAssertTrue(helloReply.text.contains("online") || helloReply.text.contains("wrist"))

        let jokeReply = await client.sendTurn(message: "Tell me a joke", sdkToken: nil)
        XCTAssertTrue(jokeReply.ok)
        XCTAssertEqual(jokeReply.mood, .cheerful)
        XCTAssertTrue(jokeReply.text.contains("smartwatches"))

        let dialReply = await client.sendTurn(message: "Please call Mom", sdkToken: nil)
        XCTAssertTrue(dialReply.ok)
        XCTAssertNotNil(dialReply.workspaceRequest)
    }

    func testPseudoMacGeneration() {
        let vault = KeychainVault.shared
        let mac = vault.macAddress
        XCTAssertEqual(mac.split(separator: ":").count, 6)
        XCTAssertTrue(vault.nodeId.starts(with: "homelink-"))
        XCTAssertTrue(vault.deviceId.starts(with: "hatch-link:"))
    }
}
