//
// ExploreView.swift
// Newsify
//
// Created by san-9 on 01/07/2026.
//

import SwiftUI

struct ExploreView: View {
    @State var catSelected = 0
    @State private var navigateToCategory = false
    @State private var showBotSheet = false
    @State private var showNotificationsSheet = false

    @StateObject private var viewModel = NewsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // Sfondo adattivo: chiaro/scuro senza bisogno di hex
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // BARRA SUPERIORE: Bot AI, Titolo e Notifiche
                    HStack {
                        Button {
                            showBotSheet = true
                        } label: {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(Color.black.opacity(0.04), in: Circle())
                        }

                        Spacer()

                        Text("Explore")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(.primary)

                        Spacer()

                        Button {
                            showNotificationsSheet = true
                        } label: {
                            Image(systemName: "bell.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(Color.black.opacity(0.04), in: Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // SELETTORE CATEGORIE
                    Picker("choose a cat", selection: $catSelected) {
                        Text("Per te").tag(0)
                        Text("Mondo").tag(1)
                        Text("Tech").tag(2)
                        Text("Sport").tag(3)
                    }
                    .pickerStyle(.segmented)
                    // Basta il tint: si adatta da solo a light/dark, niente più UIAppearance
                    .tint(.accentColor)
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // SCRITTA IN PRIMO PIANO
                    HStack {
                        Text("IN PRIMO PIANO OGGI")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            .font(.system(size: 12, weight: .bold))
                        Spacer()
                    }

                    // FEED SCORREVOLE DELLE NOTIZIE
                    Group {
                        if viewModel.isLoading && viewModel.articles.isEmpty {
                            Spacer()
                            ProgressView("Caricamento notizie…")
                            Spacer()
                        } else if let error = viewModel.errorMessage, viewModel.articles.isEmpty {
                            Spacer()
                            ContentUnavailableView(
                                "Errore",
                                systemImage: "wifi.exclamationmark",
                                description: Text(error)
                            )
                            Spacer()
                        } else {
                            ScrollView {
                                VStack(spacing: 14) {
                                    ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
                                        newsRow(for: article, isFirst: index == 0)
                                    }
                                }
                                .padding(.top, 4)
                                .padding(.bottom, 20)
                            }
                            .refreshable {
                                await viewModel.loadNews(query: query(for: catSelected))
                            }
                        }
                    }
                    .onChange(of: catSelected) { oldValue, newValue in
                        if newValue != 0 {
                            navigateToCategory = true
                        }
                    }
                } // fine vstack
            } // fine zstack
            .navigationDestination(isPresented: $navigateToCategory) {
                destinationView(for: catSelected)
            }
            .sheet(isPresented: $showBotSheet) {
                BotSheetUIView()
            }
            .sheet(isPresented: $showNotificationsSheet) {
                NotificationsSheetUIView()
            }
            .task {
                // Carica le notizie della home ("Per te") al primo avvio
                await viewModel.loadNews(query: query(for: 0))
            }
        } // fine navstack
        // Imposta qui il colore del brand: si applica a tint/accent in tutta la view,
        // e ancora meglio se lo definisci come "Accent Color" nell'Asset Catalog
        // (con una variante Any/Dark), così ogni .tint lo eredita da solo.
        .tint(.brand)
    }

    /// Riga singola del feed: card grande per la prima notizia, piccola per le altre.
    /// Estratta in una funzione separata per evitare timeout del type-checker
    /// (il compilatore fatica con troppi modificatori/condizioni annidate in un'unica espressione).
    @ViewBuilder
    private func newsRow(for article: Article, isFirst: Bool) -> some View {
        NavigationLink(destination: EmptyView()) {
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

    /// Query di ricerca associata a ogni tab del picker.
    /// "Per te" mostra un feed generico sull'Italia; le altre categorie
    /// vengono comunque gestite dalla navigazione verso CategoryPlaceholderUIView.
    private func query(for category: Int) -> String {
        switch category {
        case 1: return "Mondo"
        case 2: return "Tecnologia"
        case 3: return "Sport"
        default: return "Italia"
        }
    }

    @ViewBuilder
    private func destinationView(for category: Int) -> some View {
        switch category {
        case 1:
            CategoryPlaceholderUIView(categoryName: "Mondo")
        case 2:
            CategoryPlaceholderUIView(categoryName: "Tech")
        case 3:
            CategoryPlaceholderUIView(categoryName: "Sport")
        default:
            EmptyView()
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
