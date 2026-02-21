import SwiftUI

/// チケット一覧画面
public struct TicketListView: View {
    @StateObject private var viewModel: TicketListViewModel
    private let context: [String: String]?
    private let onTicketSelected: ((Ticket) -> Void)?

    /// チケット一覧画面を作成
    /// - Parameters:
    ///   - ticketService: チケットサービス
    ///   - messageService: メッセージサービス
    ///   - context: 新規チケット作成時に付与するコンテキスト
    ///   - onTicketSelected: チケット選択時のコールバック（nil の場合は内部遷移）
    public init(
        ticketService: TicketService,
        messageService: MessageService,
        context: [String: String]? = nil,
        onTicketSelected: ((Ticket) -> Void)? = nil
    ) {
        self._viewModel = StateObject(wrappedValue: TicketListViewModel(ticketService: ticketService, messageService: messageService))
        self.context = context
        self.onTicketSelected = onTicketSelected
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.tickets.isEmpty {
                    ProgressView("読み込み中...")
                } else if let error = viewModel.error {
                    errorView(error)
                } else if viewModel.tickets.isEmpty {
                    emptyView
                } else {
                    ticketList
                }
            }
            .navigationTitle("お問い合わせ")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    newTicketButton
                }
                #else
                ToolbarItem(placement: .automatic) {
                    newTicketButton
                }
                #endif
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadTickets()
            }
        }
    }

    private var newTicketButton: some View {
        NavigationLink {
            NewTicketView(
                ticketService: viewModel.ticketService,
                context: context
            ) { newTicket in
                viewModel.addTicket(newTicket)
            }
        } label: {
            Image(systemName: "square.and.pencil")
        }
    }

    private var ticketList: some View {
        List {
            ForEach(viewModel.tickets) { ticket in
                NavigationLink {
                    TicketDetailView(
                        ticket: ticket,
                        ticketService: viewModel.ticketService,
                        messageService: viewModel.messageService
                    ) {
                        viewModel.markAsRead(ticketId: ticket.id)
                    }
                } label: {
                    TicketRowView(ticket: ticket)
                }
            }

            if viewModel.hasMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .task {
                        await viewModel.loadMore()
                    }
            }
        }
        .listStyle(.plain)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("お問い合わせはありません")
                .font(.headline)
            Text("右上のボタンから新しいお問い合わせを作成できます")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private func errorView(_ error: AsqioError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            Text("エラーが発生しました")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("再読み込み") {
                Task {
                    await viewModel.refresh()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - Ticket Row

private struct TicketRowView: View {
    let ticket: Ticket

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(ticket.title ?? "お問い合わせ")
                        .font(.headline)
                        .lineLimit(1)

                    if ticket.unread {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 8, height: 8)
                    }
                }

                if let topicName = ticket.topic?.name {
                    Text(topicName)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }

                Text(ticket.updatedAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - ViewModel

@MainActor
final class TicketListViewModel: ObservableObject {
    @Published var tickets: [Ticket] = []
    @Published var isLoading = false
    @Published var error: AsqioError?
    @Published var hasMore = false

    let ticketService: TicketService
    let messageService: MessageService

    private var currentPage = 1
    private let perPage = 20

    init(ticketService: TicketService, messageService: MessageService) {
        self.ticketService = ticketService
        self.messageService = messageService
    }

    func loadTickets() async {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        do {
            let result = try await ticketService.listTickets(page: 1, perPage: perPage)
            tickets = result.tickets
            currentPage = 1
            hasMore = result.meta.currentPage < result.meta.totalPages
        } catch let asqioError as AsqioError {
            error = asqioError
        } catch {
            self.error = .networkError(error)
        }

        isLoading = false
    }

    func loadMore() async {
        guard !isLoading, hasMore else { return }

        isLoading = true

        do {
            let nextPage = currentPage + 1
            let result = try await ticketService.listTickets(page: nextPage, perPage: perPage)
            tickets.append(contentsOf: result.tickets)
            currentPage = nextPage
            hasMore = result.meta.currentPage < result.meta.totalPages
        } catch {
            // ページネーションエラーは静かに無視
        }

        isLoading = false
    }

    func refresh() async {
        currentPage = 1
        await loadTickets()
    }

    func addTicket(_ ticket: Ticket) {
        tickets.insert(ticket, at: 0)
    }

    func markAsRead(ticketId: String) {
        if let index = tickets.firstIndex(where: { $0.id == ticketId }) {
            var ticket = tickets[index]
            ticket = Ticket(
                id: ticket.id,
                title: ticket.title,
                topic: ticket.topic,
                context: ticket.context,
                deviceInfo: ticket.deviceInfo,
                unread: false,
                createdAt: ticket.createdAt,
                updatedAt: ticket.updatedAt,
                messages: ticket.messages
            )
            tickets[index] = ticket
        }
    }
}
