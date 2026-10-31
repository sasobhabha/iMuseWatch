import SwiftUI

public struct TranscriptView: View {
    @ObservedObject var runtime: MuseRuntime
    @Environment(\.dismiss) private var dismiss

    public init(runtime: MuseRuntime) {
        self.runtime = runtime
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Live Transcript")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                    .font(.footnote)
                    .foregroundColor(Color(red: 0.74, green: 0.88, blue: 0.77))
                }
                .padding(.bottom, 4)

                if runtime.messages.isEmpty {
                    Text("No conversation yet. Tap your companion's face to start talking.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    ForEach(runtime.messages) { message in
                        HStack {
                            if message.isUser {
                                Spacer()
                                Text(message.text)
                                    .font(.system(size: 12))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.4))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            } else {
                                Text(message.text)
                                    .font(.system(size: 12))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(white: 0.2))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }
}
