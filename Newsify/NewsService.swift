//
//  NewsService.swift
//  Newsify
//

import Foundation

enum NewsError: Error {
    case invalidURL
    case requestFailed(String)
    case decodingFailed
}

final class NewsService {
    static let shared = NewsService()

    private let apiKey = "76f637672ec34173adb9f7bb29491af9"
    private let baseURL = "https://newsapi.org/v2/top-headlines"

    /// Recupera i top headlines.
    ///
    /// NB: /top-headlines accetta SOLO questi parametri: country, category,
    /// sources, q, pageSize, page (+ apiKey). NON accetta `language`, `from`,
    /// `to`, `sortBy` — passarli fa rispondere l'API con un 400, che è il
    /// motivo per cui le notizie non si caricavano più.
    ///
    /// - Parameter query: qui viene interpretata come nome di categoria
    ///   ("Tecnologia" → technology, "Sport" → sports). Se non corrisponde a
    ///   nessuna categoria nota, viene ignorata e restituisce il feed
    ///   generico per l'Italia (country=it), perché top-headlines non ha una
    ///   categoria "Mondo"/internazionale: le uniche ammesse sono business,
    ///   entertainment, general, health, science, sports, technology.
    func fetchNews(query: String, from: String? = nil) async throws -> [Article] {
        var components = URLComponents(string: baseURL)
        var queryItems = [
            URLQueryItem(name: "country", value: "us"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        if let category = Self.category(for: query) {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }

        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw NewsError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            // NewsAPI restituisce un JSON con "code"/"message" che spiega
            // esattamente cosa non va: stamparlo qui evita di doverlo
            // indovinare la prossima volta.
            if let body = String(data: data, encoding: .utf8) {
                print("⚠️ NewsAPI error body:", body)
            }
            throw NewsError.requestFailed("Status code non valido")
        }

        do {
            let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
            return decoded.articles
        } catch {
            throw NewsError.decodingFailed
        }
    }

    /// Mappa i nomi delle tab dell'app alle category valide di NewsAPI.
    private static func category(for query: String) -> String? {
        switch query.lowercased() {
        case "tech", "technology": return "technology"
        case "finance", "business": return "business"
        case "sport", "sports": return "sports"
        case "culture", "entertainment": return "entertainment"
        case "science", "health": return "health"
        default: return nil
        }
    }
}
