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

    private var session: LanguageModelSession?

    init() {
        checkAvailability()
    }

    private func checkAvailability() {
        // Verifica che Apple Intelligence sia disponibile sul dispositivo
        switch SystemLanguageModel.default.availability {
        case .available:
            isModelAvailable = true
            session = LanguageModelSession(instructions: """
                Sei l'assistente AI di Newsify, un'app di news. \
                Rispondi in italiano, in modo chiaro e conciso. \
                Quando riassumi delle notizie, evidenzia i fatti principali \
                senza aggiungere opinioni personali.
                """)
        case .unavailable:
            isModelAvailable = false
        @unknown default:
            isModelAvailable = false
        }
    }

    /// Invia un messaggio libero dell'utente
    func send(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        messages.append(ChatMessage(role: .user, content: text))
        await generateResponse(prompt: text)
    }

    /// Riassume le notizie delle ultime 24 ore
    func summarizeLast24Hours(articles: [Article]) async {
        let cutoff = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? Date()
        let recent = articles.filter { article in
            guard let date = Self.parseDate(article.publishedAt) else { return false }
            return date >= cutoff
        }

        let userLabel = "Fammi un riassunto delle notizie delle ultime 24 ore"
        messages.append(ChatMessage(role: .user, content: userLabel))

        guard !recent.isEmpty else {
            messages.append(ChatMessage(role: .assistant, content: "Non ho trovato notizie pubblicate nelle ultime 24 ore."))
            return
        }

        let articlesText = recent.prefix(20).map { article in
            "- \(article.title): \(article.description ?? "")"
        }.joined(separator: "\n")

        let prompt = """
        Ecco un elenco di notizie delle ultime 24 ore:

        \(articlesText)

        Fai un riassunto sintetico (max 150 parole) organizzato per temi principali.
        """

        await generateResponse(prompt: prompt)
    }

    /// Chiede informazioni sull'ultimo conflitto tra le notizie disponibili
    func askAboutLatestConflict(articles: [Article]) async {
        let userLabel = "Dammi un aggiornamento sull'ultimo conflitto"
        messages.append(ChatMessage(role: .user, content: userLabel))

        let keywords = ["conflitto", "guerra", "attacco", "esercito", "cessate il fuoco", "tensioni"]
        let relevant = articles.filter { article in
            let text = (article.title + " " + (article.description ?? "")).lowercased()
            return keywords.contains { text.contains($0) }
        }

        guard !relevant.isEmpty else {
            messages.append(ChatMessage(role: .assistant, content: "Non ho trovato notizie su conflitti in corso tra quelle disponibili."))
            return
        }

        let articlesText = relevant.prefix(15).map { article in
            "- \(article.title): \(article.description ?? "")"
        }.joined(separator: "\n")

        let prompt = """
        Ecco delle notizie relative a conflitti in corso:

        \(articlesText)

        Riassumi la situazione attuale del conflitto più rilevante, spiegando \
        contesto ed eventuali sviluppi recenti, in modo neutrale e senza schierarti.
        """

        await generateResponse(prompt: prompt)
    }

    // MARK: - Generazione risposta

    private func generateResponse(prompt: String) async {
        guard let session, isModelAvailable else {
            messages.append(ChatMessage(role: .assistant, content: "Apple Intelligence non è disponibile su questo dispositivo."))
            return
        }

        isGenerating = true
        // Placeholder per lo streaming
        let placeholderIndex = messages.count
        messages.append(ChatMessage(role: .assistant, content: ""))

        do {
            let stream = session.streamResponse(to: prompt)
            for try await partial in stream {
                messages[placeholderIndex].content = partial.content
            }
        } catch {
            messages[placeholderIndex].content = "Si è verificato un errore: \(error.localizedDescription)"
        }

        isGenerating = false
    }

    // MARK: - Utility

    /// Converte la stringa `publishedAt` di NewsAPI (formato ISO8601) in Date
    private static func parseDate(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: string) {
            return date
        }
        // Fallback nel caso manchino i millisecondi o ci sia un formato leggermente diverso
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string)
    }
}

// MARK: - Router View (compatibile con tutte le versioni iOS)

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
                Text("Assistente AI richiede iOS 18.1 o superiore")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
}

// MARK: - Contenuto reale (richiede iOS 18.1+)

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
            Text("Assistente AI")
                .foregroundColor(.primary)
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

            Text("Chiedimi qualcosa sulle notizie")
                .foregroundColor(.secondary)
                .font(.subheadline)

            VStack(spacing: 10) {
                suggestionButton(
                    icon: "clock.arrow.circlepath",
                    text: "Riassumi le ultime 24 ore"
                ) {
                    Task { await viewModel.summarizeLast24Hours(articles: articles) }
                }

                suggestionButton(
                    icon: "globe",
                    text: "Aggiornami sull'ultimo conflitto"
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
            .foregroundColor(.primary)
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
            .onChange(of: viewModel.messages.count) {
                if let last = viewModel.messages.last {
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
                .foregroundColor(message.role == .user ? .white : .primary)
                .cornerRadius(14)

            if message.role == .assistant { Spacer(minLength: 40) }
        }
    }

    private var inputBar: some View {
        HStack {
            TextField("Scrivi un messaggio...", text: $inputText)
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

