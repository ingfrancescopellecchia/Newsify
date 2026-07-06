//
// BookmarksManager.swift
// Newsify
//

import Foundation
import Combine

/// Gestisce la lista delle notizie salvate dall'utente.
/// Singleton semplice: si accede ovunque con `BookmarksManager.shared`,
/// così non serve modificare l'entry point dell'app per iniettarlo come
/// EnvironmentObject (anche se puoi farlo se preferisci quell'approccio).
final class BookmarksManager: ObservableObject {
    static let shared = BookmarksManager()

    @Published private(set) var savedArticles: [Article] = []

    private let storageKey = "bookmarkedArticles"

    private init() {
        load()
    }

    /// True se l'articolo è già tra i salvati.
    func isBookmarked(_ article: Article) -> Bool {
        savedArticles.contains { $0.id == article.id }
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
        savedArticles.insert(article, at: 0)
        save()
    }

    func remove(_ article: Article) {
        savedArticles.removeAll { $0.id == article.id }
        save()
    }

    // MARK: - Persistenza

    private func save() {
        // Richiede che Article (e i suoi campi, es. Source) siano Codable.
        guard let data = try? JSONEncoder().encode(savedArticles) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Article].self, from: data)
        else { return }
        savedArticles = decoded
    }
}
