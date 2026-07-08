//
//  NewsDetailView.swift
//  Newsify
//

import SwiftUI

struct NewsDetailView: View {
    let article: Article
    
    // Osserviamo il player condiviso per aggiornare l'icona quando parla
    @ObservedObject private var audioPlayer = ArticleAudioPlayer.shared
    
    // Stato per mostrare il foglio dell'AI
    @State private var showBotSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Immagine in cima, a piena larghezza controllata
                Color.clear
                    .frame(height: 260)
                    .overlay {
                        AsyncImage(url: article.urlToImage.flatMap(URL.init)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure, .empty:
                                Color(.systemGray5)
                                    .overlay {
                                        Image(systemName: "photo")
                                            .font(.largeTitle)
                                            .foregroundStyle(.secondary)
                                    }
                            @unknown default:
                                Color(.systemGray5)
                            }
                        }
                    }
                    .clipped()

                VStack(alignment: .leading, spacing: 12) {
                    // Fonte + data
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            sourceLabel
                            Spacer(minLength: 8)
                            dateLabel
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            sourceLabel
                            dateLabel
                        }
                    }

                    // Titolo e bottone Audio affiancati
                    HStack(alignment: .top, spacing: 16) {
                        Text(article.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.navy)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Bottone Audio
                        Button {
                            let textToRead = article.description ?? article.content ?? ""
                            audioPlayer.toggle(articleID: article.id, text: textToRead)
                        } label: {
                            Image(systemName: audioPlayer.isPlaying(article.id) ? "speaker.wave.3.fill" : "speaker.wave.2")
                                .font(.title3)
                                .foregroundColor(.navy)
                                .padding(10)
                                .background(Color.black.opacity(0.04), in: Circle())
                        }
                    }

                    // Descrizione / estratto
                    if let description = article.description, !description.isEmpty {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Link all'articolo completo sul sito originale
                    if let url = URL(string: article.url) {
                        Link(destination: url) {
                            Label("Read the full article", systemImage: "arrow.up.right.square")
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.85)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        // Toolbar: ora abbiamo solo l'AI a destra.
        // Il pulsante "Indietro" tornerà visibile automaticamente a sinistra.
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showBotSheet = true
                } label: {
                    Image(systemName: "sparkles")
                        .foregroundColor(.navy)
                }
            }
        }
        .sheet(isPresented: $showBotSheet) {
            BotSheetUIView(articles: [article])
        }
        .onDisappear {
            if audioPlayer.isPlaying(article.id) {
                audioPlayer.stop()
            }
        }
    }

    private var sourceLabel: some View {
        Text(article.source.name.uppercased())
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.red)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var dateLabel: some View {
        Text(formattedDate)
            .font(.caption)
            .foregroundColor(.secondary)
            .lineLimit(2)
            .minimumScaleFactor(0.85)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        guard let publishedAt = article.publishedAt,
              let date = isoFormatter.date(from: publishedAt) else {
            return ""
        }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "en_US")
        return displayFormatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    let mockArticle = Article(
        source: ArticleSource(name: "TechCrunch"),
        title: "Apple announces major updates to its AI framework at WWDC",
        description: "Apple introduced a slew of new features for developers today, focusing heavily on on-device machine learning.",
        url: "https://www.apple.com",
        urlToImage: "https://images.unsplash.com/photo-1512054502232-10a0a035d672?q=80&w=1000",
        publishedAt: "2024-06-10T17:30:00Z",
        content: "Full content of the article would go here...",
        category: "technology",
        country: "us"
    )
    
    return NavigationStack {
        NewsDetailView(article: mockArticle)
    }
}
