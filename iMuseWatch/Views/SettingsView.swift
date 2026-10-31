import SwiftUI

public struct SettingsView: View {
    @ObservedObject var runtime: MuseRuntime
    @State private var showingTokenEntry = false
    @State private var tokenInput = ""
    @State private var tokenStatusMessage = ""
    @Environment(\.dismiss) private var dismiss

    public init(runtime: MuseRuntime) {
        self.runtime = runtime
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                    .font(.footnote)
                    .foregroundColor(Color(red: 0.74, green: 0.88, blue: 0.77))
                }

                // Status Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("STATUS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)

                    HStack {
                        Circle()
                            .fill(runtime.connection.isOnline ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(runtime.connection.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Text("Node: \(KeychainVault.shared.nodeId)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(white: 0.12))
                .cornerRadius(10)

                // Token Section
                VStack(alignment: .leading, spacing: 6) {
                    Text("MUSE SDK TOKEN")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)

                    if let token = runtime.getSdkToken(), !token.isEmpty {
                        Text("Configured (mgst_••••\(token.suffix(4)))")
                            .font(.system(size: 11))
                            .foregroundColor(.green)
                    } else {
                        Text("No personal token set (using on-device companion mode)")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }

                    Button("Edit SDK Token") {
                        tokenInput = runtime.getSdkToken() ?? ""
                        showingTokenEntry = true
                    }
                    .font(.caption2)
                    .tint(.blue)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(white: 0.12))
                .cornerRadius(10)

                // Audio & Voice
                VStack(alignment: .leading, spacing: 8) {
                    Text("VOICE & AUDIO")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)

                    Toggle("Read Replies Aloud", isOn: $runtime.autoRead)
                        .font(.system(size: 11))

                    HStack {
                        Text("Voice Speed")
                            .font(.system(size: 11))
                        Spacer()
                        Text("\(Int(runtime.speechRate * 200))%")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.gray)
                    }

                    Slider(value: $runtime.speechRate, in: 0.3...0.7, step: 0.05)
                        .tint(Color(red: 0.74, green: 0.88, blue: 0.77))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(white: 0.12))
                .cornerRadius(10)

                // Visuals
                VStack(alignment: .leading, spacing: 8) {
                    Text("DISPLAY")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)

                    Toggle("Show Captions", isOn: $runtime.showCaptions)
                        .font(.system(size: 11))

                    Toggle("Show Notifications", isOn: $runtime.showNotifications)
                        .font(.system(size: 11))

                    Picker("Avatar Style", selection: $runtime.avatarStyle) {
                        ForEach(AvatarStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .font(.system(size: 11))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(white: 0.12))
                .cornerRadius(10)

                // Unpair / Reset
                Button(role: .destructive) {
                    runtime.clearCredentials()
                    runtime.onboardingDone = false
                    dismiss()
                } label: {
                    Text("Clear Credentials & Reset")
                        .font(.system(size: 11))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 6)
        }
        .sheet(isPresented: $showingTokenEntry) {
            VStack(spacing: 12) {
                Text("Enter SDK Token")
                    .font(.headline)

                TextField("mgst_...", text: $tokenInput)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .font(.system(size: 10, design: .monospaced))

                if !tokenStatusMessage.isEmpty {
                    Text(tokenStatusMessage)
                        .font(.caption2)
                        .foregroundColor(.red)
                }

                HStack {
                    Button("Cancel") {
                        showingTokenEntry = false
                    }
                    .tint(.gray)

                    Button("Save") {
                        if KeychainVault.validateSdkToken(tokenInput) {
                            _ = runtime.saveSdkToken(tokenInput)
                            showingTokenEntry = false
                        } else {
                            tokenStatusMessage = "Invalid token format. Must start with mgst_ followed by 43 characters."
                        }
                    }
                    .tint(Color(red: 0.74, green: 0.88, blue: 0.77))
                }
            }
            .padding()
        }
    }
}
