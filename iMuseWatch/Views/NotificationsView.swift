import SwiftUI

public struct NotificationsView: View {
    let notification: GlanceableNotification
    let onDismiss: () -> Void

    public init(notification: GlanceableNotification, onDismiss: @escaping () -> Void) {
        self.notification = notification
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(notification.mood.glowColor)
                    .frame(width: 6, height: 6)

                Text(notification.title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }

            Text(notification.text)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(3)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.14).opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(notification.mood.glowColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
