//
//  BigNewsCardUIView.swift
//  Newsify
//
//  Created by san-7 on 02/07/2026.
//

import SwiftUI

struct BigNewsCardUIView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
                    
            // Immagine con Icona Cuffie sovrapposta
            ZStack(alignment: .topLeading) {
            // Immagine principale della notizia
                Image(systemName: "img")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .clipped()
                        
                // Icona Audio / Cuffie
                HStack(spacing: 4) {
                    Image(systemName: "headphones")
                        .font(.system(size: 11, weight: .bold))
                    Text("AUDIO")
                        .font(.system(size: 9, weight: .bold))
                }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                    .padding(12)
            }
            
            // Testi della notizia
            VStack(alignment: .leading, spacing: 6) {
                Text("Terremoto in Venezuela: palazzi crollati, 32 morti e 700 feriti")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                        
                Text("Prima Ora")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                        
                Text("Il terremoto di magnitudo 6.5 ha colpito nel pomeriggio la costa nord del Paese, distruggendo edifici e provocando il panico tra la popolazione. I soccorritori sono al lavoro...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
                    .padding(14)
        }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
            .padding(.horizontal)
    }
}


#Preview {
    BigNewsCardUIView()
}
