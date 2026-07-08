//
//  BotSheetUIView.swift
//  Newsify
//
//  Created by san-7 on 03/07/2026.
//

import SwiftUI
import FoundationModels
import Combine

// MARK: - Modello messaggio chat

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: Role
    var content: String

    enum Role {
        case user
        case assistant
    }
}

// MARK: - ViewModel

@available(iOS 18.1, *)
@MainActor
final class BotChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isGenerating = false
    @Published var isModelAvailable = true
    var model = SystemLanguageModel.default
    private var session: LanguageModelSession?

    init() {
        checkAvailability()
    }

    private func checkAvailability() {
        switch model.availability {
        case .available:
            isModelAvailable = true
            session = LanguageModelSession(instructions: """
                You are Newsify's AI assistant, built for a news app. \
                Reply in English, clearly and concisely. \
                When summarizing news, highlight the main facts \
                without adding personal opinions.
                """)
        case .unavailable:
            isModelAvailable = false
        @unknown default:
            isModelAvailable = false
        }
    }

    /// Invia un messaggio libero dell'utente ricostruendo il contesto se necessario
    func send(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        messages.append(ChatMessage(role: .user, content: text))
        await generateResponse(prompt: text)
    }

    /// Riassume le notizie delle ultime 24 ore
    func summarizeLast24Hours(articles: [Article]) async {
        let cutoff = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? Date()
        let recent = articles.filter { article in
            guard let publishedAt = article.publishedAt,
                  let date = Self.parseDate(publishedAt) else { return false }
            return date >= cutoff
        }

        let userLabel = "Summarize the news from the last 24 hours"
        messages.append(ChatMessage(role: .user, content: userLabel))

        guard !recent.isEmpty else {
            messages.append(ChatMessage(role: .assistant, content: "I couldn't find any news published in the last 24 hours."))
            return
        }

        let articlesText = recent.prefix(20).map { article in
            "- \(article.title): \(article.description ?? "")"
        }.joined(separator: "\n")

        let prompt = """
        Here is a list of news from the last 24 hours:

        \(articlesText)

        Write a concise summary (max 150 words) organized by main themes.
        """

        await generateResponse(prompt: prompt)
    }

    /// Chiede informazioni sull'ultimo conflitto tra le notizie disponibili
    func askAboutLatestConflict(articles: [Article]) async {
        let userLabel = "Give me an update on the latest conflict"
        messages.append(ChatMessage(role: .user, content: userLabel))

        let keywords = ["conflict", "war", "attack", "army", "military", "ceasefire", "tensions"]
        let relevant = articles.filter { article in
            let text = (article.title + " " + (article.description ?? "")).lowercased()
            return keywords.contains { text.contains($0) }
        }

        guard !relevant.isEmpty else {
            messages.append(ChatMessage(role: .assistant, content: "I couldn't find any available news about ongoing conflicts."))
            return
        }

        let articlesText = relevant.prefix(15).map { article in
            "- \(article.title): \(article.description ?? "")"
        }.joined(separator: "\n")

        let prompt = """
        Here is news related to ongoing conflicts:

        \(articlesText)

        Summarize the current situation of the most relevant conflict, explaining \
        context and any recent developments neutrally, without taking sides.
        """

        await generateResponse(prompt: prompt)
    }

    // MARK: - Generazione risposta

    private func generateResponse(prompt: String) async {
        guard let session, isModelAvailable else {
            messages.append(ChatMessage(role: .assistant, content: "Apple Intelligence is not available on this device."))
            return
        }

        isGenerating = true
        let placeholderIndex = messages.count
        messages.append(ChatMessage(role: .assistant, content: ""))

        do {
            let stream = session.streamResponse(to: prompt)
            for try await partial in stream {
                // BUG FIX: Usiamo += per sommare i token dello streaming anziché sovrascriverli
                messages[placeholderIndex].content += partial.content
            }
        } catch {
            messages[placeholderIndex].content = "An error occurred: \(error.localizedDescription)"
        }

        isGenerating = false
    }

    // MARK: - Utility

    private static func parseDate(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: string) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string)
    }
}

// MARK: - Router View

struct BotSheetUIView: View {
    @Environment(\.dismiss) var dismiss
    let articles: [Article]

    var body: some View {
        if #available(iOS 18.1, *) {
            BotSheetContentView(articles: articles)
        } else {
            VStack(spacing: 16) {
                Image(systemName: "sparkles.slash")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                Text("AI Assistant requires iOS 18.1 or later")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
}

// MARK: - Contenuto reale (iOS 18.1+)

@available(iOS 18.1, *)
private struct BotSheetContentView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = BotChatViewModel()
    @State private var inputText = ""

    let articles: [Article]

    var body: some View {
        VStack(spacing: 0) {
            header

            if viewModel.messages.isEmpty {
                emptyStateWithSuggestions
            } else {
                chatList
            }

            inputBar
        }
        .presentationDetents([.medium, .large])
    }

    private var header: some View {
        HStack {
            Text("AI Assistant")
                .foregroundColor(.navy)
                .font(.title2)
                .bold()
            Spacer()
        }
        .padding()
    }

    private var emptyStateWithSuggestions: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("Ask me something about the news")
                .foregroundColor(.secondary)
                .font(.subheadline)

            VStack(spacing: 10) {
                suggestionButton(
                    icon: "clock.arrow.circlepath",
                    text: "Summarize the last 24 hours"
                ) {
                    Task { await viewModel.summarizeLast24Hours(articles: articles) }
                }

                suggestionButton(
                    icon: "globe",
                    text: "Update me on the latest conflict"
                ) {
                    Task { await viewModel.askAboutLatestConflict(articles: articles) }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    private func suggestionButton(icon: String, text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(text)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .foregroundColor(.navy)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private var chatList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        messageBubble(message)
                            .id(message.id)
                    }
                }
                .padding()
            }
            
            .onChange(of: viewModel.messages) { _, newMessages in
                if let last = newMessages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }

            Text(message.content)
                .padding(12)
                .background(message.role == .user ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundColor(message.role == .user ? .white : .navy)
                .cornerRadius(14)

            if message.role == .assistant { Spacer(minLength: 40) }
        }
    }

    private var inputBar: some View {
        HStack {
            TextField("Write a message...", text: $inputText)
                .textFieldStyle(.roundedBorder)

            Button {
                let text = inputText
                inputText = ""
                Task { await viewModel.send(text) }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isGenerating)
        }
        .padding()
    }
}

#Preview {
    BotSheetUIView(articles: [])
}
