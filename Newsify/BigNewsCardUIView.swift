//
//  BigNewsCardUIView.swift
//  Newsify
//
//  Created by san-7 on 02/07/2026.
//

import SwiftUI

struct BigNewsCardUIView: View {
    let title: String
    let source: String
    var description: String? = nil
    var imageURL: URL? = nil
    
    // Manager condiviso per la lettura audio delle notizie.
    @ObservedObject private var audioPlayer = ArticleAudioPlayer.shared

    // Identificatore univoco dell'articolo per sapere se STA leggendo proprio questa card.
    // Se in futuro l'Article ha un id/UUID proprio, passalo qui invece del titolo.
    private var articleID: String { title }

    private var isPlayingThisArticle: Bool {
        audioPlayer.isPlaying(articleID)
    }

    // Testo che verrà letto ad alta voce: fonte, titolo e descrizione.
    private var textToRead: String {
        [source, title, description]
            .compactMap { $0 }
            .joined(separator: ". ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Immagine con Icona Cuffie sovrapposta
            ZStack(alignment: .topLeading) {
                // Immagine principale della notizia, caricata dall'URL dell'articolo.
                // Se manca o fallisce, mostra un placeholder grigio invece di un asset statico.
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        Color(.systemGray5)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                            }
                    @unknown default:
                        Color(.systemGray5)
                    }
                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipped()

                // Icona Audio / Cuffie — ora è un bottone che avvia/ferma la lettura vocale.
                Button {
                    audioPlayer.toggle(articleID: articleID, text: textToRead)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isPlayingThisArticle ? "stop.fill" : "headphones")
                            .font(.system(size: 11, weight: .bold))
                        Text(isPlayingThisArticle ? "IN ASCOLTO" : "AUDIO")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
                .padding(12)
                .animation(.easeInOut(duration: 0.2), value: isPlayingThisArticle)
            }

            // Testi della notizia
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Text(source)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)

                if let description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
            }
            .padding(14)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
        .padding(.horizontal)
    }
}

#Preview {
    BigNewsCardUIView(
        title: "Terremoto in Venezuela: palazzi crollati, 32 morti e 700 feriti",
        source: "Prima Ora",
        description: "Il terremoto di magnitudo 6.5 ha colpito nel pomeriggio la costa nord del Paese, distruggendo edifici e provocando il panico tra la popolazione. I soccorritori sono al lavoro..."
    )
}

#Preview("Dark") {
    BigNewsCardUIView(
        title: "Terremoto in Venezuela: palazzi crollati, 32 morti e 700 feriti",
        source: "Prima Ora",
        description: "Il terremoto di magnitudo 6.5 ha colpito nel pomeriggio la costa nord del Paese, distruggendo edifici e provocando il panico tra la popolazione. I soccorritori sono al lavoro..."
    )
    .preferredColorScheme(.dark)
}
