//
// ExploreView.swift
// Newsify
//
// Created by san-9 on 01/07/2026.
//

import SwiftUI

struct ExploreView: View {
    @State var catSelected = 0
    @State private var showBotSheet = false
    @State private var showNotificationsSheet = false
    
    // Notizia selezionata per aprire il dettaglio
    @State private var selectedArticle: Article?
    
    @StateObject private var viewModel = NewsViewModel()
    @ObservedObject private var bookmarksManager = BookmarksManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.cream)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // BARRA SUPERIORE: Bot AI, Titolo e Notifiche
                    HStack {
                        Button {
                            showBotSheet = true
                        } label: {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(.navy)
                                .padding(10)
                                .background(Color.black.opacity(0.04), in: Circle())
                        }
                        Spacer()
                        Text("Explore")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(.navy)
                        Spacer()
                        Button {
                            showNotificationsSheet = true
                        } label: {
                            Image(systemName: "bell.fill")
                                .font(.title2)
                                .foregroundColor(.navy)
                                .padding(10)
                                .background(Color.black.opacity(0.04), in: Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // SELETTORE CATEGORIE
                    Picker("Choose a category", selection: $catSelected) {
                        Text("For You").tag(0)
                        Text("World").tag(1)
                        Text("Tech").tag(2)
                        Text("Sport").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .tint(.accentColor)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // SCRITTA IN PRIMO PIANO
                    HStack {
                        Text("TODAY'S TOP STORIES")
                            .foregroundStyle(.navy)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            .font(.system(size: 12, weight: .bold))
                        Spacer()
                    }
                    
                    // FEED DELLE NOTIZIE
                    Group {
                        if viewModel.isLoading && viewModel.articles.isEmpty {
                            Spacer()
                            ProgressView("Loading news...")
                            Spacer()
                        } else if let error = viewModel.errorMessage, viewModel.articles.isEmpty {
                            Spacer()
                            ContentUnavailableView(
                                "Error",
                                systemImage: "wifi.exclamationmark",
                                description: Text(error)
                            )
                            Spacer()
                        } else {
                            List {
                                ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
                                    newsRow(for: article, isFirst: index == 0)
                                        .padding(.vertical, 7)
                                        .listRowInsets(EdgeInsets())
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            bookmarkButton(for: article)
                                        }
                                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                            bookmarkButton(for: article)
                                        }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .padding(.top, 4)
                            .refreshable {
                                await viewModel.loadNews(query: query(for: catSelected))
                            }
                        }
                    }
                    // QUI AVVIENE LA MAGIA: Al cambio del selettore, scarichiamo i nuovi dati
                    .onChange(of: catSelected) { oldValue, newValue in
                        Task {
                            await viewModel.loadNews(query: query(for: newValue))
                        }
                    }
                } // fine vstack
            } // fine zstack
            // Navigazione solo verso il dettaglio della notizia
            .navigationDestination(item: $selectedArticle) { article in
                NewsDetailView(article: article)
            }
            .sheet(isPresented: $showBotSheet) {
                BotSheetUIView(articles: viewModel.articles)
            }
            .sheet(isPresented: $showNotificationsSheet) {
                NotificationsSheetUIView()
            }
            .task {
                // Load the home feed ("For You") on first launch
                await viewModel.loadNews(query: query(for: catSelected))
            }
        } // fine navstack
        .tint(.brand)
    }
    
    // MARK: - Subviews & Helpers
    
    @ViewBuilder
    private func newsRow(for article: Article, isFirst: Bool) -> some View {
        Button {
            selectedArticle = article
        } label: {
            if isFirst {
                BigNewsCardUIView(
                    title: article.title,
                    source: article.source.name,
                    description: article.description,
                    imageURL: article.urlToImage.flatMap(URL.init)
                )
            } else {
                SmallNewsCardUIView(
                    title: article.title,
                    source: article.source.name
                )
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func bookmarkButton(for article: Article) -> some View {
        let saved = bookmarksManager.isBookmarked(article)
        Button {
            withAnimation {
                bookmarksManager.toggle(article)
            }
        } label: {
            Label(
                saved ? "Remove" : "Save",
                systemImage: saved ? "bookmark.slash.fill" : "bookmark.fill"
            )
        }
        .tint(saved ? .gray : .brand)
    }
    
    private func query(for category: Int) -> String {
        switch category {
        case 0: return "General" // Sostituisci "General" con la tua query di default per "For You"
        case 1: return "World"
        case 2: return "Tech"
        case 3: return "Sport"
        default: return "General"
        }
    }
}

#Preview {
    ExploreView()
}

#Preview("Dark") {
    ExploreView()
        .preferredColorScheme(.dark)
}
