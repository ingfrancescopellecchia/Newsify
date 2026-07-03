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

    // ⚠️ Per ora la mettiamo qui, ma vedi la nota in fondo alla risposta
    // su come non tenerla in chiaro nel codice sorgente.
    private let apiKey = "228b6c3cf68c411ea1cfb582793e82cf"
    private let baseURL = "https://newsapi.org/v2/everything"

    /// Recupera notizie per una query, ordinate per popolarità.
    /// - Parameters:
    ///   - query: termine di ricerca (es. "Italia")
    ///   - from: data di inizio in formato "yyyy-MM-dd". Se nil, usa gli ultimi 7 giorni.
    func fetchNews(query: String, from: String? = nil) async throws -> [Article] {
        var components = URLComponents(string: baseURL)
        var queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "sortBy", value: "popularity"),
            URLQueryItem(name: "language", value: "it"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]

        let fromDate = from ?? Self.defaultFromDate()
        queryItems.append(URLQueryItem(name: "from", value: fromDate))
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw NewsError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NewsError.requestFailed("Status code non valido")
        }

        do {
            let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
            return decoded.articles
        } catch {
            throw NewsError.decodingFailed
        }
    }

    /// Calcola la data di 7 giorni fa in formato "yyyy-MM-dd".
    /// Il piano gratuito di NewsAPI non permette di andare più indietro nel tempo.
    private static func defaultFromDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return formatter.string(from: sevenDaysAgo)
    }
}
