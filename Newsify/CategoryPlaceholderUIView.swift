//
//  CategoryPlaceholderUIView.swift
//  Newsify
//
//  Created by san-7 on 02/07/2026.
//

import SwiftUI

struct CategoryPlaceholderUIView: View {
    let categoryName: String
    var body: some View {
        ZStack {
            Color(hex: "F4F4F4")
                .ignoresSafeArea()
                    
            VStack {
                Text("Sezione \(categoryName)")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color(hex: "003D6C"))
                        
                Text("Qui vedrai solo le notizie della categoria \(categoryName.lowercased()).")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CategoryPlaceholderUIView(categoryName: "sport")
}
