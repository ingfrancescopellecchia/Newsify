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

struct Article: Codable, Identifiable {
    // NewsAPI non fornisce un id, lo generiamo noi
    var id: String { url }

    let source: ArticleSource
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
}

struct ArticleSource: Codable {
    let name: String
}
