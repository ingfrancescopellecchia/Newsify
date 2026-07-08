//
//  BookmarksView.swift
//  Newsify
//

import SwiftUI

struct BookmarksView: View {
    @ObservedObject private var bookmarksManager = BookmarksManager.shared
    @State private var searchText = ""
    @State private var sortOrder: BookmarkSortOrder = .newestFirst

    private var filteredBookmarks: [BookmarkedArticle] {
        let bookmarks = bookmarksManager.savedBookmarks.filter { bookmark in
            guard !searchText.isEmpty else { return true }

            return bookmark.article.title.localizedCaseInsensitiveContains(searchText) ||
            bookmark.article.source.name.localizedCaseInsensitiveContains(searchText) ||
            (bookmark.article.description?.localizedCaseInsensitiveContains(searchText) ?? false)
        }

        switch sortOrder {
        case .newestFirst:
            return bookmarks.sorted { $0.addedAt > $1.addedAt }
        case .oldestFirst:
            return bookmarks.sorted { $0.addedAt < $1.addedAt }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.cream)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {

                    if bookmarksManager.savedBookmarks.isEmpty {
                        emptyStateView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        sortPicker

                        if filteredBookmarks.isEmpty {
                            ContentUnavailableView(
                                "No results",
                                systemImage: "magnifyingglass",
                                description: Text("No saved news matches your search.")
                            )
                        } else {
                            bookmarksList
                        }
                    }
                }
                .padding(.top, 8)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Bookmarks")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color("navy"))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .searchable(
                text: $searchText,
                prompt: "Search bookmarks"
            )
        }
    }

    private var sortPicker: some View {
        Picker("Sort", selection: $sortOrder) {
            ForEach(BookmarkSortOrder.allCases) { order in
                Text(order.title).tag(order)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var bookmarksList: some View {
        List {
            ForEach(Array(filteredBookmarks.enumerated()), id: \.element.id) { index, bookmark in
                NavigationLink(destination: NewsDetailView(article: bookmark.article)) {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionRowUIView(
                            rank: index + 1,
                            title: bookmark.article.title,
                            tag: bookmark.article.source.name
                        )
                        .foregroundStyle(.navy) // Forziamo il colore Navy sui testi della riga

                        Text("Added on \(formattedAddedDate(bookmark.addedAt))")
                            .font(.caption2)
                            .foregroundStyle(.navy)
                            .padding(.leading, 34)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain) // Rimuove la colorazione blu standard del NavigationLink dentro le List
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation {
                            bookmarksManager.remove(bookmark.article)
                        }
                    } label: {
                        Label("Remove", systemImage: "bookmark.slash")
                    }
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var emptyStateView: some View {
        VStack(spacing: 18) {
            Image(systemName: "bookmark.slash.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 72)
                .foregroundStyle(Color.navy)

            VStack(spacing: 8) {
                Text("No bookmarked news")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.navy)
                    .multilineTextAlignment(.center)

                Text("Tap the bookmark button on a story to save it here.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.navy)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 40)
            }
        }
    }

    private func formattedAddedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private enum BookmarkSortOrder: String, CaseIterable, Identifiable {
    case newestFirst
    case oldestFirst

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newestFirst: return "Newest"
        case .oldestFirst: return "Oldest"
        }
    }
}

#Preview {
    BookmarksView()
}
