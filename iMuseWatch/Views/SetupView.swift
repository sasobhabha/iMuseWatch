import SwiftUI

public struct SetupView: View {
    @ObservedObject var runtime: MuseRuntime
    @State private var sdkToken: String = ""
    @State private var showingTokenField = false
    @State private var errorMessage = ""

    public init(runtime: MuseRuntime) {
        self.runtime = runtime
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Header Mascot
                ZStack {
                    Circle()
                        .fill(Color(red: 0.74, green: 0.88, blue: 0.77).opacity(0.2))
                        .frame(width: 64, height: 64)

                    Image(systemName: "sparkles")
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: 0.74, green: 0.88, blue: 0.77))
                }
                .padding(.top, 6)

                Text("Welcome to iMuseWatch")
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                Text("Your dedicated standalone AI companion, right on your Apple Watch.")
                    .font(.system(size: 11))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(Color(red: 0.74, green: 0.88, blue: 0.77))
                            .font(.system(size: 11))
                        Text("Tap avatar to toggle voice")
                            .font(.system(size: 10))
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "hand.point.down.fill")
                            .foregroundColor(Color(red: 0.74, green: 0.88, blue: 0.77))
                            .font(.system(size: 11))
                        Text("Hold avatar to record voice")
                            .font(.system(size: 10))
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(Color(red: 0.74, green: 0.88, blue: 0.77))
                            .font(.system(size: 11))
                        Text("Replies read aloud by default")
                            .font(.system(size: 10))
                    }
                }
                .padding(8)
                .background(Color(white: 0.12))
                .cornerRadius(10)

                if showingTokenField {
                    TextField("Personal mgst_... token", text: $sdkToken)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .font(.system(size: 10, design: .monospaced))

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 9))
                            .foregroundColor(.red)
                    }
                } else {
                    Button("Add Personal Muse Token") {
                        showingTokenField = true
                    }
                    .font(.system(size: 10))
                    .tint(.blue)
                }

                Button(action: finishOnboarding) {
                    Text("Get Started")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
                .tint(Color(red: 0.74, green: 0.88, blue: 0.77))
                .foregroundColor(.black)
                .padding(.top, 4)
            }
            .padding(.horizontal, 6)
        }
    }

    private func finishOnboarding() {
        if !sdkToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if KeychainVault.validateSdkToken(sdkToken) {
                _ = runtime.saveSdkToken(sdkToken)
            } else {
                errorMessage = "Invalid token format."
                return
            }
        }
        withAnimation {
            runtime.onboardingDone = true
        }
    }
}
