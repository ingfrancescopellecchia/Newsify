//
//  NewsListView.swift
//  Newsify
//

import SwiftUI

struct NewsListView: View {
    @StateObject private var viewModel = NewsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading news...")
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "wifi.exclamationmark",
                        description: Text(error)
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.articles) {
                                article in
                                SmallNewsCardUIView(
                                    title: article.title,
                                    source: article.source.name
                                )
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Newsify")
            .task {
                await viewModel.loadNews()
            }
        }
    }
}

#Preview {
    NewsListView()
}
