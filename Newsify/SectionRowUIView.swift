//
//  SectionRowUIView.swift
//  Newsify
//
//  Created by san-7 on 03/07/2026.
//

import SwiftUI

struct SectionRowUIView: View {
    let rank: Int
    let title: String
    let tag: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // Numero incrementato
            Text("\(rank)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.navy)
                .frame(width: 20, alignment: .leading)
            
            // Titolo della notizia
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.navy)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Tag con sfondo grigio chiaro
            Text(tag)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            // Freccia di navigazione interna alla card
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.secondary.opacity(0.4))
        }
    }
}
