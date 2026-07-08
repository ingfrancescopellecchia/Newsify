//
//  NewsViewModel.swift
//  Newsify
//

import Foundation
import Combine

@MainActor
final class NewsViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadNews(query: String = "Apple") async {
        isLoading = true
        errorMessage = nil
        do {
            articles = try await NewsService.shared.fetchNews(query: query)
        } catch {
            errorMessage = "Unable to load news. Please try again."
        }
        isLoading = false
    }
}
