import SwiftUI

/// メッセージ入力フォーム
struct MessageInputView: View {
    @Binding var text: String
    let placeholder: String
    let onSend: () -> Void
    let isSending: Bool

    @FocusState private var isFocused: Bool

    private var inputBackgroundColor: Color {
        #if os(iOS)
        Color(.systemGray6)
        #else
        Color.gray.opacity(0.1)
        #endif
    }

    private var containerBackgroundColor: Color {
        #if os(iOS)
        Color(.systemBackground)
        #else
        Color.white
        #endif
    }

    init(
        text: Binding<String>,
        placeholder: String = "メッセージを入力",
        isSending: Bool = false,
        onSend: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isSending = isSending
        self.onSend = onSend
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField(placeholder, text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(inputBackgroundColor)
                .cornerRadius(20)
                .lineLimit(1...5)
                .focused($isFocused)

            Button(action: onSend) {
                if isSending {
                    ProgressView()
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                }
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(containerBackgroundColor)
    }
}

#Preview {
    VStack {
        Spacer()
        MessageInputView(text: .constant(""), isSending: false, onSend: {})
        MessageInputView(text: .constant("テストメッセージ"), isSending: false, onSend: {})
        MessageInputView(text: .constant("送信中..."), isSending: true, onSend: {})
    }
}
