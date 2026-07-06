//
//  NewsDetailView.swift
//  Newsify
//

import SwiftUI

struct NewsDetailView: View {
    let article: Article

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Immagine in cima, a piena larghezza
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
                .frame(height: 260)
                .frame(maxWidth: .infinity)
                .clipped()

                VStack(alignment: .leading, spacing: 12) {
                    // Fonte + data
                    HStack {
                        Text(article.source.name.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)

                        Spacer()

                        Text(formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Titolo
                    Text(article.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    // Descrizione / estratto
                    if let description = article.description, !description.isEmpty {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    // Link all'articolo completo sul sito originale
                    if let url = URL(string: article.url) {
                        Link(destination: url) {
                            HStack {
                                Text("Leggi l'articolo completo")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.up.right.square")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(20)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Converte la data ISO 8601 di NewsAPI (es. "2026-07-06T10:00:00Z")
    /// in un formato leggibile come "6 lug 2026, 10:00".
    private var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: article.publishedAt) else {
            return ""
        }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "it_IT")
        return displayFormatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        NewsDetailView(
            article: Article(
                source: ArticleSource(name: "ANSA"),
                title: "Terremoto in Venezuela: palazzi crollati, 32 morti e 700 feriti",
                description: "Il terremoto di magnitudo 6.5 ha colpito nel pomeriggio la costa nord del Paese, distruggendo edifici e provocando il panico tra la popolazione.",
                url: "https://example.com",
                urlToImage: nil,
                publishedAt: "2026-07-06T10:00:00Z"
            )
        )
    }
}
