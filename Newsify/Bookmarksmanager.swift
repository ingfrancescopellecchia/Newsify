//
// BookmarksManager.swift
// Newsify
//

import Foundation
import Combine

struct BookmarkedArticle: Codable, Identifiable, Hashable {
    let article: Article
    let addedAt: Date

    var id: String { article.id }
}

/// Gestisce la lista delle notizie salvate dall'utente.
/// Singleton semplice: si accede ovunque con `BookmarksManager.shared`,
/// così non serve modificare l'entry point dell'app per iniettarlo come
/// EnvironmentObject (anche se puoi farlo se preferisci quell'approccio).
final class BookmarksManager: ObservableObject {
    static let shared = BookmarksManager()

    @Published private(set) var savedArticles: [Article] = []
    @Published private(set) var savedBookmarks: [BookmarkedArticle] = []

    private let storageKey = "bookmarkedArticles"

    private init() {
        load()
    }

    /// True se l'articolo è già tra i salvati.
    func isBookmarked(_ article: Article) -> Bool {
        savedBookmarks.contains { $0.article.id == article.id }
    }

    /// Aggiunge se non presente, rimuove se già presente.
    /// Comodo per lo swipe: prima volta salva, seconda volta rimuove.
    func toggle(_ article: Article) {
        if isBookmarked(article) {
            remove(article)
        } else {
            add(article)
        }
    }

    func add(_ article: Article) {
        guard !isBookmarked(article) else { return }
        savedBookmarks.insert(BookmarkedArticle(article: article, addedAt: Date()), at: 0)
        syncSavedArticles()
        save()
    }

    func remove(_ article: Article) {
        savedBookmarks.removeAll { $0.article.id == article.id }
        syncSavedArticles()
        save()
    }

    // MARK: - Persistenza

    private func save() {
        guard let data = try? JSONEncoder().encode(savedBookmarks) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }

        if let decoded = try? JSONDecoder().decode([BookmarkedArticle].self, from: data) {
            savedBookmarks = decoded.sorted { $0.addedAt > $1.addedAt }
            syncSavedArticles()
            return
        }

        if let legacyArticles = try? JSONDecoder().decode([Article].self, from: data) {
            savedBookmarks = legacyArticles.enumerated().map { index, article in
                BookmarkedArticle(
                    article: article,
                    addedAt: Calendar.current.date(byAdding: .second, value: -index, to: Date()) ?? Date()
                )
            }
            syncSavedArticles()
            save()
        }
    }

    private func syncSavedArticles() {
        savedArticles = savedBookmarks.map(\.article)
    }
}
