//
//  CategoryPlaceholderUIView.swift
//  Newsify
//
//  Created by san-7 on 02/07/2026.
//

import SwiftUI

struct CategoryPlaceholderUIView: View {
    let categoryName: String

    @StateObject private var viewModel = NewsViewModel()
    @ObservedObject private var bookmarksManager = BookmarksManager.shared
    // Stesso pattern di ExploreView: Button + navigationDestination(item:)
    // invece di NavigationLink, per evitare la freccetta di sistema che
    // riserva spazio a destra e scentra le card.
    @State private var selectedArticle: Article?

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            Group {
                if viewModel.isLoading && viewModel.articles.isEmpty {
                    ProgressView("Loading news...")
                } else if let error = viewModel.errorMessage, viewModel.articles.isEmpty {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "wifi.exclamationmark",
                        description: Text(error)
                    )
                } else if viewModel.articles.isEmpty {
                    // NewsAPI per questa categoria): non è un errore, è uno
                    // stato a sé, quindi merita un messaggio diverso.
                    ContentUnavailableView(
                        "No news",
                        systemImage: "newspaper",
                        description: Text("There is no news available for \(categoryName.lowercased()) right now.")
                    )
                } else {
                    List {
                        ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
                            newsRow(for: article, isFirst: index == 0)
                                .padding(.vertical, 7)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    bookmarkButton(for: article)
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    bookmarkButton(for: article)
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        await viewModel.loadNews(query: categoryName)
                    }
                }
            }
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedArticle) { article in
            NewsDetailView(article: article)
        }
        .task {
            await viewModel.loadNews(query: categoryName)
        }
    }

    @ViewBuilder
    private func newsRow(for article: Article, isFirst: Bool) -> some View {
        Button {
            selectedArticle = article
        } label: {
            if isFirst {
                BigNewsCardUIView(
                    title: article.title,
                    source: article.source.name,
                    description: article.description,
                    imageURL: article.urlToImage.flatMap(URL.init)
                )
            } else {
                SmallNewsCardUIView(
                    title: article.title,
                    source: article.source.name
                )
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func bookmarkButton(for article: Article) -> some View {
        let saved = bookmarksManager.isBookmarked(article)
        Button {
            withAnimation {
                bookmarksManager.toggle(article)
            }
        } label: {
            Label(
                saved ? "Remove" : "Save",
                systemImage: saved ? "bookmark.slash.fill" : "bookmark.fill"
            )
        }
        .tint(saved ? .gray : .brand)
    }
}

#Preview {
    NavigationStack {
        CategoryPlaceholderUIView(categoryName: "Sport")
    }
}

#Preview("Dark") {
    NavigationStack {
        CategoryPlaceholderUIView(categoryName: "Sport")
    }
    .preferredColorScheme(.dark)
}
