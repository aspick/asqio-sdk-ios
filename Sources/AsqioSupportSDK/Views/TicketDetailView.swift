import SwiftUI

/// チケット詳細画面
public struct TicketDetailView: View {
    @StateObject private var viewModel: TicketDetailViewModel
    private let onRead: (() -> Void)?

    /// チケット詳細画面を作成
    /// - Parameters:
    ///   - ticket: 表示するチケット
    ///   - ticketService: チケットサービス
    ///   - messageService: メッセージサービス
    ///   - onRead: 既読化完了時のコールバック
    public init(
        ticket: Ticket,
        ticketService: TicketService,
        messageService: MessageService,
        onRead: (() -> Void)? = nil
    ) {
        self._viewModel = StateObject(
            wrappedValue: TicketDetailViewModel(
                ticket: ticket,
                ticketService: ticketService,
                messageService: messageService
            )
        )
        self.onRead = onRead
    }

    public var body: some View {
        VStack(spacing: 0) {
            messageList

            Divider()

            MessageInputView(
                text: $viewModel.newMessageText,
                isSending: viewModel.isSending
            ) {
                Task {
                    await viewModel.sendMessage()
                }
            }
        }
        .navigationTitle(viewModel.ticket.title ?? "お問い合わせ")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            await viewModel.loadMessages()
            await viewModel.markAsRead()
            onRead?()
        }
        .alert("エラー", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.hasMore {
                        Button("以前のメッセージを読み込む") {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                    }

                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                }
                .padding(.vertical)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
final class TicketDetailViewModel: ObservableObject {
    @Published var ticket: Ticket
    @Published var messages: [Message] = []
    @Published var newMessageText = ""
    @Published var isLoading = false
    @Published var isSending = false
    @Published var error: AsqioError?
    @Published var showError = false
    @Published var hasMore = false

    private let ticketService: TicketService
    private let messageService: MessageService
    private var currentPage = 1
    private let perPage = 50

    init(ticket: Ticket, ticketService: TicketService, messageService: MessageService) {
        self.ticket = ticket
        self.ticketService = ticketService
        self.messageService = messageService

        // チケットにメッセージが含まれている場合は初期表示
        if let ticketMessages = ticket.messages {
            self.messages = ticketMessages
        }
    }

    func loadMessages() async {
        guard !isLoading else { return }

        isLoading = true

        do {
            let result = try await messageService.listMessages(
                ticketId: ticket.id,
                page: 1,
                perPage: perPage
            )
            messages = result.messages.reversed()
            currentPage = 1
            hasMore = result.meta.currentPage < result.meta.totalPages
        } catch let asqioError as AsqioError {
            error = asqioError
            showError = true
        } catch {
            self.error = .networkError(error)
            showError = true
        }

        isLoading = false
    }

    func loadMore() async {
        guard !isLoading, hasMore else { return }

        isLoading = true

        do {
            let nextPage = currentPage + 1
            let result = try await messageService.listMessages(
                ticketId: ticket.id,
                page: nextPage,
                perPage: perPage
            )
            let newMessages = result.messages.reversed()
            messages.insert(contentsOf: newMessages, at: 0)
            currentPage = nextPage
            hasMore = result.meta.currentPage < result.meta.totalPages
        } catch {
            // ページネーションエラーは静かに無視
        }

        isLoading = false
    }

    func sendMessage() async {
        let body = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty, !isSending else { return }

        isSending = true

        do {
            let message = try await messageService.postMessage(ticketId: ticket.id, body: body)
            messages.append(message)
            newMessageText = ""
        } catch let asqioError as AsqioError {
            error = asqioError
            showError = true
        } catch {
            self.error = .networkError(error)
            showError = true
        }

        isSending = false
    }

    func markAsRead() async {
        do {
            try await ticketService.markAsRead(ticketId: ticket.id)
        } catch {
            // 既読エラーは静かに無視
        }
    }
}
