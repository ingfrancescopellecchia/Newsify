//
//  SmallNewsCardUIView.swift
//  Newsify
//
//  Created by san-7 on 02/07/2026.
//

import SwiftUI

struct SmallNewsCardUIView: View {
    let title: String
    let source: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            Text(source)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    SmallNewsCardUIView(title: "Titolo della notizia", source:"Cronaca")
}
