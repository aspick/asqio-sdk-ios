import SwiftUI

/// 新規チケット作成画面
public struct NewTicketView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: NewTicketViewModel
    private let context: [String: String]?
    private let onCreated: ((Ticket) -> Void)?

    @FocusState private var isMessageFocused: Bool

    private var overlayBackgroundColor: Color {
        #if os(iOS)
        Color(.systemBackground)
        #else
        Color.white
        #endif
    }

    /// 新規チケット作成画面を作成
    /// - Parameters:
    ///   - ticketService: チケットサービス
    ///   - context: チケットに付与するコンテキスト
    ///   - onCreated: チケット作成完了時のコールバック
    public init(
        ticketService: TicketService,
        context: [String: String]? = nil,
        onCreated: ((Ticket) -> Void)? = nil
    ) {
        self._viewModel = StateObject(wrappedValue: NewTicketViewModel(ticketService: ticketService))
        self.context = context
        self.onCreated = onCreated
    }

    public var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    TextField("件名（省略可）", text: $viewModel.title)
                }

                Section {
                    TextEditor(text: $viewModel.message)
                        .frame(minHeight: 150)
                        .focused($isMessageFocused)
                } header: {
                    Text("お問い合わせ内容")
                } footer: {
                    Text("できるだけ詳しくお書きください")
                }
            }
        }
        .navigationTitle("新規お問い合わせ")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .topBarTrailing) {
                sendButton
            }
            #else
            ToolbarItem(placement: .automatic) {
                sendButton
            }
            #endif

            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("完了") {
                        isMessageFocused = false
                    }
                }
            }
        }
        .disabled(viewModel.isSubmitting)
        .overlay {
            if viewModel.isSubmitting {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView("送信中...")
                    .padding()
                    .background(overlayBackgroundColor)
                    .cornerRadius(8)
            }
        }
        .alert("エラー", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
        .onAppear {
            isMessageFocused = true
        }
    }

    private var sendButton: some View {
        Button("送信") {
            Task {
                await createTicket()
            }
        }
        .disabled(!viewModel.canSubmit)
    }

    private func createTicket() async {
        let ticket = await viewModel.createTicket(context: context)
        if let ticket = ticket {
            onCreated?(ticket)
            dismiss()
        }
    }
}

// MARK: - ViewModel

@MainActor
final class NewTicketViewModel: ObservableObject {
    @Published var title = ""
    @Published var message = ""
    @Published var isSubmitting = false
    @Published var error: AsqioError?
    @Published var showError = false

    private let ticketService: TicketService

    var canSubmit: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }

    init(ticketService: TicketService) {
        self.ticketService = ticketService
    }

    func createTicket(context: [String: String]?) async -> Ticket? {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return nil }

        isSubmitting = true

        do {
            let titleToSend = title.trimmingCharacters(in: .whitespacesAndNewlines)
            let ticket = try await ticketService.createTicket(
                message: trimmedMessage,
                title: titleToSend.isEmpty ? nil : titleToSend,
                context: context
            )
            isSubmitting = false
            return ticket
        } catch let asqioError as AsqioError {
            error = asqioError
            showError = true
        } catch {
            self.error = .networkError(error)
            showError = true
        }

        isSubmitting = false
        return nil
    }
}
