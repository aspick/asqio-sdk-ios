import SwiftUI

/// メッセージバブル
struct MessageBubbleView: View {
    let message: Message

    private var isFromUser: Bool {
        message.senderType == .user
    }

    private var operatorBackgroundColor: Color {
        #if os(iOS)
        Color(.systemGray5)
        #else
        Color.gray.opacity(0.2)
        #endif
    }

    var body: some View {
        HStack {
            if isFromUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.body)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isFromUser ? Color.accentColor : operatorBackgroundColor)
                    .foregroundColor(isFromUser ? .white : .primary)
                    .cornerRadius(16)

                Text(message.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if !isFromUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 16) {
        MessageBubbleView(
            message: Message(
                id: "1",
                senderType: .user,
                senderId: "user1",
                body: "こんにちは。アプリの使い方について質問があります。",
                createdAt: Date()
            )
        )

        MessageBubbleView(
            message: Message(
                id: "2",
                senderType: .operator,
                senderId: "op1",
                body: "お問い合わせありがとうございます。どのような点でお困りでしょうか？",
                createdAt: Date()
            )
        )
    }
}
