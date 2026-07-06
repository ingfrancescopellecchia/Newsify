//
//  SearchView.swift
//  Newsify
//
//  Created by san-9 on 01/07/2026.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    
    // Array di esempio
    @State private var allArticles = [
        Article(
            source: ArticleSource(name: "TECH"),
            title: "L'AI SUPERA I MEDICI NELLA DIAGNOSI",
            description: "Descrizione di prova",
            url: "https://example.com",
            urlToImage: nil,
            publishedAt: "2026-07-06"
        ),
        Article(
            source: ArticleSource(name: "FINANCE"),
            title: "MERCATI EUROPEI IN RIALZO DOPO I DATI",
            description: "Descrizione di prova",
            url: "https://example.com",
            urlToImage: nil,
            publishedAt: "2026-07-06"
        ),
        Article(
            source: ArticleSource(name: "SPORT"),
            title: "CHAMPIONS LEAGUE: RISULTATI IN DIRETTA",
            description: "Descrizione di prova",
            url: "https://example.com",
            urlToImage: nil,
            publishedAt: "2026-07-06"
        )
    ]
    
    // Filtro che ignora maiuscole e minuscole
    var filteredArticles: [Article] {
        if searchText.isEmpty {
            return allArticles
        } else {
            return allArticles.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.source.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Sezione Categorie
                        if searchText.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("CATEGORIE")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                
                                LazyVGrid(columns: columns, spacing: 16) {
                                    NavigationLink(destination: EmptyView()) {
                                        CategUIView(title: "MONDO", count: 248, iconName: "globe")
                                    }
                                    NavigationLink(destination: EmptyView()) {
                                        CategUIView(title: "TECH", count: 134, iconName: "bolt.fill")
                                    }
                                    NavigationLink(destination: EmptyView()) {
                                        CategUIView(title: "FINANCE", count: 91, iconName: "chart.bar")
                                    }
                                    NavigationLink(destination: EmptyView()) {
                                        CategUIView(title: "SPORT", count: 312, iconName: "soccerball")
                                    }
                                    NavigationLink(destination: EmptyView()) {
                                        KeepCulturaView()
                                    }
                                    NavigationLink(destination: EmptyView()) {
                                        CategUIView(title: "SCIENZA", count: 56, iconName: "atom")
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, 16) // Spazio dal motore di ricerca superiore
                        }
                        
                        // Sezione Trending
                        VStack(alignment: .leading, spacing: 12) {
                            Text(searchText.isEmpty ? "TRENDING ORA" : "RISULTATI RICERCA")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 12) {
                                if filteredArticles.isEmpty {
                                    Text("Nessun risultato trovato")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.vertical, 24)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .background(Color.white)
                                        .cornerRadius(18)
                                } else {
                                    // iterazione sugli indici dell'array
                                    ForEach(0..<filteredArticles.count, id: \.self) { index in
                                        let article = filteredArticles[index]
                                        
                                        NavigationLink(destination: EmptyView()) {
                                            SectionRowUIView(rank: index + 1, title: article.title, tag: article.source.name)
                                                .padding(.vertical, 16)
                                                .padding(.horizontal, 16)
                                                .background(Color.white)
                                                .cornerRadius(16)
                                                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            // Sfruttiamo la toolbar per forzare il titolo in alto
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Search")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.primary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            // Barra di ricerca
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Cerca notizie, argomenti...")
        }
    }
}

struct KeepCulturaView: View {
    var body: some View {
        CategUIView(title: "CULTURA", count: 77, iconName: "paintpalette")
    }
}

#Preview {
    SearchView()
}
