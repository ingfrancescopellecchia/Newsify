//
//  SearchView.swift
//  Newsify
//
//  Created by san-9 on 01/07/2026.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = NewsViewModel()
    @ObservedObject private var bookmarksManager = BookmarksManager.shared
    @State private var searchText = ""

    private let categories = [
        CategoryItem(title: "WORLD", query: "World", count: 248, iconName: "globe"),
        CategoryItem(title: "TECH", query: "Tech", count: 134, iconName: "bolt.fill"),
        CategoryItem(title: "FINANCE", query: "Finance", count: 91, iconName: "chart.bar"),
        CategoryItem(title: "SPORT", query: "Sport", count: 312, iconName: "soccerball"),
        CategoryItem(title: "CULTURE", query: "Culture", count: 77, iconName: "paintpalette"),
        CategoryItem(title: "SCIENCE", query: "Science", count: 56, iconName: "atom")
    ]

    private var filteredArticles: [Article] {
        guard !searchText.isEmpty else { return viewModel.articles }

        return viewModel.articles.filter { article in
            article.title.localizedCaseInsensitiveContains(searchText) ||
            article.source.name.localizedCaseInsensitiveContains(searchText) ||
            (article.description?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.cream)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        if searchText.isEmpty {
                            categoriesSection
                        }

                        trendingSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .refreshable {
                    await viewModel.loadNews(query: "World")
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Search")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.navy)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search news, topics...")
            .task {
                if viewModel.articles.isEmpty {
                    await viewModel.loadNews(query: "World")
                }
            }
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CATEGORIES")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.navy)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryPlaceholderUIView(categoryName: category.query)) {
                        CategUIView(
                            title: category.title,
                            count: category.count,
                            iconName: category.iconName
                        )
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 16)
    }

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(searchText.isEmpty ? "TRENDING NOW" : "SEARCH RESULTS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.navy)

            VStack(spacing: 12) {
                if viewModel.isLoading && viewModel.articles.isEmpty {
                    ProgressView("Loading news...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                } else if let error = viewModel.errorMessage, viewModel.articles.isEmpty {
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color(.biancosporco))
                        .cornerRadius(18)
                } else if filteredArticles.isEmpty {
                    Text("No results found")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color(.biancosporco))
                        .cornerRadius(18)
                } else {
                    ForEach(Array(filteredArticles.enumerated()), id: \.element.id) { index, article in
                        HStack(spacing: 10) {
                            NavigationLink(destination: NewsDetailView(article: article)) {
                                SectionRowUIView(rank: index + 1, title: article.title, tag: article.source.name)
                                    .foregroundStyle(.navy)
                            }
                            .buttonStyle(.plain) 
                            bookmarkButton(for: article)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(Color(.biancosporco))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func bookmarkButton(for article: Article) -> some View {
        let saved = bookmarksManager.isBookmarked(article)

        return Button {
            withAnimation {
                bookmarksManager.toggle(article)
            }
        } label: {
            Image(systemName: saved ? "bookmark.fill" : "bookmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(saved ? Color.brand : Color.secondary)
                .frame(width: 34, height: 34)
                .background(Color(.systemGray6), in: Circle())
        }
        .accessibilityLabel(saved ? "Remove from bookmarks" : "Add to bookmarks")
    }
}

private struct CategoryItem: Identifiable {
    let title: String
    let query: String
    let count: Int
    let iconName: String

    var id: String { title }
}

#Preview {
    SearchView()
}
