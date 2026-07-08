//
//  Article.swift
//  Newsify
//

import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable, Identifiable, Hashable {
    // NewsAPI non fornisce un id, lo generiamo noi
    var id: String { url }

    let source: ArticleSource
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    let category: String?
    let country: String?
}

struct ArticleSource: Codable, Hashable {
    let name: String
}
